-- Report: Marketing ROI by Campaigns
-- Aggregation for the entire period + by channels

WITH campaign_totals AS (
    SELECT
        campaign_id,
        campaign_name,
        channel,
        campaign_type,
        
        SUM(impressions) AS total_impressions,
        SUM(clicks) AS total_clicks,
        SUM(cost) AS total_cost,
        SUM(conversions) AS total_conversions,
        SUM(revenue) AS total_revenue,
        
        COUNT(DISTINCT stat_date) AS active_days
        
    FROM {{ ref('fct_campaign_daily') }}
    GROUP BY campaign_id, campaign_name, channel, campaign_type
)

SELECT
    campaign_id,
    campaign_name,
    channel,
    campaign_type,
    total_impressions,
    total_clicks,
    total_cost,
    total_conversions,
    total_revenue,
    active_days,
    
    -- Calculated metrics
    ROUND(total_clicks::NUMERIC / NULLIF(total_impressions, 0) * 100, 2) AS ctr_pct,
    ROUND(total_cost / NULLIF(total_clicks, 0), 2) AS avg_cpc,
    ROUND(total_cost / NULLIF(total_conversions, 0), 2) AS avg_cpa,
    ROUND(total_revenue / NULLIF(total_cost, 0), 2) AS roas,
    total_revenue - total_cost AS net_profit,
    ROUND((total_revenue - total_cost) / NULLIF(total_cost, 0) * 100, 1) AS roi_pct,
    
    -- Performance categorization
    CASE
        WHEN total_revenue / NULLIF(total_cost, 0) >= 5 THEN 'excellent'
        WHEN total_revenue / NULLIF(total_cost, 0) >= 3 THEN 'good'
        WHEN total_revenue / NULLIF(total_cost, 0) >= 1 THEN 'break_even'
        ELSE 'unprofitable'
    END AS performance_category

FROM campaign_totals
ORDER BY total_revenue DESC
