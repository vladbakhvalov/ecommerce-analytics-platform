-- Intermediate: aggregation of orders by users
-- Used for dim_users: segment, CLV-tier, totals

WITH orders AS (
    SELECT * FROM {{ ref('stg_orders') }}
),

items AS (
    SELECT * FROM {{ ref('stg_order_items') }}
),

order_totals AS (
    SELECT
        o.order_id,
        o.user_id,
        o.order_date_day,
        SUM(i.line_revenue) AS order_revenue,
        SUM(i.quantity) AS order_items_count
    FROM orders o
    JOIN items i ON o.order_id = i.order_id
    GROUP BY o.order_id, o.user_id, o.order_date_day
)

SELECT
    user_id,
    COUNT(*) AS total_orders,
    SUM(order_revenue) AS total_revenue,
    AVG(order_revenue) AS avg_order_value,
    MIN(order_date_day) AS first_order_date,
    MAX(order_date_day) AS last_order_date,
    SUM(order_items_count) AS total_items_purchased,
    
    -- Segmentation
    CASE
        WHEN COUNT(*) = 0 THEN 'new'
        WHEN MAX(order_date_day) >= CURRENT_DATE - INTERVAL '30 days' AND COUNT(*) >= 3 THEN 'vip'
        WHEN MAX(order_date_day) >= CURRENT_DATE - INTERVAL '30 days' THEN 'active'
        WHEN MAX(order_date_day) >= CURRENT_DATE - INTERVAL '90 days' THEN 'returning'
        ELSE 'dormant'
    END AS calculated_segment,
    
    -- CLV Tier
    CASE
        WHEN SUM(order_revenue) >= 1000 THEN 'platinum'
        WHEN SUM(order_revenue) >= 500 THEN 'gold'
        WHEN SUM(order_revenue) >= 200 THEN 'silver'
        ELSE 'bronze'
    END AS calculated_clv_tier
    
FROM order_totals
GROUP BY user_id
