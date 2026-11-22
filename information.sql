SET client_encoding = 'UTF-8';

-- Справочник категорий
INSERT INTO categories(name, min_age, normative_hours) VALUES
 ('A',16,108),
 ('B',16,190),
 ('C',18,224),
 ('D',21,200),
 ('BE',18,60);

-- Вставка данных об инструкторах: ФИО, дата рождения, телефон, адрес и номер удостоверения
INSERT INTO instructors(full_name, birth_date, phone, address, certificate_number) VALUES
('Моисеев Владислав Игоревич', '1985-04-15', '+7917-450-66-77', 'город Тюмень, улица Зеленогорская, дом 94, квартира 6', 'ИН-72-0012'),
('Селевёрстов Игорь Александрович', '1986-04-15', '+7917-451-66-77', 'город Тюмень, улица Ямская, дом 95, квартира 64', 'ИН-72-0011'),
('Матвеев Александр Анатольевич', '1987-04-15', '+7981-450-65-78', 'город Тюмень, улица Первомайская, дом 65, квартира 43', 'ИН-72-0044'),
('Водкин Григорий Михайлович', '1986-04-15', '+7917-451-66-77', 'город Тюмень, улица Чекалина, дом 87, квартира 61', 'ИН-72-0066'),
('Горин Вячеслав Владимирович', '1986-04-15', '+7917-451-66-77', 'город Тюмень, улица Свердловская, дом 90, квартира 164', 'ИН-72-0013');

-- Создание учебных групп с привязкой к категории транспорта и инструктору
INSERT INTO study_groups(group_number, category_id, lecturer_id, start_date, end_date) VALUES
 ('Л-004', (SELECT id FROM categories WHERE name = 'B'), (SELECT id FROM instructors WHERE full_name = 'Моисеев Владислав Игоревич'), CURRENT_DATE - 45, CURRENT_DATE + 45),
 ('Л-005', (SELECT id FROM categories WHERE name = 'B'), (SELECT id FROM instructors WHERE full_name = 'Селевёрстов Игорь Александрович'), CURRENT_DATE - 10, CURRENT_DATE + 60),
 ('С-001', (SELECT id FROM categories WHERE name = 'C'), (SELECT id FROM instructors WHERE full_name = 'Водкин Григорий Михайлович'), CURRENT_DATE - 15, CURRENT_DATE + 35),
 ('Д-100', (SELECT id FROM categories WHERE name = 'D'), (SELECT id FROM instructors WHERE full_name = 'Горин Вячеслав Владимирович'), CURRENT_DATE - 10, CURRENT_DATE + 20);

-- Добавление учебных автомобилей: марка/модель, госномер, VIN и категория
INSERT INTO cars(make_model, plate_number, vin, category_id) VALUES
 ('Lada Granta', 'А123ВС72', 'XTA219010L1234567', (SELECT id FROM categories WHERE name = 'B')),
 ('Renault Logan', 'А345КХ72', 'Z94CB41AAGR323456', (SELECT id FROM categories WHERE name = 'B')),
 ('Kia Rio', 'Е987НТ77', 'XWEJP4A33H1234567', (SELECT id FROM categories WHERE name = 'B')),
 ('YAMAHA YBR125', 'М121ВС72', 'JYARJ12E1KA012345', (SELECT id FROM categories WHERE name = 'A')),
 ('КАМАЗ 4308', 'О654АК72', 'XTC65115XM1234567', (SELECT id FROM categories WHERE name = 'C')),
 ('ПАЗ - 3205-70', 'А541РК72', 'X1M3205CXA0000969', (SELECT id FROM categories WHERE name = 'D'));
 
