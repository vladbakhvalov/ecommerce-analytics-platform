-- Fact: Events

WITH events AS (
    SELECT * FROM {{ ref('stg_events') }}
)

SELECT
    event_id,
    user_id,
    product_id,
    event_type,
    event_timestamp,
    TO_CHAR(event_date, 'YYYYMMDD')::INTEGER AS event_date_key,
    event_date,
    device_type,
    session_id,
    country,
    page_url,
    
    -- Funnel step number (for conversion funnel)
    CASE event_type
        WHEN 'page_view' THEN 1
        WHEN 'product_view' THEN 2
        WHEN 'add_to_cart' THEN 3
        WHEN 'begin_checkout' THEN 4
        WHEN 'purchase' THEN 5
        ELSE 0
    END AS funnel_step

FROM events
