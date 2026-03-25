-- All rows with revenue should have a positive value
SELECT
    order_item_id,
    line_revenue
FROM {{ ref('fct_orders') }}
WHERE line_revenue < 0
  AND is_refunded = FALSE
  