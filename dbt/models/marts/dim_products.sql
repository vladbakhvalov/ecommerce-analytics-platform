-- Dimension: Products

WITH products AS (
    SELECT * FROM {{ source('raw', 'products') }}
)

SELECT
    product_id,
    name AS product_name,
    category,
    subcategory,
    brand,
    price,
    cost,
    ROUND((price - cost) / NULLIF(price, 0) * 100, 1) AS margin_pct,
    price_segment,
    rating,
    reviews_count,
    stock_quantity,
    CASE
        WHEN stock_quantity = 0 THEN 'out_of_stock'
        WHEN stock_quantity < 10 THEN 'low_stock'
        WHEN stock_quantity < 50 THEN 'normal'
        ELSE 'in_stock'
    END AS stock_status,
    is_active

FROM products
