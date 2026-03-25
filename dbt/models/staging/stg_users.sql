-- Staging: users
-- Source: raw.users

WITH source AS (
    SELECT * FROM {{ source('raw', 'users') }}
)

SELECT
    user_id,
    email,
    first_name,
    last_name,
    UPPER(country) AS country,
    city,
    registration_date,
    birth_date,
    gender,
    device_type,
    segment,
    clv_tier,
    total_orders,
    total_revenue,
    is_active,
    created_at
FROM source
