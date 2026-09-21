-- ==============================================================================
-- QUERY 01: DDL TABLE OPTIMIZATION & CLEANING
-- PROJECT ID: driiiportfolio
-- DATASET: trust_and_safety_ops
-- TARGET ROLE: Analyst, Content Safety (Google Ads)
-- PURPOSE: Create a production-ready, partitioned, and clustered table with
--          automated policy risk tiering.
-- ==============================================================================

CREATE OR REPLACE TABLE `driiiportfolio.trust_and_safety_ops.standardized_ad_traffic`
PARTITION BY DATE(timestamp)
CLUSTER BY policy_violation_category, ip_subnet AS
SELECT
  UPPER(TRIM(ad_id)) AS ad_id,
  UPPER(TRIM(account_id)) AS account_id,
  TIMESTAMP(timestamp) AS timestamp,
  LOWER(TRIM(vertical)) AS vertical,
  CAST(domain_age_days AS INT64) AS domain_age_days,
  CAST(daily_spend_usd AS NUMERIC) AS daily_spend_usd,
  CAST(click_through_rate AS FLOAT64) AS click_through_rate,
  CAST(user_report_count AS INT64) AS user_report_count,
  CAST(ai_generated_flag AS INT64) AS ai_generated_flag,
  CAST(ai_label_compliant AS INT64) AS ai_label_compliant,
  TRIM(ip_subnet) AS ip_subnet,
  LOWER(TRIM(destination_tld)) AS destination_tld,
  TRIM(policy_violation_category) AS policy_violation_category,
  
  -- Feature Engineering: Policy Risk Tiering
  CASE
    WHEN domain_age_days <= 7 AND daily_spend_usd > 500.0 AND ai_label_compliant = 0 THEN 'CRITICAL_RISK'
    WHEN ai_generated_flag = 1 AND ai_label_compliant = 0 THEN 'HIGH_RISK_NON_COMPLIANT'
    WHEN user_report_count >= 3 THEN 'ELEVATED_REPORT_RISK'
    ELSE 'LOW_RISK'
  END AS automated_risk_tier
FROM
  `driiiportfolio.trust_and_safety_ops.raw_ad_traffic`;