-- Курсанты автошколы: ФИО, пол, дата рождения, номер телефона, серия паспорта, номер паспорта, адрес регистрации, идентификатор группы 
INSERT INTO cadets(full_name, gender, birth_date, phone, passport_series, passport_number, registration_address, group_id) VALUES
 ('Просеков Кирилл Григорьевич', 'мужской', '2007-04-24', '+7999-123-45-67', '9204', '123456', 'г. Тюмень, ул. Пушкина, д. 10, кв. 5', (SELECT id FROM study_groups WHERE group_number = 'Л-004')),
 ('Матаев Давид Владимирович', 'мужской', '2007-01-19', '+7966-766-14-45', '7121', '588955', 'г. Тюмень, ул. Фабричная, д. 1, кв. 107', (SELECT id FROM study_groups WHERE group_number = 'Л-004')),
 ('Шипунов Павел Андреевич', 'мужской', '2007-02-22', '+7972-156-49-65', '7123', '098765', 'г. Тюмень, ул. Александрова, д. 10, кв. 54', (SELECT id FROM study_groups WHERE group_number = 'Л-004')),
 ('Бочанов Глеб Сергеевич', 'мужской', '2007-12-27', '+7922-871-09-10', '7121', '973457', 'г. Тюмень, ул. Чкаловская, д. 100, кв. 98', (SELECT id FROM study_groups WHERE group_number = 'Л-004')),
 ('Шлома Степан Денисович', 'мужской', '2006-05-15', '+7932-642-78-14', '7124', '286443', 'г. Тюмень, ул. Ямская, д. 111, кв. 65', (SELECT id FROM study_groups WHERE group_number = 'Л-004')),
 ('Ефремов Василий Игоревич', 'мужской', '2004-02-20', '+7992-939-09-11', '7125', '827916', 'г. Тюмень, ул. Орджинекидзе, д. 24, кв. 78', (SELECT id FROM study_groups WHERE group_number = 'Л-004')),
 ('Мазер Максим Владимирович', 'мужской', '2007-01-17', '+7998-543-57-88', '7234', '127890', 'г. Тюмень, ул. Широтная, д. 222, кв. 2', (SELECT id FROM study_groups WHERE group_number = 'Л-005')),
 ('Сунцов Андрей Владимирович', 'мужской', '2007-05-16', '+7943-988-54-32', '7124', '764230', 'г. Тюмень, ул. Свердлова, д. 5, кв. 1', (SELECT id FROM study_groups WHERE group_number = 'Л-005')),
 ('Жарков Алексей Алексеевич', 'мужской', '2007-09-12', '+7956-091-07-59', '7689', '726134', 'г. Тюмень, ул. Пермякова, д. 7, кв. 14', (SELECT id FROM study_groups WHERE group_number = 'Л-005')),
 ('Набоков Никита Денисович', 'мужской', '2008-03-18', '+7935-311-61-01', '7120', '738641', 'г. Тюмень, ул. Парфёнова, д. 17, кв. 23', (SELECT id FROM study_groups WHERE group_number = 'Л-005')),
 ('Ганзя Максим Егорович', 'мужской', '2005-01-10', '+7966-755-54-53', '7160', '234567', 'г. Тюмень, ул. Одесская, д. 22, кв. 75', (SELECT id FROM study_groups WHERE group_number = 'Л-005')),
 ('Ниазян Геннадий Александрович', 'мужской', '2004-08-07', '+7981-881-78-46', '7126', '345678', 'г. Тюмень, ул. Мельникайте, д. 123, кв. 43', (SELECT id FROM study_groups WHERE group_number = 'Д-100')),
 ('Лебедев Павел Дмитриевич', 'мужской', '2004-09-01', '+7922-322-09-81', '7119', '456789', 'г. Тюмень, ул. Первомайская, д. 98, кв. 98', (SELECT id FROM study_groups WHERE group_number = 'С-001')),
 ('Щербаков Роман Андреевич', 'мужской', '2004-04-05', '+7967-422-02-32', '7118', '109876', 'г. Тюмень, ул. Советская, д. 65, кв. 59', (SELECT id FROM study_groups WHERE group_number = 'С-001'));

