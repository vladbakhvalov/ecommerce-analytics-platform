-- Report: Executive Summary — daily summary
-- Used on page 1 of the Power BI dashboard

WITH daily AS (
    SELECT * FROM {{ ref('int_daily_revenue') }}
),

prev_period AS (
    SELECT
        *,
        LAG(total_revenue, 7) OVER (ORDER BY revenue_date) AS revenue_7d_ago,
        LAG(total_orders, 7) OVER (ORDER BY revenue_date) AS orders_7d_ago,
        AVG(total_revenue) OVER (
            ORDER BY revenue_date
            ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
        ) AS revenue_sma_7d,
        SUM(total_revenue) OVER (
            ORDER BY revenue_date
            ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
        ) AS revenue_rolling_30d
    FROM daily
)

SELECT
    revenue_date,
    total_orders,
    unique_customers,
    total_revenue,
    avg_order_value,
    total_units_sold,
    revenue_sma_7d,
    revenue_rolling_30d,
    
    -- WoW changes
    ROUND(
        (total_revenue - revenue_7d_ago) / NULLIF(revenue_7d_ago, 0) * 100, 1
    ) AS revenue_wow_change_pct,
    ROUND(
        (total_orders - orders_7d_ago) / NULLIF(orders_7d_ago, 0) * 100, 1
    ) AS orders_wow_change_pct

FROM prev_period
ORDER BY revenue_date
