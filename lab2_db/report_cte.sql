WITH

params AS (
    SELECT DATE '2026-06-01' AS period_start,
           DATE '2026-10-30' AS report_date
),

base_rentals AS (
    SELECT r.rental_id,
           c.class_id,
           cc.price_per_day,
           r.total_price,
           COALESCE(r.actual_return_date, p.report_date) - r.start_date          AS used_days,
           GREATEST(COALESCE(r.actual_return_date, p.report_date) - r.end_date, 0) AS late_days
    FROM rentals r
    CROSS JOIN params p
    JOIN cars        c  ON c.car_id    = r.car_id
    JOIN car_classes cc ON cc.class_id = c.class_id
    WHERE r.status <> 'cancelled'
      AND r.start_date BETWEEN p.period_start AND p.report_date
),

option_revenue AS (
    SELECT ro.rental_id,
           SUM(ro.quantity * ro.price_at_rental) AS options_sum
    FROM rental_options ro
    GROUP BY ro.rental_id
),

rental_income AS (
    SELECT b.rental_id,
           b.class_id,
           b.used_days,
           b.late_days,
           b.total_price                            AS rent_sum,
           COALESCE(o.options_sum, 0)               AS options_sum,
           b.late_days * b.price_per_day            AS late_fee,
           b.total_price
             + COALESCE(o.options_sum, 0)
             + b.late_days * b.price_per_day        AS income
    FROM base_rentals b
    LEFT JOIN option_revenue o ON o.rental_id = b.rental_id
),

class_stats AS (
    SELECT ri.class_id,
           COUNT(*)                                   AS rentals,
           SUM(ri.rent_sum)                           AS rent_sum,
           SUM(ri.options_sum)                        AS options_sum,
           SUM(ri.late_fee)                           AS late_fees,
           SUM(ri.income)                             AS income,
           ROUND(AVG(ri.income), 2)                   AS avg_check,
           SUM(ri.used_days)                          AS used_days,
           COUNT(*) FILTER (WHERE ri.late_days > 0)   AS late_rentals
    FROM rental_income ri
    GROUP BY ri.class_id
),

fleet AS (
    SELECT class_id,
           COUNT(*) AS cars
    FROM cars
    WHERE status <> 'retired'
    GROUP BY class_id
)

SELECT cc.class_name,
       COALESCE(f.cars, 0)                                     AS cars,
       COALESCE(s.rentals, 0)                                  AS rentals,
       COALESCE(s.rent_sum, 0)                                 AS rent_sum,
       COALESCE(s.options_sum, 0)                              AS options_sum,
       COALESCE(s.late_fees, 0)                                AS late_fees,
       COALESCE(s.income, 0)                                   AS income,
       s.avg_check,
       COALESCE(s.late_rentals, 0)                             AS late_rentals,
       ROUND(s.income / NULLIF(f.cars, 0), 2)                  AS income_per_car,
       ROUND(100.0 * s.used_days
             / NULLIF(f.cars * (p.report_date - p.period_start), 0), 1)
                                                               AS utilization_pct,
       ROUND(100.0 * s.income / SUM(s.income) OVER (), 1)      AS income_share_pct
FROM car_classes cc
CROSS JOIN params p
LEFT JOIN fleet       f ON f.class_id = cc.class_id
LEFT JOIN class_stats s ON s.class_id = cc.class_id
ORDER BY income_per_car DESC NULLS LAST;
