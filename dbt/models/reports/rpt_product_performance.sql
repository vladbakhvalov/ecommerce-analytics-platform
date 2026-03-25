-- Report: Product Performance

WITH product_sales AS (
    SELECT
        fo.product_id,
        dp.product_name,
        dp.category,
        dp.subcategory,
        dp.brand,
        dp.price,
        dp.margin_pct,
        dp.price_segment,
        dp.rating,
        dp.stock_status,
        
        COUNT(DISTINCT fo.order_id) AS order_count,
        SUM(fo.quantity) AS units_sold,
        SUM(fo.line_revenue) AS total_revenue,
        SUM(fo.line_profit) AS total_profit,
        COUNT(DISTINCT fo.user_id) AS unique_buyers,
        AVG(fo.discount_pct) AS avg_discount
        
    FROM {{ ref('fct_orders') }} fo
    JOIN {{ ref('dim_products') }} dp ON fo.product_id = dp.product_id
    WHERE fo.is_refunded = FALSE
    GROUP BY
        fo.product_id, dp.product_name, dp.category, dp.subcategory,
        dp.brand, dp.price, dp.margin_pct, dp.price_segment,
        dp.rating, dp.stock_status
)

SELECT
    *,
    ROUND(total_profit / NULLIF(total_revenue, 0) * 100, 1) AS realized_margin_pct,
    ROUND(total_revenue / NULLIF(units_sold, 0), 2) AS avg_selling_price,
    
    -- Ranking
    RANK() OVER (ORDER BY total_revenue DESC) AS revenue_rank,
    RANK() OVER (PARTITION BY category ORDER BY total_revenue DESC) AS category_revenue_rank,
    
    -- ABC analysis
    CASE
        WHEN SUM(total_revenue) OVER (ORDER BY total_revenue DESC 
             ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) 
             / SUM(total_revenue) OVER () <= 0.8 THEN 'A'
        WHEN SUM(total_revenue) OVER (ORDER BY total_revenue DESC 
             ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) 
             / SUM(total_revenue) OVER () <= 0.95 THEN 'B'
        ELSE 'C'
    END AS abc_class

FROM product_sales
