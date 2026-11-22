-- Применение кодировки 'UTF-8' для правильно чтения специальных символов и алфавита
SET client_encoding = 'UTF-8';

-- Быстрый сброс БД, для ускоренного процесса пересбора БД
DROP TABLE IF EXISTS payments, lessons, contracts, cadets, study_groups, cars, instructors, categories CASCADE;
DROP SEQUENCE IF EXISTS seq_contract_number;
DROP FUNCTION IF EXISTS fn_lesson_validate(), fn_contract_validate(), fn_payment_validate(), fn_payment_after(), fn_contract_status(int, numeric), fn_refresh_contract(int, int, numeric), fn_refresh_contract(int) CASCADE;
DROP PROCEDURE IF EXISTS sp_enroll_cadet(int, int, numeric);
DROP DOMAIN IF EXISTS d_full_name, d_phone, d_birth_date, d_money, d_money_pos, d_pos_int, d_passport_series, d_passport_number, d_plate, d_vin, d_certificate, d_gender, d_category_name, d_lesson_type, d_lesson_status, d_contract_status, d_pay_method, d_pay_status CASCADE;

-- Уникальный тип данных для ФИО: только буквы, от 2 до 4 слов, максимум 150 символов
CREATE DOMAIN d_full_name AS varchar(150)
 CONSTRAINT chk_full_name CHECK (VALUE ~ '^[А-Яа-яЁёA-Za-z-]+( [А-Яа-яЁёA-Za-z-]+){1,3}$');

-- Уникальный тип данных для номеров телефонов: обязательный формат '+7XXXXXXXXXX'
CREATE DOMAIN d_phone AS varchar(20)
 CONSTRAINT chk_phone CHECK (VALUE ~ '^\+7[0-9]{3}-[0-9]{3}-[0-9]{2}-[0-9]{2}$');

-- Уникальный тип данных для даты рождения: обязательный формат 'год - месяц - день'
CREATE DOMAIN d_birth_date AS date
 CONSTRAINT  chk_birth_date CHECK(VALUE <= CURRENT_DATE AND VALUE >= DATE'1920-01-01');

-- Уникальный тип данных для денежной суммы: неотрицательное число, до 10 знаков, до 2х знаков после запятой
CREATE DOMAIN d_money AS numeric(10, 2)
 CONSTRAINT chk_money CHECK(VALUE >= 0);

-- Уникальный тип данных для положительных денежных сумм: обязательно должно быть 0
CREATE DOMAIN d_money_pos AS numeric(10,2)
 CONSTRAINT chk_money_pos CHECK(VALUE > 0);

-- Уникальный тип данных для положительного числа: обязательно больше 0(1, 2, 3, ...)
CREATE DOMAIN d_pos_int AS integer
 CONSTRAINT chk_pos_int CHECK(VALUE > 0);

-- Уникальный тип данных для серии паспорта: числа от 0 до 9, 4х значное число
CREATE DOMAIN d_passport_series AS varchar(10)
 CONSTRAINT chk_passport_series CHECK(VALUE ~ '^[0-9]{4}$');

-- Уникальный тип данных для номера паспорта: числа от 0 до 9, 6ти значное число
CREATE DOMAIN d_passport_number AS varchar(20)
 CONSTRAINT chk_passport_number CHECK(VALUE ~ '^[0-9]{6}$');

-- Уникальный тип данных для номера автомобиля: обязательно используемые символы буквы и числа
CREATE DOMAIN d_plate AS varchar(20)
 CONSTRAINT chk_plate CHECK(VALUE ~ '^[АВЕКМНОРСТУХ][0-9]{3}[АВЕКМНОРСТУХ]{2}[0-9]{2,3}$');

-- Уникальный тип данных для VIN кода: ровно 17 символов(без букв I, O, Q)
CREATE DOMAIN d_vin AS varchar(20)
 CONSTRAINT chk_vin CHECK(VALUE ~ '^[A-HJ-NPR-Z0-9]{17}$');

