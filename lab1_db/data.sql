INSERT INTO car_classes (class_name, price_per_day, deposit_amount, description) VALUES
('Эконом',      1500.00,  5000.00, 'Бюджетные автомобили для города'),
('Комфорт',     3000.00, 10000.00, 'Повышенный комфорт, средний класс'),
('Бизнес',      7000.00, 25000.00, 'Премиальные автомобили'),
('Внедорожник', 5000.00, 20000.00, 'SUV для поездок за город');


INSERT INTO options (option_name, price) VALUES
('Детское кресло',            300.00),
('Навигатор',                 200.00),
('Дополнительная страховка',  500.00),
('Второй водитель',           400.00),
('Багажник на крышу',         250.00);


INSERT INTO cars (license_plate, brand, model, manufacture_year, class_id, status) VALUES
('А123ВС77',  'Lada',     'Vesta',    2022, 1, 'available'),
('В456ЕК99',  'Kia',      'Rio',      2021, 1, 'available'),
('С789МН77',  'Toyota',   'Camry',    2023, 2, 'available'),
('Е012ОР50',  'Hyundai',  'Sonata',   2022, 2, 'rented'),
('К345СТ77',  'BMW',      '5 Series', 2023, 3, 'available'),
('М678УХ99',  'Mercedes', 'E-Class',  2022, 3, 'maintenance'),
('Н901ФЦ77',  'Toyota',   'Land Cruiser', 2023, 4, 'available'),
('Р234ЦЧ50',  'Nissan',   'X-Trail',  2021, 4, 'available');


INSERT INTO clients (full_name, passport, driver_license, email, phone, birth_date) VALUES
('Иванов Иван Иванович',        '4510 123456', '77 АА 123456', 'ivanov@mail.ru',    '+7-916-111-22-33', '1985-03-15'),
('Петрова Анна Сергеевна',      '4512 234567', '77 ББ 234567', 'petrova@yandex.ru', '+7-925-222-33-44', '1990-07-22'),
('Сидоров Пётр Алексеевич',     '4514 345678', '77 ВВ 345678', 'sidorov@gmail.com', '+7-903-333-44-55', '1978-11-05'),
('Кузнецова Мария Дмитриевна',  '4516 456789', '77 ГГ 456789', 'kuznetsova@mail.ru','+7-926-444-55-66', '1995-01-30'),
('Смирнов Алексей Владимирович','4518 567890', '77 ДД 567890', 'smirnov@bk.ru',     '+7-915-555-66-77', '1982-09-12');


INSERT INTO rentals (client_id, car_id, start_date, end_date, status, total_price) VALUES
(1, 3, '2024-09-01', '2024-09-05', 'completed', 12000.00),
(2, 1, '2024-09-10', '2024-09-12', 'completed',  3000.00),
(3, 4, '2024-09-15', '2024-09-20', 'active',    15000.00),
(4, 7, '2024-09-18', '2024-09-25', 'active',    35000.00),
(5, 5, '2024-09-22', '2024-09-24', 'active',    14000.00),
(1, 2, '2024-08-01', '2024-08-03', 'cancelled',  3000.00);


INSERT INTO rental_options (rental_id, option_id, quantity) VALUES
(1, 2, 1),   
(1, 3, 1),  
(2, 1, 1),   
(3, 2, 1),
(3, 4, 1),  
(4, 2, 1),
(4, 5, 1),   
(4, 3, 1),  
(5, 1, 2), 
(5, 2, 1);  