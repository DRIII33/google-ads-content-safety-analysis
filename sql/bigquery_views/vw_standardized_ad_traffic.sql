-- ==============================================================================
-- VIEW 01: STANDARDIZED AD TRAFFIC & AUTOMATED RISK TIERING
-- PROJECT ID: driiiportfolio
-- DATASET: trust_and_safety_ops
-- PURPOSE: Normalizes raw ad traffic and dynamically attaches risk categories.
-- ==============================================================================

CREATE OR REPLACE VIEW `driiiportfolio.trust_and_safety_ops.vw_standardized_ad_traffic` AS
SELECT
  UPPER(TRIM(ad_id)) AS ad_id,
  UPPER(TRIM(account_id)) AS account_id,
  TIMESTAMP(timestamp) AS timestamp,
  DATE(timestamp) AS traffic_date,
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
  
  -- Calculated Field: AI Non-Compliance Indicator
  CASE 
    WHEN CAST(ai_generated_flag AS INT64) = 1 AND CAST(ai_label_compliant AS INT64) = 0 THEN 1 
    ELSE 0 
  END AS is_unlabeled_ai,

  -- Calculated Field: Automated Risk Tier Logic
  CASE 
    WHEN CAST(domain_age_days AS INT64) <= 7 
         AND CAST(daily_spend_usd AS NUMERIC) > 500.0 
         AND CAST(ai_label_compliant AS INT64) = 0 THEN 'CRITICAL_RISK'
    WHEN CAST(ai_generated_flag AS INT64) = 1 
         AND CAST(ai_label_compliant AS INT64) = 0 THEN 'HIGH_RISK_NON_COMPLIANT'
    WHEN CAST(user_report_count AS INT64) >= 3 THEN 'ELEVATED_REPORT_RISK'
    ELSE 'LOW_RISK'
  END AS automated_risk_tier
FROM
  `driiiportfolio.trust_and_safety_ops.raw_ad_traffic`;