-- Уникальный тип данных для удостоверения инструктора: от 4 до 50 символов(буквы, цифры, дефис)
CREATE DOMAIN d_certificate AS varchar(50)
 CONSTRAINT chk_certificate CHECK(VALUE ~ '^[0-9A-ZА-Я\-]{4,50}$');

-- Уникальный тип данных для пола: мужской или женский
CREATE DOMAIN d_gender AS varchar(20)
 CONSTRAINT chk_gender CHECK(VALUE IN ('мужской', 'женский'));

-- Уникальный тип данных для категории обучения: мотоциклы, машины, тяжёлые машины, фуры, автобусы и т.д.
CREATE DOMAIN d_category_name AS varchar(10)
 CONSTRAINT chk_category_name CHECK(VALUE IN ('A','B','C','D','E','BE','CE','DE'));

-- Уникальный тип данных для типа занятия: теория или практика
CREATE DOMAIN d_lesson_type AS varchar(20)
 CONSTRAINT chk_lesson_type CHECK(VALUE IN ('теория', 'практика'));

-- Уникальный тип данных для статуса занятия: запланировано, проведено или отменено
CREATE DOMAIN d_lesson_status AS varchar(20)
 CONSTRAINT chk_lesson_status CHECK(VALUE IN('запланирован','проведён','отменён'));

-- Уникальный тип данных для оплаты: оплачен, частично оплачен или не оплачен
CREATE DOMAIN d_contract_status AS varchar(20)
 CONSTRAINT chk_contract_status CHECK(VALUE IN('не оплачен','частично оплачен','оплачен полностью'));

-- Уникальный тип данных для способа оплаты: наличными или безналичными, возможна оплата онлайн
CREATE DOMAIN d_pay_method AS varchar(20)
 CONSTRAINT chk_pay_method CHECK(VALUE IN('наличные','безналичные','онлайн'));

-- Уникальный тип данных для статуса оплаты: сформирован, оплачен или отмена оплаты
CREATE DOMAIN d_pay_status AS varchar(20)
 CONSTRAINT chk_pay_status CHECK(VALUE IN('сформирован','оплачен','отменён'));

-- Таблица категорий обучения
CREATE TABLE categories (
 id	serial	PRIMARY KEY, -- идентификатор категории
 name	d_category_name NOT NULL, -- название катгории, по домену(А, В , С ...)
 min_age integer NOT NULL, -- порог вступления в обучение
 normative_hours d_pos_int NOT NULL, -- период обучения, по домену
 CONSTRAINT uq_categories_name UNIQUE (name), -- каждое название категории уникальное, не повторяется
 CONSTRAINT chk_categories_min_age CHECK (min_age >= 16) -- проверка возраста для прохождения минимального порога
);

-- Таблица информации про инструкторов автошколы
CREATE TABLE instructors (
 id	serial	PRIMARY KEY, -- идентификатор инструктора
 full_name	d_full_name	NOT NULL, -- ФИО инструктора, по домену
 birth_date d_birth_date NOT NULL, -- дата рождения, по домену
 phone	d_phone	NOT NULL, -- номер телефона, по домену
 address	varchar(200)	NOT NULL, -- адрес проживания, максимум 200 символов
 certificate_number d_certificate NOT NULL, -- номер удостоверения инструктора, по домену
 CONSTRAINT uq_instructors_certificate UNIQUE (certificate_number), -- номер удостоверения инструктора уникален, у каждого должен быть разный
 CONSTRAINT chk_instructors_age CHECK (birth_date <= CURRENT_DATE - INTERVAL '21 years') -- проверка соответствия мсинимального возраста для допуска к работе
);

-- Таблица учебных групп
CREATE TABLE study_groups (
 id	serial	PRIMARY KEY, -- идентификатор группы
 group_number varchar(30) NOT NULL, -- название группы, максимум 30 символов
 category_id integer NOT NULL REFERENCES categories(id) ON UPDATE CASCADE ON DELETE RESTRICT, -- ссылка на категорию прав
 lecturer_id integer	NOT NULL REFERENCES instructors(id) ON UPDATE CASCADE ON DELETE RESTRICT, -- ссылка на преподавателя группы
 start_date date NOT NULL, -- дата начала обучения, по домену
 end_date date NOT NULL, -- дата окончания обучения, по домену
 CONSTRAINT uq_study_groups_number UNIQUE (group_number), -- каждая группа уникальна, навзание и сама группы должна быть такая одна
 CONSTRAINT chk_study_groups_dates CHECK (end_date > start_date) -- проверка на обучения курсанта, дата окончания позже даты начала обучения
);

