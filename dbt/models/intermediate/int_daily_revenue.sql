-- Intermediate: daily revenue
-- Used for Executive Summary and trends

WITH orders AS (
    SELECT * FROM {{ ref('stg_orders') }}
),

items AS (
    SELECT * FROM {{ ref('stg_order_items') }}
)

SELECT
    o.order_date_day AS revenue_date,
    COUNT(DISTINCT o.order_id) AS total_orders,
    COUNT(DISTINCT o.user_id) AS unique_customers,
    SUM(i.line_revenue) AS total_revenue,
    SUM(i.line_revenue) / NULLIF(COUNT(DISTINCT o.order_id), 0) AS avg_order_value,
    SUM(i.quantity) AS total_units_sold
FROM orders o
JOIN items i ON o.order_id = i.order_id
GROUP BY o.order_date_day
