-- Report: Conversion Funnel by Day
-- page_view -> product_view -> add_to_cart -> begin_checkout -> purchase

WITH user_daily_progress AS (
    SELECT
        event_date,
        device_type,
        user_id,
        MAX(funnel_step) AS max_funnel_step
    FROM {{ ref('fct_events') }}
    WHERE funnel_step > 0
    GROUP BY event_date, device_type, user_id
),

pivoted AS (
    SELECT
        event_date,
        device_type,

        COUNT(DISTINCT CASE WHEN max_funnel_step >= 1 THEN user_id END) AS page_views,
        COUNT(DISTINCT CASE WHEN max_funnel_step >= 2 THEN user_id END) AS product_views,
        COUNT(DISTINCT CASE WHEN max_funnel_step >= 3 THEN user_id END) AS add_to_carts,
        COUNT(DISTINCT CASE WHEN max_funnel_step >= 4 THEN user_id END) AS checkouts,
        COUNT(DISTINCT CASE WHEN max_funnel_step >= 5 THEN user_id END) AS purchases

    FROM user_daily_progress
    GROUP BY event_date, device_type
)

SELECT
    event_date,
    device_type,
    page_views,
    product_views,
    add_to_carts,
    checkouts,
    purchases,
    
    -- Conversion rates (%)
    ROUND(product_views::NUMERIC / NULLIF(page_views, 0) * 100, 2) AS cvr_view_to_product,
    ROUND(add_to_carts::NUMERIC / NULLIF(product_views, 0) * 100, 2) AS cvr_product_to_cart,
    ROUND(checkouts::NUMERIC / NULLIF(add_to_carts, 0) * 100, 2) AS cvr_cart_to_checkout,
    ROUND(purchases::NUMERIC / NULLIF(checkouts, 0) * 100, 2) AS cvr_checkout_to_purchase,
    ROUND(purchases::NUMERIC / NULLIF(page_views, 0) * 100, 2) AS cvr_overall

FROM pivoted
ORDER BY event_date, device_type
