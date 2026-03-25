-- Staging: campaigns
-- Source: raw.campaigns

WITH source AS (
    SELECT * FROM {{ source('raw', 'campaigns') }}
)

SELECT
    campaign_id,
    name AS campaign_name,
    channel,
    campaign_type,
    start_date,
    end_date,
    daily_budget,
    is_active
FROM source