--
-- PostgreSQL database dump
--

\restrict t7kK1emook17AxroxuYayzaaqwHCCy7eIakdOiVMneRDrNLizvf3Bu4316ldOJe

-- Dumped from database version 14.19 (Homebrew)
-- Dumped by pg_dump version 16.16 (Homebrew)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: public; Type: SCHEMA; Schema: -; Owner: -
--

-- *not* creating schema, since initdb creates it


--
-- Name: d_birth_date; Type: DOMAIN; Schema: public; Owner: -
--

CREATE DOMAIN public.d_birth_date AS date
	CONSTRAINT chk_birth_date CHECK (((VALUE <= CURRENT_DATE) AND (VALUE >= '1920-01-01'::date)));


--
-- Name: d_category_name; Type: DOMAIN; Schema: public; Owner: -
--

CREATE DOMAIN public.d_category_name AS character varying(10)
	CONSTRAINT chk_category_name CHECK (((VALUE)::text = ANY ((ARRAY['A'::character varying, 'B'::character varying, 'C'::character varying, 'D'::character varying, 'E'::character varying, 'BE'::character varying, 'CE'::character varying, 'DE'::character varying])::text[])));


--
-- Name: d_certificate; Type: DOMAIN; Schema: public; Owner: -
--

CREATE DOMAIN public.d_certificate AS character varying(50)
	CONSTRAINT chk_certificate CHECK (((VALUE)::text ~ '^[0-9A-ZА-Я\-]{4,50}$'::text));


--
-- Name: d_contract_status; Type: DOMAIN; Schema: public; Owner: -
--

CREATE DOMAIN public.d_contract_status AS character varying(20)
	CONSTRAINT chk_contract_status CHECK (((VALUE)::text = ANY ((ARRAY['не оплачен'::character varying, 'частично оплачен'::character varying, 'оплачен полностью'::character varying])::text[])));


--
-- Name: d_full_name; Type: DOMAIN; Schema: public; Owner: -
--

CREATE DOMAIN public.d_full_name AS character varying(150)
	CONSTRAINT chk_full_name CHECK (((VALUE)::text ~ '^[А-Яа-яЁёA-Za-z-]+( [А-Яа-яЁёA-Za-z-]+){1,3}$'::text));


--
-- Name: d_gender; Type: DOMAIN; Schema: public; Owner: -
--

CREATE DOMAIN public.d_gender AS character varying(20)
	CONSTRAINT chk_gender CHECK (((VALUE)::text = ANY ((ARRAY['мужской'::character varying, 'женский'::character varying])::text[])));


--
-- Name: d_lesson_status; Type: DOMAIN; Schema: public; Owner: -
--

CREATE DOMAIN public.d_lesson_status AS character varying(20)
	CONSTRAINT chk_lesson_status CHECK (((VALUE)::text = ANY ((ARRAY['запланирован'::character varying, 'проведён'::character varying, 'отменён'::character varying])::text[])));


--
-- Name: d_lesson_type; Type: DOMAIN; Schema: public; Owner: -
--

CREATE DOMAIN public.d_lesson_type AS character varying(20)
	CONSTRAINT chk_lesson_type CHECK (((VALUE)::text = ANY ((ARRAY['теория'::character varying, 'практика'::character varying])::text[])));


--
-- Name: d_money; Type: DOMAIN; Schema: public; Owner: -
--

CREATE DOMAIN public.d_money AS numeric(10,2)
	CONSTRAINT chk_money CHECK ((VALUE >= (0)::numeric));


--
-- Name: d_money_pos; Type: DOMAIN; Schema: public; Owner: -
--

CREATE DOMAIN public.d_money_pos AS numeric(10,2)
	CONSTRAINT chk_money_pos CHECK ((VALUE > (0)::numeric));


--
-- Name: d_passport_number; Type: DOMAIN; Schema: public; Owner: -
--

