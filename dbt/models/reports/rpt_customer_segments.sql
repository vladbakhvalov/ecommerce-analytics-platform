-- Report: Customer Segmentation

WITH users AS (
    SELECT * FROM {{ ref('dim_users') }}
)

SELECT
    segment,
    clv_tier,
    COUNT(*) AS user_count,
    ROUND(COUNT(*)::NUMERIC / SUM(COUNT(*)) OVER () * 100, 1) AS user_pct,
    SUM(total_revenue) AS segment_revenue,
    ROUND(SUM(total_revenue) / NULLIF(SUM(SUM(total_revenue)) OVER (), 0) * 100, 1) AS revenue_pct,
    ROUND(AVG(total_revenue), 2) AS avg_revenue_per_user,
    ROUND(AVG(total_orders), 1) AS avg_orders_per_user,
    ROUND(AVG(avg_order_value), 2) AS avg_order_value,
    ROUND(AVG(days_since_registration), 0) AS avg_tenure_days,
    ROUND(AVG(age), 0) AS avg_age

FROM users
GROUP BY segment, clv_tier
ORDER BY segment, clv_tier