-- Контракты: номера контрактов, дата заключения контракта, общая стоимость, идентификатор курсанта, идентификатор категории транспорта
INSERT INTO contracts(contract_number, contract_date, total_cost, cadet_id,category_id) VALUES
 ('Д-001', CURRENT_DATE - 60, 39900, (SELECT id FROM cadets WHERE full_name = 'Просеков Кирилл Григорьевич'), (SELECT id FROM categories WHERE name = 'B')),
 ('Д-002', CURRENT_DATE - 58, 39900, (SELECT id FROM cadets WHERE full_name = 'Матаев Давид Владимирович'), (SELECT id FROM categories WHERE name = 'B')),
 ('Д-003', CURRENT_DATE - 70, 39900, (SELECT id FROM cadets WHERE full_name = 'Шипунов Павел Андреевич'), (SELECT id FROM categories WHERE name = 'B')),
 ('Д-004', CURRENT_DATE - 56, 39900, (SELECT id FROM cadets WHERE full_name = 'Бочанов Глеб Сергеевич'), (SELECT id FROM categories WHERE name = 'B')),
 ('Д-005', CURRENT_DATE - 55, 39900, (SELECT id FROM cadets WHERE full_name = 'Шлома Степан Денисович'), (SELECT id FROM categories WHERE name = 'B')),
 ('Д-006', CURRENT_DATE - 34, 39900, (SELECT id FROM cadets WHERE full_name = 'Ефремов Василий Игоревич'), (SELECT id FROM categories WHERE name = 'B')),
 ('Д-007', CURRENT_DATE - 45, 39900, (SELECT id FROM cadets WHERE full_name = 'Мазер Максим Владимирович'), (SELECT id FROM categories WHERE name = 'B')),
 ('Д-008', CURRENT_DATE - 65, 39900, (SELECT id FROM cadets WHERE full_name = 'Сунцов Андрей Владимирович'), (SELECT id FROM categories WHERE name = 'B')),
 ('Д-009', CURRENT_DATE - 39, 39900, (SELECT id FROM cadets WHERE full_name = 'Жарков Алексей Алексеевич'), (SELECT id FROM categories WHERE name = 'B')),
 ('Д-010', CURRENT_DATE - 30, 39900, (SELECT id FROM cadets WHERE full_name = 'Набоков Никита Денисович'), (SELECT id FROM categories WHERE name = 'B')),
 ('Д-011', CURRENT_DATE - 59, 39900, (SELECT id FROM cadets WHERE full_name = 'Ганзя Максим Егорович'), (SELECT id FROM categories WHERE name = 'B')),
 ('Д-012', CURRENT_DATE - 57, 39900, (SELECT id FROM cadets WHERE full_name = 'Ниазян Геннадий Александрович'), (SELECT id FROM categories WHERE name = 'D')),
 ('Д-013', CURRENT_DATE - 52, 49900, (SELECT id FROM cadets WHERE full_name = 'Лебедев Павел Дмитриевич'), (SELECT id FROM categories WHERE name = 'C')),
 ('Д-014', CURRENT_DATE - 50, 44900, (SELECT id FROM cadets WHERE full_name = 'Щербаков Роман Андреевич'), (SELECT id FROM categories WHERE name = 'C'));

