# Looker Studio Threat Dashboard Architecture

## 1. Data Source Configuration
* **Primary Connection:** Google BigQuery
* **Billing Project ID:** `driiiportfolio`
* **Dataset:** `trust_and_safety_ops`
* **Table:** `standardized_ad_traffic`

---

## 2. Executive Dashboard Layout & Scorecards
* **Scorecard 1: Total Ad Spend at Risk (USD)**
  * Metric: `SUM(daily_spend_usd)`
  * Filter: `automated_risk_tier IN ('CRITICAL_RISK', 'HIGH_RISK_NON_COMPLIANT')`
* **Scorecard 2: Unlabeled AI Creative Rate (%)**
  * Calculated Field: `SUM(CASE WHEN ai_generated_flag = 1 AND ai_label_compliant = 0 THEN 1 ELSE 0 END) / COUNT(ad_id)`
  * Format: Percentage (2 decimal places)
* **Scorecard 3: Active Scam Subnets Isolated**
  * Metric: `COUNT_DISTINCT(ip_subnet)`
  * Filter: `automated_risk_tier = 'CRITICAL_RISK'`

---

## 3. Core Visualizations
1. **Subnet Abuse Heatmap (Geo/Network Density):**
   * Dimensions: `ip_subnet`, `destination_tld`
   * Metric: `total_subnet_daily_spend_usd`, `total_user_reports`
2. **Spend Velocity vs. Domain Age Anomaly Scatter:**
   * X-Axis: `domain_age_days`
   * Y-Axis: `daily_spend_usd`
   * Color Dimension: `automated_risk_tier`
3. **Policy Violation Breakdown (Donut Chart):**
   * Dimension: `policy_violation_category`
   * Metric: `COUNT(ad_id)`
