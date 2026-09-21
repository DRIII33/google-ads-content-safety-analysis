CREATE OR REPLACE VIEW `driiiportfolio.trust_and_safety_ops.vw_anomalous_ad_traffic` AS
SELECT
  *
FROM
  `driiiportfolio.trust_and_safety_ops.vw_standardized_ad_traffic`
WHERE
  automated_risk_tier != 'LOW_RISK';
