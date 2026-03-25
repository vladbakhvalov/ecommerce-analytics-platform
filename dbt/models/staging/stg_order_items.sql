-- Staging: order items

WITH source AS (
    SELECT * FROM {{ source('raw', 'order_items') }}
)

SELECT
    order_item_id,
    order_id,
    product_id,
    quantity,
    unit_price,
    discount_pct,
    quantity * unit_price * (1 - discount_pct) AS line_revenue
FROM source