-- Таблица информации про автромобили
CREATE TABLE cars (
 id	serial	PRIMARY KEY, -- идентфикатор автомобиля
 make_model varchar(100)	NOT NULL, -- модель автомобиля, максимум 100 символов
 plate_number	d_plate	NOT NULL, -- уникальный номер автомобиля, по домену
 vin	d_vin	NOT NULL, -- вин код автомобиля, по домену
 category_id integer NOT NULL REFERENCES categories(id) ON UPDATE CASCADE ON DELETE RESTRICT, -- ссылка на категорию обучения
 CONSTRAINT uq_cars_plate UNIQUE (plate_number), -- номер автомобиля уникален, каждый автомобиль имеет свой номер
 CONSTRAINT uq_cars_vin UNIQUE (vin) -- вин код уникален, каждый автомобиль имеет свой вин код
);

-- Таблица информации про курсантов
CREATE TABLE cadets (
 id	serial	PRIMARY KEY, -- идентификатор курсанта
 full_name d_full_name NOT NULL, -- ФИО курсанта, по домену
 gender	d_gender	NOT NULL, -- пол курсанта, по домену
 birth_date d_birth_date NOT NULL, -- дата рождения курсанта, по домену
 phone	d_phone	NOT NULL, -- номер телефона, по домену
 passport_series	d_passport_series NOT NULL, -- серия паспорта курсанта, по домену
 passport_number d_passport_number NOT NULL, -- номер паспорта курсанта, по домену
 registration_address varchar(250) NOT NULL, -- адрес регистрации, максимум 250 символов
 group_id integer NOT NULL REFERENCES study_groups(id) ON UPDATE CASCADE ON DELETE RESTRICT, -- ссылка на группу
 CONSTRAINT uq_cadets_passport UNIQUE (passport_series, passport_number) -- серия и номер паспорта должны быть уникальны, у каждого курсанта свои
);

CREATE SEQUENCE seq_contract_number; -- создаём счётчик номеров договоров по порядку

CREATE TABLE contracts (
 id	serial	PRIMARY KEY, -- идентификатор договора
 contract_number	varchar(50)	NOT NULL DEFAULT('Д-' ||lpad(nextval('seq_contract_number')::text, 3, '0')), -- номер договора, максимум 50 символов, например 'Д-001'
 contract_date date NOT NULL DEFAULT CURRENT_DATE, -- дата заключения договора, дата, при пустой строке ставить дату - сегодня
 total_cost d_money NOT NULL, -- общая сумма, по домену
 payment_status d_contract_status NOT NULL DEFAULT 'не оплачен', -- статус оплаты, по домену
 cadet_id integer NOT NULL REFERENCES cadets(id) ON UPDATE CASCADE ON DELETE RESTRICT, -- ссылка на идентификатор курсанта
 category_id integer NOT NULL REFERENCES categories(id) ON UPDATE CASCADE ON DELETE RESTRICT, -- ссылка на категорию обучения
 CONSTRAINT uq_contracts_number UNIQUE (contract_number) -- номер договора должен быть уникален, каждый договор имеет свой номер
);

-- Таблица информации о оплате
CREATE TABLE payments (
 id	serial	PRIMARY KEY, -- идентификатор оплаты
 payment_date	date NOT NULL DEFAULT CURRENT_DATE, -- дата оплаты, по домену
 amount	d_money_pos	NOT NULL, -- общая цена оплаты, по домену
 payment_method	d_pay_method NOT NULL, -- способ оплаты, по домену
 status	d_pay_status	NOT NULL DEFAULT 'сформирован', -- статус оплаты, в пустой строке всегда писать сформирован
 contract_id	integer	NOT NULL REFERENCES contracts(id) ON UPDATE CASCADE ON DELETE RESTRICT -- ссылка на номер договора
);

