-- Check that purchases <= checkouts <= add_to_carts <= product_views <= page_views
-- (at the daily level)

SELECT
    event_date
FROM {{ ref('rpt_conversion_funnel') }}
WHERE purchases > checkouts
   OR checkouts > add_to_carts
   OR add_to_carts > product_views
GROUP BY event_date
