BEGIN;

ALTER TABLE rentals ADD COLUMN actual_return_date DATE;

UPDATE rentals
SET actual_return_date = end_date
WHERE status = 'completed';

UPDATE rentals
SET status = 'completed',
    actual_return_date = end_date
WHERE status = 'active'
  AND end_date < DATE '2025-01-01';

ALTER TABLE rentals ADD CONSTRAINT chk_actual_return_after_start
    CHECK (actual_return_date IS NULL OR actual_return_date >= start_date);

ALTER TABLE rentals ADD CONSTRAINT chk_return_matches_status
    CHECK ((status = 'completed') = (actual_return_date IS NOT NULL));

ALTER TABLE rental_options ADD COLUMN price_at_rental NUMERIC(10,2);

UPDATE rental_options ro
SET price_at_rental = o.price
FROM options o
WHERE o.option_id = ro.option_id;

ALTER TABLE rental_options ALTER COLUMN price_at_rental SET NOT NULL;
ALTER TABLE rental_options ADD CONSTRAINT chk_price_at_rental
    CHECK (price_at_rental > 0);

UPDATE cars c
SET status = CASE
                 WHEN EXISTS (SELECT 1 FROM rentals r
                              WHERE r.car_id = c.car_id AND r.status = 'active')
                     THEN 'rented'
                 ELSE 'available'
             END
WHERE c.status IN ('available', 'rented');

COMMIT;
