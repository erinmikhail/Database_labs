BEGIN;

SELECT (SELECT COUNT(*) FROM clients)        AS clients,
       (SELECT COUNT(*) FROM rentals)        AS rentals,
       (SELECT COUNT(*) FROM rental_options) AS rental_options,
       (SELECT COUNT(*) FROM options)        AS options;

INSERT INTO clients (full_name, passport, driver_license, email, phone, birth_date)
VALUES ('Зайцев Кирилл Андреевич', '4535 167890', '77 ХХ 167890',
        'zaitsev@mail.ru', '+7-916-210-66-77', '1994-06-12')
RETURNING client_id, full_name;

INSERT INTO rentals (client_id, car_id, start_date, end_date, status, total_price)
SELECT cl.client_id,
       c.car_id,
       DATE '2026-10-30',
       DATE '2026-11-02',
       'active',
       (DATE '2026-11-02' - DATE '2026-10-30') * cc.price_per_day
FROM clients cl
CROSS JOIN cars c
JOIN car_classes cc ON cc.class_id = c.class_id
WHERE cl.passport = '4535 167890'
  AND c.license_plate = 'Е666НН99'
RETURNING rental_id, client_id, car_id, total_price;

INSERT INTO rental_options (rental_id, option_id, quantity, price_at_rental)
SELECT r.rental_id, o.option_id, 1, o.price
FROM rentals r
JOIN clients cl ON cl.client_id = r.client_id
JOIN options o  ON o.option_name IN ('Навигатор', 'Детское кресло')
WHERE cl.passport = '4535 167890'
RETURNING rental_id, option_id, price_at_rental;

UPDATE cars SET status = 'rented' WHERE license_plate = 'Е666НН99';

UPDATE rentals
SET status = 'completed',
    actual_return_date = DATE '2026-10-30'
WHERE rental_id = 38
  AND status = 'active'
RETURNING rental_id, status, end_date, actual_return_date,
          actual_return_date - end_date AS days_late;

UPDATE cars SET status = 'available'
WHERE car_id = (SELECT car_id FROM rentals WHERE rental_id = 38);

UPDATE cars
SET status = 'maintenance'
WHERE manufacture_year <= 2021
  AND status = 'available'
RETURNING car_id, brand, model, manufacture_year, status;

DELETE FROM options
WHERE option_name = 'Wi-Fi роутер'
RETURNING option_id, option_name;

SAVEPOINT before_car_delete;

DELETE FROM cars WHERE car_id = 5;

ROLLBACK TO SAVEPOINT before_car_delete;

DELETE FROM clients
WHERE passport = '4535 167890'
RETURNING client_id, full_name;

SELECT (SELECT COUNT(*) FROM rentals WHERE rental_id = 41)        AS rental_41_left,
       (SELECT COUNT(*) FROM rental_options WHERE rental_id = 41) AS its_options_left;

SELECT (SELECT COUNT(*) FROM options)                         AS options,
       (SELECT status FROM rentals WHERE rental_id = 38)      AS rental_38,
       (SELECT COUNT(*) FROM cars WHERE status = 'maintenance') AS cars_on_service;

ROLLBACK;

SELECT (SELECT COUNT(*) FROM options)                         AS options,
       (SELECT status FROM rentals WHERE rental_id = 38)      AS rental_38,
       (SELECT COUNT(*) FROM cars WHERE status = 'maintenance') AS cars_on_service,
       (SELECT COUNT(*) FROM clients)                         AS clients;
