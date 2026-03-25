-- Staging: events

WITH source AS (
    SELECT * FROM {{ source('raw', 'events') }}
)

SELECT
    event_id,
    user_id,
    event_type,
    event_timestamp,
    event_timestamp::DATE AS event_date,
    product_id,
    page_url,
    device_type,
    session_id,
    UPPER(country) AS country
FROM source