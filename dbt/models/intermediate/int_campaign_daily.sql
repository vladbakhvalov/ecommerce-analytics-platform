-- Intermediate: daily campaign statistics with calculated metrics

WITH stats AS (
    SELECT * FROM {{ source('raw', 'campaign_daily_stats') }}
),

campaigns AS (
    SELECT * FROM {{ ref('stg_campaigns') }}
)

SELECT
    s.campaign_id,
    c.campaign_name,
    c.channel,
    c.campaign_type,
    s.stat_date,
    s.impressions,
    s.clicks,
    s.cost,
    s.conversions,
    s.revenue,
    
    -- Calculated metrics
    ROUND(s.clicks::NUMERIC / NULLIF(s.impressions, 0) * 100, 2) AS ctr_pct,
    ROUND(s.cost / NULLIF(s.clicks, 0), 2) AS cpc,
    ROUND(s.cost / NULLIF(s.conversions, 0), 2) AS cpa,
    ROUND(s.revenue / NULLIF(s.cost, 0), 2) AS roas
    
FROM stats s
JOIN campaigns c ON s.campaign_id = c.campaign_id
