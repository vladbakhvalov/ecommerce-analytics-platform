-- Fact: Orders (granularity: one row = one order item)

WITH orders AS (
    SELECT * FROM {{ ref('stg_orders') }}
),

items AS (
    SELECT * FROM {{ ref('stg_order_items') }}
),

products AS (
    SELECT product_id, cost FROM {{ source('raw', 'products') }}
)

SELECT
    i.order_item_id,
    o.order_id,
    o.user_id,
    i.product_id,
    o.campaign_id,
    
    -- Date keys
    TO_CHAR(o.order_date_day, 'YYYYMMDD')::INTEGER AS order_date_key,
    o.order_date,
    o.order_date_day,
    
    -- Order info
    o.status,
    o.payment_method,
    o.shipping_country,
    
    -- Item metrics
    i.quantity,
    i.unit_price,
    i.discount_pct,
    i.line_revenue,
    
    -- Cost & margin
    p.cost AS unit_cost,
    i.quantity * p.cost AS line_cost,
    i.line_revenue - (i.quantity * p.cost) AS line_profit,
    
    -- Flags
    CASE WHEN o.status = 'refunded' THEN TRUE ELSE FALSE END AS is_refunded,
    CASE WHEN o.campaign_id IS NOT NULL THEN TRUE ELSE FALSE END AS is_from_campaign

FROM orders o
JOIN items i ON o.order_id = i.order_id
LEFT JOIN products p ON i.product_id = p.product_id