CREATE DOMAIN public.d_passport_number AS character varying(20)
	CONSTRAINT chk_passport_number CHECK (((VALUE)::text ~ '^[0-9]{6}$'::text));


--
-- Name: d_passport_series; Type: DOMAIN; Schema: public; Owner: -
--

CREATE DOMAIN public.d_passport_series AS character varying(10)
	CONSTRAINT chk_passport_series CHECK (((VALUE)::text ~ '^[0-9]{4}$'::text));


--
-- Name: d_pay_method; Type: DOMAIN; Schema: public; Owner: -
--

CREATE DOMAIN public.d_pay_method AS character varying(20)
	CONSTRAINT chk_pay_method CHECK (((VALUE)::text = ANY ((ARRAY['наличные'::character varying, 'безналичные'::character varying, 'онлайн'::character varying])::text[])));


--
-- Name: d_pay_status; Type: DOMAIN; Schema: public; Owner: -
--

CREATE DOMAIN public.d_pay_status AS character varying(20)
	CONSTRAINT chk_pay_status CHECK (((VALUE)::text = ANY ((ARRAY['сформирован'::character varying, 'оплачен'::character varying, 'отменён'::character varying])::text[])));


--
-- Name: d_phone; Type: DOMAIN; Schema: public; Owner: -
--

CREATE DOMAIN public.d_phone AS character varying(20)
	CONSTRAINT chk_phone CHECK (((VALUE)::text ~ '^\+7[0-9]{3}-[0-9]{3}-[0-9]{2}-[0-9]{2}$'::text));


--
-- Name: d_plate; Type: DOMAIN; Schema: public; Owner: -
--

CREATE DOMAIN public.d_plate AS character varying(20)
	CONSTRAINT chk_plate CHECK (((VALUE)::text ~ '^[АВЕКМНОРСТУХ][0-9]{3}[АВЕКМНОРСТУХ]{2}[0-9]{2,3}$'::text));


--
-- Name: d_pos_int; Type: DOMAIN; Schema: public; Owner: -
--

CREATE DOMAIN public.d_pos_int AS integer
	CONSTRAINT chk_pos_int CHECK ((VALUE > 0));


--
-- Name: d_vin; Type: DOMAIN; Schema: public; Owner: -
--

CREATE DOMAIN public.d_vin AS character varying(20)
	CONSTRAINT chk_vin CHECK (((VALUE)::text ~ '^[A-HJ-NPR-Z0-9]{17}$'::text));


--
-- Name: fn_contract_status(integer, numeric); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_contract_status(p_contract integer, p_total numeric) RETURNS character varying
    LANGUAGE sql STABLE
    AS $$ -- функция не изменяет данные и для одних и тех же входных значений всегда возвращает одинаковый результат
 SELECT CASE
 	WHEN s.paid = 0 THEN 'не оплачен' -- если сумма платежей равно 0 - 'не оплачен'
	WHEN s.paid < p_total THEN 'частично оплачен' -- если сумма платежей меньше полной стоимости - 'оплачен частично'
	ELSE 'оплачен полностью' -- в ином случае оплата проведена полностью
   END
  FROM (SELECT COALESCE(sum(amount), 0) AS paid -- считаем сумму всех платежей по договору
  	FROM payments WHERE contract_id = p_contract AND status = 'оплачен') s $$;