-- Платежи: дата платежа, сумма платежа, способ оплаты, статус платежа, идентификатор контракта
INSERT INTO payments(payment_date, amount, payment_method, status, contract_id) VALUES
 (CURRENT_DATE - 60, 13300, 'онлайн', 'оплачен', (SELECT id FROM contracts WHERE contract_number = 'Д-001')),
 (CURRENT_DATE - 45, 13300, 'наличные', 'оплачен', (SELECT id FROM contracts WHERE contract_number = 'Д-001')),
 (CURRENT_DATE - 30, 13300, 'онлайн', 'сформирован', (SELECT id FROM contracts WHERE contract_number = 'Д-001')),
 (CURRENT_DATE - 60, 30000, 'безналичные', 'оплачен', (SELECT id FROM contracts WHERE contract_number = 'Д-002')),
 (CURRENT_DATE - 40, 9900, 'онлайн', 'оплачен', (SELECT id FROM contracts WHERE contract_number = 'Д-002')),
 (CURRENT_DATE - 47, 13300, 'наличные', 'оплачен', (SELECT id FROM contracts WHERE contract_number = 'Д-003')),
 (CURRENT_DATE - 23, 39900, 'безналичные', 'оплачен', (SELECT id FROM contracts WHERE contract_number = 'Д-004')),
 (CURRENT_DATE - 63, 39900, 'онлайн', 'оплачен', (SELECT id FROM contracts WHERE contract_number = 'Д-005')),
 (CURRENT_DATE - 35, 39900, 'онлайн', 'оплачен', (SELECT id FROM contracts WHERE contract_number = 'Д-006')),
 (CURRENT_DATE - 60, 13300, 'наличные', 'оплачен', (SELECT id FROM contracts WHERE contract_number = 'Д-007')),
 (CURRENT_DATE - 40, 13300, 'онлайн', 'оплачен', (SELECT id FROM contracts WHERE contract_number = 'Д-007')),
 (CURRENT_DATE - 20, 13300, 'безналичные', 'оплачен', (SELECT id FROM contracts WHERE contract_number = 'Д-007')),
 (CURRENT_DATE - 60, 39900, 'наличные', 'оплачен', (SELECT id FROM contracts WHERE contract_number = 'Д-008')),
 (CURRENT_DATE - 60, 39900, 'онлайн', 'оплачен', (SELECT id FROM contracts WHERE contract_number = 'Д-009')),
 (CURRENT_DATE - 60, 39900, 'онлайн', 'оплачен', (SELECT id FROM contracts WHERE contract_number = 'Д-010')),
 (CURRENT_DATE - 60, 30000, 'онлайн', 'оплачен', (SELECT id FROM contracts WHERE contract_number = 'Д-011')),
 (CURRENT_DATE - 60, 5000, 'безналичные', 'оплачен', (SELECT id FROM contracts WHERE contract_number = 'Д-011')),
 (CURRENT_DATE - 60, 4900, 'безналичные', 'оплачен', (SELECT id FROM contracts WHERE contract_number = 'Д-012')),
 (CURRENT_DATE - 60, 39900, 'наличные', 'оплачен', (SELECT id FROM contracts WHERE contract_number = 'Д-013')),
 (CURRENT_DATE - 60, 39900, 'безналичные', 'оплачен', (SELECT id FROM contracts WHERE contract_number = 'Д-014'));

-- Учебные занятия теории(в группах): тема занятия, тип занятия, дата занятия, время начала занятия, статус занятия, идентификатор группы
INSERT INTO lessons(topic, lesson_type, lesson_date, start_time, status, group_id) VALUES
 ('Общие положения ПДД', 'теория', CURRENT_DATE - 30, '18:00', 'проведён', (SELECT id FROM study_groups WHERE group_number = 'Л-004')),
 ('Дорожные знаки', 'теория', CURRENT_DATE - 23, '18:00', 'проведён', (SELECT id FROM study_groups WHERE group_number = 'Л-004')),
 ('Маневрирование', 'теория', CURRENT_DATE + 3,  '18:00', 'запланирован', (SELECT id FROM study_groups WHERE group_number = 'Л-004')),  
 ('Основы законодательства', 'теория', CURRENT_DATE + 5,  '19:00', 'запланирован', (SELECT id FROM study_groups WHERE group_number = 'Л-004')),
 ('Дорожная разметка', 'теория', CURRENT_DATE + 7,  '19:00', 'запланирован', (SELECT id FROM study_groups WHERE group_number = 'Л-004')),
 ('Общие положения ПДД', 'теория', CURRENT_DATE - 80, '18:00', 'проведён', (SELECT id FROM study_groups WHERE group_number = 'Л-005')),
 ('Дорожные знаки', 'теория', CURRENT_DATE - 75, '18:00', 'проведён', (SELECT id FROM study_groups WHERE group_number = 'Л-005')),
 ('Маневрирование', 'теория', CURRENT_DATE - 70,  '18:00', 'проведён', (SELECT id FROM study_groups WHERE group_number = 'Л-005')),
 ('Основы законодательства', 'теория', CURRENT_DATE - 65,  '19:00', 'проведён', (SELECT id FROM study_groups WHERE group_number = 'Л-005')),
 ('Дорожная разметка', 'теория', CURRENT_DATE - 60,  '19:00', 'проведён', (SELECT id FROM study_groups WHERE group_number = 'Л-005')),
 ('Общие положения ПДД', 'теория', CURRENT_DATE - 10, '18:00', 'проведён', (SELECT id FROM study_groups WHERE group_number = 'С-001')),
 ('Дорожные знаки', 'теория', CURRENT_DATE - 5, '18:00', 'проведён', (SELECT id FROM study_groups WHERE group_number = 'С-001')),
 ('Маневрирование', 'теория', CURRENT_DATE + 1,  '18:00', 'запланирован', (SELECT id FROM study_groups WHERE group_number = 'С-001')),
 ('Основы законодательства', 'теория', CURRENT_DATE + 5,  '19:00', 'запланирован', (SELECT id FROM study_groups WHERE group_number = 'С-001')),
 ('Дорожная разметка', 'теория', CURRENT_DATE + 10,  '19:00', 'запланирован', (SELECT id FROM study_groups WHERE group_number = 'С-001')),
 ('Общие положения ПДД', 'теория', CURRENT_DATE - 30, '18:00', 'проведён', (SELECT id FROM study_groups WHERE group_number = 'Д-100')),
 ('Дорожные знаки', 'теория', CURRENT_DATE - 23, '18:00', 'проведён', (SELECT id FROM study_groups WHERE group_number = 'Д-100')),
 ('Маневрирование', 'теория', CURRENT_DATE - 16,  '18:00', 'проведён', (SELECT id FROM study_groups WHERE group_number = 'Д-100')),
 ('Основы законодательства', 'теория', CURRENT_DATE - 9,  '19:00', 'проведён', (SELECT id FROM study_groups WHERE group_number = 'Д-100')),
 ('Дорожная разметка', 'теория', CURRENT_DATE - 2,  '19:00', 'проведён', (SELECT id FROM study_groups WHERE group_number = 'Д-100'));


