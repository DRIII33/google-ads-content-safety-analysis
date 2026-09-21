-- ==============================================================================
-- VIEW 02: FORENSIC NETWORK CLUSTER ANALYSIS
-- PROJECT ID: driiiportfolio
-- DATASET: trust_and_safety_ops
-- PURPOSE: Aggregates network traffic by IP subnet to expose bad actor rings.
-- ==============================================================================

CREATE OR REPLACE VIEW `driiiportfolio.trust_and_safety_ops.vw_forensic_subnet_clusters` AS
WITH SubnetAggregations AS (
  SELECT
    ip_subnet,
    COUNT(DISTINCT account_id) AS linked_accounts_count,
    COUNT(DISTINCT ad_id) AS total_ads_launched,
    AVG(domain_age_days) AS avg_domain_age_days,
    SUM(daily_spend_usd) AS total_subnet_daily_spend_usd,
    AVG(click_through_rate) AS avg_click_through_rate,
    SUM(user_report_count) AS total_user_reports,
    SUM(is_unlabeled_ai) AS total_unlabeled_ai_ads
  FROM
    `driiiportfolio.trust_and_safety_ops.vw_standardized_ad_traffic`
  GROUP BY
    ip_subnet
)
SELECT
  ip_subnet,
  linked_accounts_count,
  total_ads_launched,
  ROUND(avg_domain_age_days, 1) AS avg_domain_age_days,
  ROUND(total_subnet_daily_spend_usd, 2) AS total_subnet_daily_spend_usd,
  ROUND(avg_click_through_rate, 4) AS avg_click_through_rate,
  total_user_reports,
  total_unlabeled_ai_ads,
  
  -- Calculated Field: Abuse Penetration Percentage
  ROUND(SAFE_DIVIDE(total_unlabeled_ai_ads, total_ads_launched) * 100, 2) AS unlabeled_ai_penetration_pct,
  
  -- Calculated Field: Recommended Enforcement Action
  CASE 
    WHEN avg_domain_age_days <= 7 
         AND total_subnet_daily_spend_usd > 50000.0 
         AND total_user_reports > 100 THEN 'ACTION_REQUIRED_IMMEDIATE_BAN'
    WHEN total_unlabeled_ai_ads > 50 THEN 'FLAG_FOR_ON_CALL_REVIEW'
    ELSE 'MONITOR'
  END AS enforcement_recommendation
FROM
  SubnetAggregations;