-- Таблица информации о занятиях
CREATE TABLE lessons (
 id	serial	PRIMARY KEY, -- идентифкатор занятий
 topic	varchar(200) NOT NULL, -- тема занятия, максимум 200 символов
 lesson_type d_lesson_type NOT NULL, -- тип занятия, по домену
 lesson_date	date	NOT NULL, -- дата занятия, дата
 start_time time NOT NULL, -- время начала занятия, время
 status d_lesson_status NOT NULL DEFAULT 'запланирован', -- статус занятия, в пустой строке автоматически писать 'запланирован'
 group_id integer REFERENCES study_groups(id) ON UPDATE CASCADE ON DELETE RESTRICT, -- ссылка на идентификатор группы
 cadet_id integer REFERENCES cadets(id) ON UPDATE CASCADE ON DELETE RESTRICT,
 instructor_id integer REFERENCES instructors(id) ON UPDATE CASCADE ON DELETE RESTRICT, -- ссылка на идентификатор инструктора
 car_id integer REFERENCES cars(id) ON UPDATE CASCADE ON DELETE RESTRICT, -- ссылка на идентификатор автомобиля

-- Проверка на наличие нужного оборудования или условий для проведения занятий - теория/практика
  CONSTRAINT chk_lessons_participants CHECK ((lesson_type = 'теория' AND group_id IS NOT NULL AND cadet_id IS NULL AND instructor_id IS NULL AND car_id IS NULL)
   OR (lesson_type = 'практика' AND group_id IS NULL AND cadet_id IS NOT NULL AND instructor_id IS NOT NULL AND car_id IS NOT NULL))
);

-- Индекс уникального случая: один инструктор не может проводить несколько занятий одновременно
CREATE UNIQUE INDEX ux_lessons_instructor_time ON lessons (instructor_id, lesson_date, start_time) WHERE status <> 'отменён';

-- Индекс уникального случая: один автомобиль не может использоваться на двух занятиях одновременно
CREATE UNIQUE INDEX ux_lessons_car_time ON lessons(car_id, lesson_date, start_time) WHERE status <> 'отменён';

-- Индекс уникального случая: курсант не может быть на двух занятиях одновременно
CREATE UNIQUE INDEX ux_lessons_cadet_time ON Lessons(cadet_id, lesson_date, start_time) WHERE status <> 'отменён';

-- Индекс уникального случая: у одной группы не может быть два занятия одновременно
CREATE UNIQUE INDEX ux_lessons_group_time ON lessons(group_id, lesson_date, start_time) WHERE status <> 'отменён';

-- индекс скорого поиска: поиск курсанта по ФИО
CREATE INDEX idx_cadets_full_name ON cadets(full_name);

-- индекс скорого поиска: поиск курсанта по группе
CREATE INDEX idx_cadets_group ON cadets(group_id);

-- индекс скорого поиска: поиск договора по курсантам
CREATE INDEX idx_contracts_cadet ON contracts(cadet_id);

-- индекс скорого поиска: поиск оплаты по договору
CREATE INDEX idx_payments_contract ON payments(contract_id);

-- Функция изменения начала занятия
CREATE FUNCTION fn_lesson_validate() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE v_start timestamp := NEW.lesson_date + NEW.start_time; -- дата и время начала занятия
v_car_cat integer; -- категория автомобиля
BEGIN

-- устанавливаем правило, нельзя менять статус занятия, если оно уже не 'запланирован'
 IF TG_OP = 'UPDATE' AND OLD.status <>'запланирован' AND NEW.status <> OLD.status THEN 
  RAISE EXCEPTION 'статус занятия "%" изменить нельзя: допустимы только переходы "запланирован" → "проведён" / "отменён"', OLD.status
   USING ERRCODE = 'check_violation';
    END IF;