--
-- Name: fn_contract_validate(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_contract_validate() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
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


--
-- Name: fn_lesson_validate(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_lesson_validate() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
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


--
-- Name: fn_payment_after(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_payment_after() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
 -- При UPDATE или DELETE: пересчитываем статус СТАРОГО договора (по OLD.contract_id)
 IF TG_OP IN ('UPDATE', 'DELETE') THEN PERFORM fn_refresh_contract(OLD.contract_id);
 END IF;
 -- При INSERT или UPDATE: пересчитываем статус НОВОГО договора (по NEW.contract_id)
 IF TG_OP IN ('INSERT', 'UPDATE') THEN PERFORM fn_refresh_contract(NEW.contract_id);
 END IF;
  RETURN NULL; -- AFTER-триггер должен возвращать NULL
 END $$;


--
-- Name: fn_payment_validate(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_payment_validate() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
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


--
-- Name: fn_refresh_contract(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_refresh_contract(p_contract integer) RETURNS void
    LANGUAGE sql
    AS $$
 UPDATE contracts SET payment_status = fn_contract_status(id, total_cost) WHERE id = p_contract $$;


--
-- Name: sp_enroll_cadet(integer, integer, numeric); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.sp_enroll_cadet(IN p_cadet integer, IN p_category integer, IN p_cost numeric)
    LANGUAGE sql
    AS $$
 INSERT INTO contracts (total_cost, cadet_id, category_id) VALUES (p_cost, p_cadet, p_category); $$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: cadets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cadets (
    id integer NOT NULL,
    full_name public.d_full_name NOT NULL,
    gender public.d_gender NOT NULL,
    birth_date public.d_birth_date NOT NULL,
    phone public.d_phone NOT NULL,
    passport_series public.d_passport_series NOT NULL,
    passport_number public.d_passport_number NOT NULL,
    registration_address character varying(250) NOT NULL,
    group_id integer NOT NULL
);


--
-- Name: cadets_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cadets_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cadets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cadets_id_seq OWNED BY public.cadets.id;


--
-- Name: cars; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cars (
    id integer NOT NULL,
    make_model character varying(100) NOT NULL,
    plate_number public.d_plate NOT NULL,
    vin public.d_vin NOT NULL,
    category_id integer NOT NULL
);


--
-- Name: cars_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cars_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cars_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cars_id_seq OWNED BY public.cars.id;


--
-- Name: categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.categories (
    id integer NOT NULL,
    name public.d_category_name NOT NULL,
    min_age integer NOT NULL,
    normative_hours public.d_pos_int NOT NULL,
    CONSTRAINT chk_categories_min_age CHECK ((min_age >= 16))
);


--
-- Name: categories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.categories_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.categories_id_seq OWNED BY public.categories.id;


--
-- Name: seq_contract_number; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_contract_number
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: contracts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.contracts (
    id integer NOT NULL,
    contract_number character varying(50) DEFAULT ('Д-'::text || lpad((nextval('public.seq_contract_number'::regclass))::text, 3, '0'::text)) NOT NULL,
    contract_date date DEFAULT CURRENT_DATE NOT NULL,
    total_cost public.d_money NOT NULL,
    payment_status public.d_contract_status DEFAULT 'не оплачен'::character varying NOT NULL,
    cadet_id integer NOT NULL,
    category_id integer NOT NULL
);


--
-- Name: contracts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.contracts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: contracts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.contracts_id_seq OWNED BY public.contracts.id;


--
-- Name: instructors; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.instructors (
    id integer NOT NULL,
    full_name public.d_full_name NOT NULL,
    birth_date public.d_birth_date NOT NULL,
    phone public.d_phone NOT NULL,
    address character varying(200) NOT NULL,
    certificate_number public.d_certificate NOT NULL,
    CONSTRAINT chk_instructors_age CHECK (((birth_date)::date <= (CURRENT_DATE - '21 years'::interval)))
);


--
-- Name: instructors_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.instructors_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: instructors_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.instructors_id_seq OWNED BY public.instructors.id;


--
-- Name: lessons; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lessons (
    id integer NOT NULL,
    topic character varying(200) NOT NULL,
    lesson_type public.d_lesson_type NOT NULL,
    lesson_date date NOT NULL,
    start_time time without time zone NOT NULL,
    status public.d_lesson_status DEFAULT 'запланирован'::character varying NOT NULL,
    group_id integer,
    cadet_id integer,
    instructor_id integer,
    car_id integer,
    CONSTRAINT chk_lessons_participants CHECK (((((lesson_type)::text = 'теория'::text) AND (group_id IS NOT NULL) AND (cadet_id IS NULL) AND (instructor_id IS NULL) AND (car_id IS NULL)) OR (((lesson_type)::text = 'практика'::text) AND (group_id IS NULL) AND (cadet_id IS NOT NULL) AND (instructor_id IS NOT NULL) AND (car_id IS NOT NULL))))
);


--
-- Name: lessons_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lessons_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lessons_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lessons_id_seq OWNED BY public.lessons.id;


--
-- Name: payments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.payments (
    id integer NOT NULL,
    payment_date date DEFAULT CURRENT_DATE NOT NULL,
    amount public.d_money_pos NOT NULL,
    payment_method public.d_pay_method NOT NULL,
    status public.d_pay_status DEFAULT 'сформирован'::character varying NOT NULL,
    contract_id integer NOT NULL
);


--
-- Name: payments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.payments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: payments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.payments_id_seq OWNED BY public.payments.id;


--
-- Name: study_groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.study_groups (
    id integer NOT NULL,
    group_number character varying(30) NOT NULL,
    category_id integer NOT NULL,
    lecturer_id integer NOT NULL,
    start_date date NOT NULL,
    end_date date NOT NULL,
    CONSTRAINT chk_study_groups_dates CHECK ((end_date > start_date))
);


--
-- Name: study_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.study_groups_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: study_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.study_groups_id_seq OWNED BY public.study_groups.id;


--
-- Name: cadets id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cadets ALTER COLUMN id SET DEFAULT nextval('public.cadets_id_seq'::regclass);


--
-- Name: cars id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cars ALTER COLUMN id SET DEFAULT nextval('public.cars_id_seq'::regclass);


--
-- Name: categories id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categories ALTER COLUMN id SET DEFAULT nextval('public.categories_id_seq'::regclass);


--
-- Name: contracts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contracts ALTER COLUMN id SET DEFAULT nextval('public.contracts_id_seq'::regclass);


--
-- Name: instructors id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.instructors ALTER COLUMN id SET DEFAULT nextval('public.instructors_id_seq'::regclass);


--
-- Name: lessons id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lessons ALTER COLUMN id SET DEFAULT nextval('public.lessons_id_seq'::regclass);


--
-- Name: payments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payments ALTER COLUMN id SET DEFAULT nextval('public.payments_id_seq'::regclass);


--
-- Name: study_groups id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.study_groups ALTER COLUMN id SET DEFAULT nextval('public.study_groups_id_seq'::regclass);


--
-- Data for Name: cadets; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cadets (id, full_name, gender, birth_date, phone, passport_series, passport_number, registration_address, group_id) FROM stdin;
1	Просеков Кирилл Григорьевич	мужской	2007-04-24	+7999-123-45-67	9204	123456	г. Тюмень, ул. Пушкина, д. 10, кв. 5	1
2	Матаев Давид Владимирович	мужской	2007-01-19	+7966-766-14-45	7121	588955	г. Тюмень, ул. Фабричная, д. 1, кв. 107	1
3	Шипунов Павел Андреевич	мужской	2007-02-22	+7972-156-49-65	7123	098765	г. Тюмень, ул. Александрова, д. 10, кв. 54	1
4	Бочанов Глеб Сергеевич	мужской	2007-12-27	+7922-871-09-10	7121	973457	г. Тюмень, ул. Чкаловская, д. 100, кв. 98	1
5	Шлома Степан Денисович	мужской	2006-05-15	+7932-642-78-14	7124	286443	г. Тюмень, ул. Ямская, д. 111, кв. 65	1
6	Ефремов Василий Игоревич	мужской	2004-02-20	+7992-939-09-11	7125	827916	г. Тюмень, ул. Орджинекидзе, д. 24, кв. 78	1
7	Мазер Максим Владимирович	мужской	2007-01-17	+7998-543-57-88	7234	127890	г. Тюмень, ул. Широтная, д. 222, кв. 2	2
8	Сунцов Андрей Владимирович	мужской	2007-05-16	+7943-988-54-32	7124	764230	г. Тюмень, ул. Свердлова, д. 5, кв. 1	2
9	Жарков Алексей Алексеевич	мужской	2007-09-12	+7956-091-07-59	7689	726134	г. Тюмень, ул. Пермякова, д. 7, кв. 14	2
10	Набоков Никита Денисович	мужской	2008-03-18	+7935-311-61-01	7120	738641	г. Тюмень, ул. Парфёнова, д. 17, кв. 23	2
11	Ганзя Максим Егорович	мужской	2005-01-10	+7966-755-54-53	7160	234567	г. Тюмень, ул. Одесская, д. 22, кв. 75	2
12	Ниазян Геннадий Александрович	мужской	2004-08-07	+7981-881-78-46	7126	345678	г. Тюмень, ул. Мельникайте, д. 123, кв. 43	4
13	Лебедев Павел Дмитриевич	мужской	2004-09-01	+7922-322-09-81	7119	456789	г. Тюмень, ул. Первомайская, д. 98, кв. 98	3
14	Щербаков Роман Андреевич	мужской	2004-04-05	+7967-422-02-32	7118	109876	г. Тюмень, ул. Советская, д. 65, кв. 59	3
\.


--
-- Data for Name: cars; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cars (id, make_model, plate_number, vin, category_id) FROM stdin;
1	Lada Granta	А123ВС72	XTA219010L1234567	2
2	Renault Logan	А345КХ72	Z94CB41AAGR323456	2
4	YAMAHA YBR125	М121ВС72	JYARJ12E1KA012345	1
5	КАМАЗ 4308	О654АК72	XTC65115XM1234567	3
6	ПАЗ - 3205-70	А541РК72	X1M3205CXA0000969	4
3	Kia Rio	Е987НТ77	XWEJP4A33H1234567	2
\.


--
-- Data for Name: categories; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.categories (id, name, min_age, normative_hours) FROM stdin;
1	A	16	108
2	B	16	190
3	C	18	224
4	D	21	200
5	BE	18	60
\.


--
-- Data for Name: contracts; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.contracts (id, contract_number, contract_date, total_cost, payment_status, cadet_id, category_id) FROM stdin;
1	Д-001	2026-09-23	39900.00	частично оплачен	1	2
2	Д-002	2026-09-25	39900.00	оплачен полностью	2	2
3	Д-003	2026-09-13	39900.00	частично оплачен	3	2
4	Д-004	2026-09-27	39900.00	оплачен полностью	4	2
5	Д-005	2026-09-28	39900.00	оплачен полностью	5	2
6	Д-006	2026-10-19	39900.00	оплачен полностью	6	2
7	Д-007	2026-10-08	39900.00	оплачен полностью	7	2
8	Д-008	2026-09-18	39900.00	оплачен полностью	8	2
9	Д-009	2026-10-14	39900.00	оплачен полностью	9	2
10	Д-010	2026-10-23	39900.00	оплачен полностью	10	2
11	Д-011	2026-09-24	39900.00	частично оплачен	11	2
12	Д-012	2026-09-26	39900.00	частично оплачен	12	4
13	Д-013	2026-10-01	49900.00	частично оплачен	13	3
14	Д-014	2026-10-03	44900.00	частично оплачен	14	3
\.


--
-- Data for Name: instructors; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.instructors (id, full_name, birth_date, phone, address, certificate_number) FROM stdin;
2	Селевёрстов Игорь Александрович	1986-04-15	+7917-451-66-77	город Тюмень, улица Ямская, дом 95, квартира 64	ИН-72-0011
3	Матвеев Александр Анатольевич	1987-04-15	+7981-450-65-78	город Тюмень, улица Первомайская, дом 65, квартира 43	ИН-72-0044
4	Водкин Григорий Михайлович	1986-04-15	+7917-451-66-77	город Тюмень, улица Чекалина, дом 87, квартира 61	ИН-72-0066
5	Горин Вячеслав Владимирович	1986-04-15	+7917-451-66-77	город Тюмень, улица Свердловская, дом 90, квартира 164	ИН-72-0013
1	Моисеев Владислав Игоревич	1985-04-15	+7917-450-66-77	город Тюмень, улица Зеленогорская, дом 94, квартира 6	ИН-72-0012
\.


--
-- Data for Name: lessons; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.lessons (id, topic, lesson_type, lesson_date, start_time, status, group_id, cadet_id, instructor_id, car_id) FROM stdin;
1	Общие положения ПДД	теория	2026-10-23	18:00:00	проведён	1	\N	\N	\N
2	Дорожные знаки	теория	2026-10-30	18:00:00	проведён	1	\N	\N	\N
3	Маневрирование	теория	2026-11-25	18:00:00	запланирован	1	\N	\N	\N
4	Основы законодательства	теория	2026-11-27	19:00:00	запланирован	1	\N	\N	\N
5	Дорожная разметка	теория	2026-11-29	19:00:00	запланирован	1	\N	\N	\N
6	Общие положения ПДД	теория	2026-09-03	18:00:00	проведён	2	\N	\N	\N
7	Дорожные знаки	теория	2026-09-08	18:00:00	проведён	2	\N	\N	\N
8	Маневрирование	теория	2026-09-13	18:00:00	проведён	2	\N	\N	\N
9	Основы законодательства	теория	2026-09-18	19:00:00	проведён	2	\N	\N	\N
10	Дорожная разметка	теория	2026-09-23	19:00:00	проведён	2	\N	\N	\N
11	Общие положения ПДД	теория	2026-11-12	18:00:00	проведён	3	\N	\N	\N
12	Дорожные знаки	теория	2026-11-17	18:00:00	проведён	3	\N	\N	\N
13	Маневрирование	теория	2026-11-23	18:00:00	запланирован	3	\N	\N	\N
14	Основы законодательства	теория	2026-11-27	19:00:00	запланирован	3	\N	\N	\N
15	Дорожная разметка	теория	2026-12-02	19:00:00	запланирован	3	\N	\N	\N
16	Общие положения ПДД	теория	2026-10-23	18:00:00	проведён	4	\N	\N	\N
17	Дорожные знаки	теория	2026-10-30	18:00:00	проведён	4	\N	\N	\N
18	Маневрирование	теория	2026-11-06	18:00:00	проведён	4	\N	\N	\N
19	Основы законодательства	теория	2026-11-13	19:00:00	проведён	4	\N	\N	\N
20	Дорожная разметка	теория	2026-11-20	19:00:00	проведён	4	\N	\N	\N
21	Езда по городу	практика	2026-11-23	16:00:00	отменён	\N	11	2	1
22	Начало движения, остановка	практика	2026-11-28	08:00:00	запланирован	\N	11	2	1
23	Начало движения, остановка	практика	2026-11-27	14:00:00	запланирован	\N	2	5	2
24	Движение по автодрому	практика	2026-11-26	11:00:00	запланирован	\N	2	5	2
25	Езда по городу	практика	2026-11-24	09:00:00	запланирован	\N	1	1	3
26	Движение по автодрому	практика	2026-11-15	09:00:00	проведён	\N	1	1	3
27	Начало движения, остановка	практика	2026-11-08	09:00:00	проведён	\N	1	1	3
\.


--
-- Data for Name: payments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.payments (id, payment_date, amount, payment_method, status, contract_id) FROM stdin;
1	2026-09-23	13300.00	онлайн	оплачен	1
2	2026-10-08	13300.00	наличные	оплачен	1
3	2026-10-23	13300.00	онлайн	сформирован	1
4	2026-09-23	30000.00	безналичные	оплачен	2
5	2026-10-13	9900.00	онлайн	оплачен	2
6	2026-10-06	13300.00	наличные	оплачен	3
7	2026-10-30	39900.00	безналичные	оплачен	4
8	2026-09-20	39900.00	онлайн	оплачен	5
9	2026-10-18	39900.00	онлайн	оплачен	6
10	2026-09-23	13300.00	наличные	оплачен	7
11	2026-10-13	13300.00	онлайн	оплачен	7
12	2026-11-02	13300.00	безналичные	оплачен	7
13	2026-09-23	39900.00	наличные	оплачен	8
14	2026-09-23	39900.00	онлайн	оплачен	9
15	2026-09-23	39900.00	онлайн	оплачен	10
16	2026-09-23	30000.00	онлайн	оплачен	11
17	2026-09-23	5000.00	безналичные	оплачен	11
18	2026-09-23	4900.00	безналичные	оплачен	12
19	2026-09-23	39900.00	наличные	оплачен	13
20	2026-09-23	39900.00	безналичные	оплачен	14
\.


--
-- Data for Name: study_groups; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.study_groups (id, group_number, category_id, lecturer_id, start_date, end_date) FROM stdin;
2	Л-005	2	2	2026-11-12	2027-01-21
3	С-001	3	4	2026-11-07	2026-12-27
4	Д-100	4	5	2026-11-12	2026-12-12
1	Л-004	2	1	2026-10-08	2027-01-06
\.


--
-- Name: cadets_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cadets_id_seq', 14, true);


--
-- Name: cars_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cars_id_seq', 6, true);


--
-- Name: categories_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.categories_id_seq', 5, true);


--
-- Name: contracts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.contracts_id_seq', 14, true);


--
-- Name: instructors_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.instructors_id_seq', 5, true);


--
-- Name: lessons_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.lessons_id_seq', 27, true);


--
-- Name: payments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.payments_id_seq', 20, true);


--
-- Name: seq_contract_number; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_contract_number', 14, true);


--
-- Name: study_groups_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.study_groups_id_seq', 4, true);


--
-- Name: cadets cadets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cadets
    ADD CONSTRAINT cadets_pkey PRIMARY KEY (id);


--
-- Name: cars cars_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cars
    ADD CONSTRAINT cars_pkey PRIMARY KEY (id);


--
-- Name: categories categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (id);


--
-- Name: contracts contracts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contracts
    ADD CONSTRAINT contracts_pkey PRIMARY KEY (id);


--
-- Name: instructors instructors_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.instructors
    ADD CONSTRAINT instructors_pkey PRIMARY KEY (id);


--
-- Name: lessons lessons_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lessons
    ADD CONSTRAINT lessons_pkey PRIMARY KEY (id);


--
-- Name: payments payments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_pkey PRIMARY KEY (id);


--
-- Name: study_groups study_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.study_groups
    ADD CONSTRAINT study_groups_pkey PRIMARY KEY (id);


--
-- Name: cadets uq_cadets_passport; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cadets
    ADD CONSTRAINT uq_cadets_passport UNIQUE (passport_series, passport_number);


--
-- Name: cars uq_cars_plate; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cars
    ADD CONSTRAINT uq_cars_plate UNIQUE (plate_number);


--
-- Name: cars uq_cars_vin; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cars
    ADD CONSTRAINT uq_cars_vin UNIQUE (vin);


--
-- Name: categories uq_categories_name; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT uq_categories_name UNIQUE (name);


--
-- Name: contracts uq_contracts_number; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contracts
    ADD CONSTRAINT uq_contracts_number UNIQUE (contract_number);


--
-- Name: instructors uq_instructors_certificate; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.instructors
    ADD CONSTRAINT uq_instructors_certificate UNIQUE (certificate_number);


--
-- Name: study_groups uq_study_groups_number; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.study_groups
    ADD CONSTRAINT uq_study_groups_number UNIQUE (group_number);


--
-- Name: idx_cadets_full_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_cadets_full_name ON public.cadets USING btree (full_name);


--
-- Name: idx_cadets_group; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_cadets_group ON public.cadets USING btree (group_id);


--
-- Name: idx_contracts_cadet; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_contracts_cadet ON public.contracts USING btree (cadet_id);


--
-- Name: idx_payments_contract; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_payments_contract ON public.payments USING btree (contract_id);


--
-- Name: ux_lessons_cadet_time; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX ux_lessons_cadet_time ON public.lessons USING btree (cadet_id, lesson_date, start_time) WHERE ((status)::text <> 'отменён'::text);


--
-- Name: ux_lessons_car_time; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX ux_lessons_car_time ON public.lessons USING btree (car_id, lesson_date, start_time) WHERE ((status)::text <> 'отменён'::text);


--
-- Name: ux_lessons_group_time; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX ux_lessons_group_time ON public.lessons USING btree (group_id, lesson_date, start_time) WHERE ((status)::text <> 'отменён'::text);


--
-- Name: ux_lessons_instructor_time; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX ux_lessons_instructor_time ON public.lessons USING btree (instructor_id, lesson_date, start_time) WHERE ((status)::text <> 'отменён'::text);


--
-- Name: contracts trg_contract_validate; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_contract_validate BEFORE INSERT OR UPDATE ON public.contracts FOR EACH ROW EXECUTE FUNCTION public.fn_contract_validate();


--
-- Name: lessons trg_lesson_validate; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_lesson_validate BEFORE INSERT OR UPDATE ON public.lessons FOR EACH ROW EXECUTE FUNCTION public.fn_lesson_validate();


--
-- Name: payments trg_payment_after; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_payment_after AFTER INSERT OR DELETE OR UPDATE ON public.payments FOR EACH ROW EXECUTE FUNCTION public.fn_payment_after();


--
-- Name: payments trg_payment_validate; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_payment_validate BEFORE INSERT OR UPDATE ON public.payments FOR EACH ROW EXECUTE FUNCTION public.fn_payment_validate();


--
-- Name: cadets cadets_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cadets
    ADD CONSTRAINT cadets_group_id_fkey FOREIGN KEY (group_id) REFERENCES public.study_groups(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: cars cars_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cars
    ADD CONSTRAINT cars_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.categories(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: contracts contracts_cadet_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contracts
    ADD CONSTRAINT contracts_cadet_id_fkey FOREIGN KEY (cadet_id) REFERENCES public.cadets(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: contracts contracts_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contracts
    ADD CONSTRAINT contracts_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.categories(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: lessons lessons_cadet_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lessons
    ADD CONSTRAINT lessons_cadet_id_fkey FOREIGN KEY (cadet_id) REFERENCES public.cadets(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: lessons lessons_car_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lessons
    ADD CONSTRAINT lessons_car_id_fkey FOREIGN KEY (car_id) REFERENCES public.cars(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: lessons lessons_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lessons
    ADD CONSTRAINT lessons_group_id_fkey FOREIGN KEY (group_id) REFERENCES public.study_groups(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: lessons lessons_instructor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lessons
    ADD CONSTRAINT lessons_instructor_id_fkey FOREIGN KEY (instructor_id) REFERENCES public.instructors(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: payments payments_contract_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_contract_id_fkey FOREIGN KEY (contract_id) REFERENCES public.contracts(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: study_groups study_groups_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.study_groups
    ADD CONSTRAINT study_groups_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.categories(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: study_groups study_groups_lecturer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.study_groups
    ADD CONSTRAINT study_groups_lecturer_id_fkey FOREIGN KEY (lecturer_id) REFERENCES public.instructors(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: -
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

\unrestrict t7kK1emook17AxroxuYayzaaqwHCCy7eIakdOiVMneRDrNLizvf3Bu4316ldOJe

