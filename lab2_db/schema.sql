--  «Сервис аренды автомобилей»
-- Лабораторная работа №1


-- 0. Создание БД
CREATE DATABASE car_rental_db_lab1
	WITH ENCODING 'UTF8';



-- 1. Справочник классов автомобилей
CREATE TABLE car_classes (
	class_id	SERIAL PRIMARY KEY,
	class_name	VARCHAR(50) NOT NULL UNIQUE,
	price_per_day	NUMERIC(10,2) NOT NULL CHECK (price_per_day > 0),
	deposit_amount	NUMERIC(10,2) NOT NULL CHECK (deposit_amount >= 0),
	description TEXT
);



-- 2. Автомобили автопарка
CREATE TABLE cars (
    car_id           SERIAL PRIMARY KEY,
    license_plate    VARCHAR(15) NOT NULL UNIQUE,
    brand            VARCHAR(50) NOT NULL,
    model            VARCHAR(50) NOT NULL,
    manufacture_year SMALLINT NOT NULL
                     CHECK (manufacture_year BETWEEN 1990 AND 2100),
    class_id         INTEGER NOT NULL
                     REFERENCES car_classes(class_id)
                     ON DELETE RESTRICT,
    status           VARCHAR(20) NOT NULL DEFAULT 'available'
                     CHECK (status IN ('available','rented','maintenance','retired'))
);



-- 3. Клиенты
CREATE TABLE clients (
    client_id       SERIAL PRIMARY KEY,
    full_name       VARCHAR(150) NOT NULL,
    passport        VARCHAR(20) NOT NULL UNIQUE,
    driver_license  VARCHAR(20) NOT NULL UNIQUE,
    email           VARCHAR(100) NOT NULL UNIQUE
                    CHECK (email LIKE '%@%.%'),
    phone           VARCHAR(20) NOT NULL,
    birth_date      DATE NOT NULL
                    CHECK (birth_date < CURRENT_DATE)
);



-- 4. Договоры аренды
CREATE TABLE rentals (
	rental_id	SERIAL PRIMARY KEY,
	client_id	INTEGER NOT NULL
				REFERENCES clients(client_id)
				ON DELETE CASCADE,
	car_id	INTEGER NOT NULL
			REFERENCES cars(car_id)
			ON DELETE RESTRICT,
	start_date	DATE NOT NULL,
	end_date	DATE NOT NULL,
	status	VARCHAR(30) NOT NULL DEFAULT 'active'
			CHECK (status IN ('active', 'completed', 'cancelled')),
	total_price	NUMERIC(12,2) NOT NULL CHECK (total_price >= 0),
	created_at 	TIMESTAMP NOT NULL DEFAULT NOW(),
	CONSTRAINT chk_rental_dates CHECK (end_date > start_date)
);



-- 5. Справочник дополнительных опций
CREATE TABLE options (
    option_id    SERIAL PRIMARY KEY,
    option_name  VARCHAR(100) NOT NULL UNIQUE,
    price        NUMERIC(10,2) NOT NULL CHECK (price > 0)
);



-- 6. Связь аренд и опций (многие-ко-многим)
CREATE TABLE rental_options (
    rental_id    INTEGER NOT NULL
                 REFERENCES rentals(rental_id)
                 ON DELETE CASCADE,
    option_id    INTEGER NOT NULL
                 REFERENCES options(option_id)
                 ON DELETE RESTRICT,
    quantity     SMALLINT NOT NULL DEFAULT 1 CHECK (quantity > 0),
    PRIMARY KEY (rental_id, option_id)
);