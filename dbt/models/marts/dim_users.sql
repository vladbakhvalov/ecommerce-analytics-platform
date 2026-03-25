-- Dimension: Users with segmentation and CLV

WITH users AS (
    SELECT * FROM {{ ref('stg_users') }}
),

user_orders AS (
    SELECT * FROM {{ ref('int_user_orders') }}
)

SELECT
    u.user_id,
    u.email,
    u.first_name,
    u.last_name,
    u.country,
    u.city,
    u.registration_date,
    u.birth_date,
    u.gender,
    u.device_type,
    
    -- Aggregated order data
    COALESCE(uo.total_orders, 0) AS total_orders,
    COALESCE(uo.total_revenue, 0) AS total_revenue,
    uo.avg_order_value,
    uo.first_order_date,
    uo.last_order_date,
    uo.total_items_purchased,
    
    -- Calculated segments
    COALESCE(uo.calculated_segment, 'new') AS segment,
    COALESCE(uo.calculated_clv_tier, 'bronze') AS clv_tier,
    
    -- Days since registration
    CURRENT_DATE - u.registration_date AS days_since_registration,
    
    -- Age
    EXTRACT(YEAR FROM AGE(u.birth_date))::INTEGER AS age,
    
    u.is_active

FROM users u
LEFT JOIN user_orders uo ON u.user_id = uo.user_id