-- устанавливаем правило, нельзя запланировать занятия на время, которое уже прошло
 IF NEW.status = 'запланирован' AND v_start < now()
  AND (TG_OP = 'INSERT' OR OLD.lesson_date <> NEW.lesson_date OR OLD.start_time <> NEW.start_time) THEN
   RAISE EXCEPTION 'нельзя запланировать занятие на прошедшее время (%)', to_char(v_start, 'DD.MM.YYYY HH24:MI')
    USING ERRCODE = 'check_violation';
     END IF;

-- Устанавливаем правило, нельзя обучаться на другую категорию, не на ту что была выбрана при подписании договора
 IF NEW.lesson_type='практика' THEN
  SELECT category_id INTO v_car_cat FROM cars WHERE id = NEW.car_id;
  IF NOT EXISTS (SELECT 1 FROM contracts c WHERE c.cadet_id = NEW.cadet_id AND c.category_id = v_car_cat) THEN
   RAISE EXCEPTION 'У курсанта нет договора обучения на категорию выбранного транспорта'
    USING ERRCODE = 'check_violation';
  END IF;
 END IF;
 RETURN NEW;
END $$;

-- Создаём выполнение функции, каждый триггер работает построчно, проверяем наличие договора у курсанта перед записью его на занятие
CREATE TRIGGER trg_lesson_validate BEFORE INSERT OR UPDATE ON lessons
 FOR EACH ROW EXECUTE FUNCTION fn_lesson_validate();

-- Функция для создания проверки статуса оплаты договора
CREATE FUNCTION fn_contract_status(p_contract int, p_total numeric) RETURNS varchar
LANGUAGE sql STABLE AS $$ -- функция не изменяет данные и для одних и тех же входных значений всегда возвращает одинаковый результат
 SELECT CASE
 	WHEN s.paid = 0 THEN 'не оплачен' -- если сумма платежей равно 0 - 'не оплачен'
	WHEN s.paid < p_total THEN 'частично оплачен' -- если сумма платежей меньше полной стоимости - 'оплачен частично'
	ELSE 'оплачен полностью' -- в ином случае оплата проведена полностью
   END
  FROM (SELECT COALESCE(sum(amount), 0) AS paid -- считаем сумму всех платежей по договору
  	FROM payments WHERE contract_id = p_contract AND status = 'оплачен') s $$; -- выбираем все платежи только со статусом 'оплачен'

-- Функция для триггера, проверяет данные контракта после обновления, также проверяет минимальный допустимый возраст студента
CREATE FUNCTION fn_contract_validate() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE v_birth date; v_min integer; v_reserved numeric; -- создание переменных для хранения даты рождения, минимального допустимого возраста, таблицы для проверки всего этого 
BEGIN
 SELECT birth_date INTO v_birth FROM cadets WHERE id = NEW.cadet_id; -- получаем дату рождения из нового списка, после обновления или изменения
 SELECT min_age INTO v_min FROM categories WHERE id = NEW.category_id; -- получаем минимальный допустимый возраст для обучения выбранной категории транспорта после обновления или изменения

-- Функция для проверки, сверяем чтобы на момент заключения договора курсант достиг минимального допустимого возраста
 IF NEW.contract_date < v_birth + make_interval(years => v_min) THEN
  RAISE EXCEPTION 'Возраст курсанта на дату договора меньше минимального для категории (% лет)', v_min
  	USING ERRCODE = 'check_violation';
 END IF;

-- Блок выполнения операции обновления договора
 IF TG_OP = 'UPDATE' THEN
  -- считаем сумму уже ранее внесённых платежей по договору
  SELECT COALESCE(sum(amount), 0) INTO v_reserved
   FROM payments WHERE contract_id = NEW.id AND status <> 'отменён';
  IF NEW.total_cost < v_reserved THEN
   RAISE EXCEPTION 'Стоимость договора (%) меньше суммы платежей(%;)', -- если новая стоимость меньше уже внесённой, запрещаем уменьшение и выдаём текст
NEW.total_cost, v_reserved
    USING ERRCODE = 'check_violation';
  END IF;
  NEW.payment_status := fn_contract_status(NEW.id, NEW.total_cost); -- пересчитываем статус оплаты на основе новой стоимости и существующих платежей
 ELSE
  NEW.payment_status := 'не оплачен'; -- для нового договора по умолчанию ставим статус - 'не оплачен'
 END IF;
 RETURN NEW; -- возвращаем изменённую строку