-- Учебные занятия(практика): тема занятия, тип занятия, дата занятия, время начала занятия, статус занятия, идентификаторы курсанта/инструктора/автомобиля
INSERT INTO lessons(topic, lesson_type, lesson_date, start_time, status, cadet_id,instructor_id, car_id)
SELECT v.topic, 'практика', v.lesson_date, v.start_time, v.status, c.id, i.id, car.id
 FROM(VALUES
 ('Начало движения, остановка', CURRENT_DATE - 14, TIME '09:00', 'проведён', 'Просеков Кирилл Григорьевич', 'Моисеев Владислав Игоревич', 'Е987НТ77'),
 ('Движение по автодрому', CURRENT_DATE - 7,  TIME '09:00', 'проведён', 'Просеков Кирилл Григорьевич', 'Моисеев Владислав Игоревич', 'Е987НТ77'),
 ('Езда по городу', CURRENT_DATE + 2,  TIME '09:00', 'запланирован', 'Просеков Кирилл Григорьевич', 'Моисеев Владислав Игоревич', 'Е987НТ77'),
 ('Движение по автодрому', CURRENT_DATE + 4,  TIME '11:00', 'запланирован', 'Матаев Давид Владимирович', 'Горин Вячеслав Владимирович', 'А345КХ72'),
 ('Начало движения, остановка', CURRENT_DATE + 5,  TIME '14:00', 'запланирован', 'Матаев Давид Владимирович', 'Горин Вячеслав Владимирович', 'А345КХ72'),
 ('Начало движения, остановка', CURRENT_DATE + 6,  TIME '08:00', 'запланирован', 'Ганзя Максим Егорович', 'Селевёрстов Игорь Александрович', 'А123ВС72'),
 ('Езда по городу', CURRENT_DATE + 1,  TIME '16:00', 'отменён', 'Ганзя Максим Егорович', 'Селевёрстов Игорь Александрович', 'А123ВС72')

) AS v(topic, lesson_date, start_time, status, cadet, instructor, plate) -- завершаем заполнение, создаём виртуальную таблицу v
 JOIN cadets c ON c.full_name = v.cadet -- находим идентификатор курсанта по его ФИО
 JOIN instructors i ON i.full_name = v.instructor -- находим идентификатор инструктора по его ФИО
 JOIN cars car ON car.plate_number = v.plate; -- находим идентифкатор автомобиля по его государственному регистрационному номеру
-- Синхронизируем счётчик номеров договоров с уже вставленными данными, чтобы следующий договор получил номер 'Д-015'
 SELECT setval('seq_contract_number', (SELECT count(*) FROM contracts));
