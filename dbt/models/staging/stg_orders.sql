-- Staging: orders

WITH source AS (
    SELECT * FROM {{ source('raw', 'orders') }}
)

SELECT
    order_id,
    user_id,
    order_date,
    order_date::DATE AS order_date_day,
    status,
    payment_method,
    UPPER(shipping_country) AS shipping_country,
    campaign_id,
    created_at
FROM source
WHERE status NOT IN ('cancelled')  -- Exclude cancelled orders
