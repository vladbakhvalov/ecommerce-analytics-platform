-- Dimension: Advertising Campaigns

SELECT
    campaign_id,
    campaign_name,
    channel,
    campaign_type,
    start_date,
    end_date,
    daily_budget,
    is_active,
    COALESCE(end_date, CURRENT_DATE) - start_date AS campaign_duration_days

FROM {{ ref('stg_campaigns') }}
