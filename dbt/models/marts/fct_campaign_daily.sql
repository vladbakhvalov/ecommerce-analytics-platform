-- Fact: Daily Campaign Statistics

SELECT
    campaign_id,
    campaign_name,
    channel,
    campaign_type,
    TO_CHAR(stat_date, 'YYYYMMDD')::INTEGER AS stat_date_key,
    stat_date,
    impressions,
    clicks,
    cost,
    conversions,
    revenue,
    ctr_pct,
    cpc,
    cpa,
    roas

FROM {{ ref('int_campaign_daily') }}
