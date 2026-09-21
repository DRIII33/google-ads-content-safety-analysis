-- ==============================================================================
-- VIEW 03: LOOKER STUDIO EXECUTIVE SUMMARY KPI FEED
-- PROJECT ID: driiiportfolio
-- DATASET: trust_and_safety_ops
-- PURPOSE: Pre-calculates macro KPIs for low-latency Looker Studio rendering.
-- ==============================================================================

CREATE OR REPLACE VIEW `driiiportfolio.trust_and_safety_ops.vw_looker_executive_summary_metrics` AS
SELECT
  traffic_date,
  COUNT(ad_id) AS total_ads_monitored,
  
  -- Policy Violation Metrics
  SUM(CASE WHEN policy_violation_category != 'None' THEN 1 ELSE 0 END) AS total_flagged_violations,
  ROUND(
    SAFE_DIVIDE(SUM(CASE WHEN policy_violation_category != 'None' THEN 1 ELSE 0 END), COUNT(ad_id)) * 100,
    2
  ) AS abuse_rate_pct,
  
  -- AI Transparency Metrics
  SUM(is_unlabeled_ai) AS total_unlabeled_ai_creatives,
  ROUND(
    SAFE_DIVIDE(SUM(is_unlabeled_ai), SUM(ai_generated_flag)) * 100,
    2
  ) AS ai_non_compliance_rate_pct,
  
  -- Financial At-Risk Exposure
  SUM(CASE WHEN automated_risk_tier = 'CRITICAL_RISK' THEN daily_spend_usd ELSE 0 END) AS at_risk_daily_spend_usd,
  
  -- User Escalation Metrics
  SUM(user_report_count) AS total_user_reports
FROM
  `driiiportfolio.trust_and_safety_ops.vw_standardized_ad_traffic`
GROUP BY
  traffic_date;