END $$;

-- Триггер для таблицы contracts, срабатывает перед обновлением или изменением каждой строки 
CREATE TRIGGER trg_contract_validate BEFORE INSERT OR UPDATE ON contracts 
 FOR EACH ROW EXECUTE FUNCTION fn_contract_validate(); -- вызываем функцию для проверки возраста курсанта и стоимости договора

-- Функция триггер, проверяем корректность платежей при вставке
CREATE FUNCTION fn_payment_validate() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE v_total numeric; v_other numeric; -- переменные для хранения полной стоимости по договору, для хранения суммы остальных платежей по договору
BEGIN
 IF TG_OP = 'UPDATE' AND OLD.status <> 'сформирован' AND NEW.status <> OLD.status THEN -- проверка допустимых переходов статусов платежей при обновлениях
  RAISE EXCEPTION 'Статус платежа "%" изменять нельзя: допустимы только переходы "сформирован" → "оплачен"/ "отменён"', OLD.status -- допустимые виды переходов
   USING ERRCODE = 'check_violation';
 END IF;

-- Проверяем суммы платежей, работает только если новый платёж не будет отменён
 IF NEW.status <> 'отменён' THEN
  SELECT total_cost INTO v_total FROM contracts WHERE id = NEW.contract_id; -- получаем полную стоимость договора по его идентификатору
  SELECT COALESCE(sum(amount), 0) INTO v_other FROM payments
  WHERE contract_id = NEW.contract_id AND status <> 'отменён' AND id IS DISTINCT FROM NEW.id;
  IF v_other + NEW.amount > v_total THEN -- Проверяем, что сумма остальных платежей + текущий платёж не превышает стоимость договора
   RAISE EXCEPTION 'Сумма платежей (%) превышает стоимость договора (%)', v_other + NEW.amount, v_total
    USING ERRCODE = 'check_violation';
  END IF;
 END IF;
 RETURN NEW; -- возвращаем изменённую строку для вставки или обновления
END $$;

-- Триггер для таблицы payments - срабатывает до бновления или имзенения каждой строки 
CREATE TRIGGER trg_payment_validate BEFORE INSERT OR UPDATE ON payments
 FOR EACH ROW EXECUTE FUNCTION fn_payment_validate(); -- вызываем функцию для проверки оплаты и статусов платежей

-- Функция для проверки, пересчитываем статус оплаты конкретного договора
CREATE FUNCTION fn_refresh_contract(p_contract int) RETURNS void LANGUAGE sql AS $$
 UPDATE contracts SET payment_status = fn_contract_status(id, total_cost) WHERE id = p_contract $$; -- вызываем функцию расчёта статуса

-- AFTER-триггерная функция для той же таблицы
CREATE FUNCTION fn_payment_after() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
 -- При UPDATE или DELETE: пересчитываем статус СТАРОГО договора (по OLD.contract_id)
 IF TG_OP IN ('UPDATE', 'DELETE') THEN PERFORM fn_refresh_contract(OLD.contract_id);
 END IF;
 -- При INSERT или UPDATE: пересчитываем статус НОВОГО договора (по NEW.contract_id)
 IF TG_OP IN ('INSERT', 'UPDATE') THEN PERFORM fn_refresh_contract(NEW.contract_id);
 END IF;
  RETURN NULL; -- AFTER-триггер должен возвращать NULL
 END $$;

-- AFTER-триггер на таблице payments: срабатывает ПОСЛЕ вставки/обновления/удаления каждой строки
CREATE TRIGGER trg_payment_after AFTER INSERT OR UPDATE OR DELETE ON payments
 FOR EACH ROW EXECUTE FUNCTION fn_payment_after();

-- -- Процедура записи курсанта на обучение
CREATE PROCEDURE sp_enroll_cadet(p_cadet int, p_category int, p_cost numeric)
LANGUAGE sql AS $$
 INSERT INTO contracts (total_cost, cadet_id, category_id) VALUES (p_cost, p_cadet, p_category); $$;


 


