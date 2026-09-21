-- ==============================================================================
-- QUERY 02: FORENSIC NETWORK CLUSTER ANALYSIS (CTEs)
-- PROJECT ID: driiiportfolio
-- DATASET: trust_and_safety_ops
-- TARGET ROLE: Analyst, Content Safety (Google Ads)
-- PURPOSE: Isolate coordinated bad actor subnets bypassing individual filters.
-- ==============================================================================

WITH SubnetMetrics AS (
  SELECT
    ip_subnet,
    COUNT(DISTINCT account_id) AS linked_accounts_count,
    COUNT(DISTINCT ad_id) AS total_ads_launched,
    AVG(domain_age_days) AS avg_domain_age,
    SUM(daily_spend_usd) AS total_subnet_daily_spend,
    AVG(click_through_rate) AS avg_ctr,
    SUM(user_report_count) AS total_user_reports,
    SUM(CASE WHEN ai_generated_flag = 1 AND ai_label_compliant = 0 THEN 1 ELSE 0 END) AS unlabeled_ai_ads_count
  FROM
    `driiiportfolio.trust_and_safety_ops.standardized_ad_traffic`
  GROUP BY
    ip_subnet
),
RiskScoredSubnets AS (
  SELECT
    ip_subnet,
    linked_accounts_count,
    total_ads_launched,
    ROUND(avg_domain_age, 1) AS avg_domain_age_days,
    ROUND(total_subnet_daily_spend, 2) AS total_subnet_daily_spend_usd,
    ROUND(avg_ctr, 4) AS avg_ctr,
    total_user_reports,
    unlabeled_ai_ads_count,
    
    -- Abuse Penetration Ratio
    ROUND(SAFE_DIVIDE(unlabeled_ai_ads_count, total_ads_launched) * 100, 2) AS unlabeled_ai_penetration_pct,
    
    -- Statistical Velocity Flag
    CASE
      WHEN avg_domain_age <= 7 AND total_subnet_daily_spend > 50000.0 AND total_user_reports > 100 THEN 'ACTION_REQUIRED_IMMEDIATE_BAN'
      WHEN unlabeled_ai_ads_count > 50 THEN 'FLAG_FOR_ON_CALL_REVIEW'
      ELSE 'MONITOR'
    END AS enforcement_recommendation
  FROM
    SubnetMetrics
)
SELECT
  *
FROM
  RiskScoredSubnets
WHERE
  enforcement_recommendation != 'MONITOR'
ORDER BY
  total_subnet_daily_spend_usd DESC;
