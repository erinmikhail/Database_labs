SELECT r.rental_id,
       cl.full_name                        AS client,
       c.brand || ' ' || c.model           AS car,
       c.license_plate,
       cc.class_name,
       r.start_date,
       r.end_date,
       r.end_date - r.start_date           AS days,
       r.status,
       r.total_price,
       r.actual_return_date,
       CASE
           WHEN r.status = 'cancelled'                        THEN 'не выдавалась'
           WHEN r.actual_return_date > r.end_date             THEN 'возврат с опозданием'
           WHEN r.status = 'active' AND r.end_date < DATE '2026-10-30'
                                                              THEN 'ПРОСРОЧЕНА'
           WHEN r.status = 'active'                           THEN 'в аренде'
           ELSE 'вовремя'
       END                                 AS return_state
FROM rentals r
JOIN clients     cl ON cl.client_id = r.client_id
JOIN cars        c  ON c.car_id     = r.car_id
JOIN car_classes cc ON cc.class_id  = c.class_id
WHERE r.start_date >= DATE '2026-09-01'
ORDER BY r.start_date, r.rental_id;

SELECT cc.class_name,
       c.car_id,
       c.brand || ' ' || c.model AS car,
       c.status                  AS car_status,
       CASE WHEN c.car_id IS NULL THEN 'в классе нет машин'
            ELSE 'машина ни разу не сдавалась'
       END                       AS problem
FROM car_classes cc
LEFT JOIN cars    c ON c.class_id = cc.class_id
LEFT JOIN rentals r ON r.car_id   = c.car_id
                   AND r.status  <> 'cancelled'
WHERE r.rental_id IS NULL
ORDER BY cc.class_id, c.car_id;

SELECT r.rental_id,
       cl.full_name,
       cl.phone,
       c.brand || ' ' || c.model             AS car,
       cc.class_name,
       r.end_date,
       r.actual_return_date,
       r.actual_return_date - r.end_date     AS days_late,
       o.option_name
FROM rentals r
JOIN clients        cl ON cl.client_id = r.client_id
JOIN cars           c  ON c.car_id     = r.car_id
JOIN car_classes    cc ON cc.class_id  = c.class_id
JOIN rental_options ro ON ro.rental_id = r.rental_id
JOIN options        o  ON o.option_id  = ro.option_id
WHERE cc.class_name IN ('Бизнес', 'Внедорожник')
  AND r.actual_return_date > r.end_date
  AND o.option_name = 'Дополнительная страховка'
ORDER BY days_late DESC;

SELECT cc.class_name,
       COUNT(DISTINCT c.car_id)                                       AS cars,
       COUNT(r.rental_id)                                             AS rentals_total,
       COUNT(r.rental_id) FILTER (WHERE r.status = 'completed')       AS completed,
       COUNT(r.rental_id) FILTER (WHERE r.status = 'active')          AS active,
       COUNT(r.rental_id) FILTER (WHERE r.status = 'cancelled')       AS cancelled,
       COUNT(DISTINCT r.client_id)                                    AS unique_clients
FROM car_classes cc
LEFT JOIN cars    c ON c.class_id = cc.class_id
LEFT JOIN rentals r ON r.car_id   = c.car_id
GROUP BY cc.class_id, cc.class_name
ORDER BY rentals_total DESC, cc.class_id;

SELECT cl.full_name,
       COUNT(*)                         AS rentals,
       SUM(r.total_price)               AS total_spent,
       ROUND(AVG(r.total_price), 2)     AS avg_check,
       MIN(r.total_price)               AS min_check,
       MAX(r.total_price)               AS max_check,
       SUM(r.end_date - r.start_date)   AS total_days
FROM clients cl
JOIN rentals r ON r.client_id = cl.client_id
WHERE r.status <> 'cancelled'
GROUP BY cl.client_id, cl.full_name
HAVING COUNT(*) >= 3
ORDER BY total_spent DESC;

SELECT to_char(date_trunc('month', r.start_date), 'YYYY-MM')               AS month,
       COUNT(*)                                                             AS rentals,
       COUNT(*) FILTER (WHERE r.status = 'cancelled')                       AS cancelled,
       COUNT(*) FILTER (WHERE r.actual_return_date > r.end_date)            AS late_returns,
       SUM(r.total_price)   FILTER (WHERE r.status <> 'cancelled')          AS revenue,
       ROUND(AVG(r.total_price) FILTER (WHERE r.status <> 'cancelled'), 2)  AS avg_check,
       MAX(r.total_price)                                                   AS max_check
FROM rentals r
WHERE r.start_date >= DATE '2026-01-01'
GROUP BY date_trunc('month', r.start_date)
ORDER BY month;

SELECT r.rental_id,
       cl.full_name,
       cc.class_name,
       r.total_price,
       class_avg.avg_price                        AS class_avg_price,
       r.total_price - class_avg.avg_price        AS above_avg_by
FROM rentals r
JOIN clients     cl ON cl.client_id = r.client_id
JOIN cars        c  ON c.car_id     = r.car_id
JOIN car_classes cc ON cc.class_id  = c.class_id
JOIN (
        SELECT c2.class_id,
               ROUND(AVG(r2.total_price), 2) AS avg_price
        FROM rentals r2
        JOIN cars c2 ON c2.car_id = r2.car_id
        WHERE r2.status <> 'cancelled'
        GROUP BY c2.class_id
     ) AS class_avg ON class_avg.class_id = c.class_id
WHERE r.status <> 'cancelled'
  AND r.total_price > class_avg.avg_price
ORDER BY cc.class_name, above_avg_by DESC;

SELECT cl.client_id,
       cl.full_name,
       cl.phone
FROM clients cl
WHERE EXISTS (
        SELECT 1
        FROM rentals r
        WHERE r.client_id = cl.client_id
          AND r.actual_return_date > r.end_date
      )
ORDER BY cl.client_id;

SELECT c.car_id,
       c.brand || ' ' || c.model AS car,
       c.license_plate,
       c.status,
       (SELECT MAX(r2.start_date)
        FROM rentals r2
        WHERE r2.car_id = c.car_id
          AND r2.status <> 'cancelled')                AS last_rental
FROM cars c
WHERE c.status <> 'retired'
  AND NOT EXISTS (
        SELECT 1
        FROM rentals r
        WHERE r.car_id = c.car_id
          AND r.status <> 'cancelled'
          AND r.start_date >= DATE '2026-10-30' - 60
      )
ORDER BY c.car_id;

SELECT cl.client_id,
       cl.full_name,
       (SELECT COUNT(*)
        FROM rentals r
        WHERE r.client_id = cl.client_id
          AND r.status <> 'cancelled')                       AS rentals,
       (SELECT COALESCE(SUM(r.total_price), 0)
        FROM rentals r
        WHERE r.client_id = cl.client_id
          AND r.status <> 'cancelled')                       AS total_spent,
       (SELECT MAX(r.start_date)
        FROM rentals r
        WHERE r.client_id = cl.client_id
          AND r.status <> 'cancelled')                       AS last_rental,
       DATE '2026-10-30' -
       (SELECT MAX(r.start_date)
        FROM rentals r
        WHERE r.client_id = cl.client_id
          AND r.status <> 'cancelled')                       AS days_since_last
FROM clients cl
ORDER BY total_spent DESC, cl.client_id;
