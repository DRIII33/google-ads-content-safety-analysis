# ==============================================================================
# SCRIPT 02: STATISTICAL ANOMALY DETECTION & RISK SCORING (GOOGLE COLAB)
# PURPOSE: Z-Score modeling on spend velocity and complaint rates
# ==============================================================================

import pandas as pd
import numpy as np
from scipy import stats
import matplotlib.pyplot as plt
import seaborn as sns

# Load dataset
df = pd.read_csv('google_ads_q3_traffic.csv')

# Ensure numeric types
df['daily_spend_usd'] = pd.to_numeric(df['daily_spend_usd'], errors='coerce')
df['user_report_count'] = pd.to_numeric(df['user_report_count'], errors='coerce')

# 1. Calculate Z-Scores
df['spend_zscore'] = stats.zscore(df['daily_spend_usd'].dropna())
df['reports_zscore'] = stats.zscore(df['user_report_count'].dropna())

# 2. Calculate Composite Risk Score
domain_penalty = np.where(df['domain_age_days'] <= 7, 2.0, 0.0)
non_compliant_ai_penalty = np.where((df['ai_generated_flag'] == 1) & (df['ai_label_compliant'] == 0), 2.5, 0.0)

df['composite_risk_score'] = (
    (df['spend_zscore'] * 0.45) +
    (df['reports_zscore'] * 0.35) +
    non_compliant_ai_penalty +
    domain_penalty
)

# 3. Define Anomaly Threshold (97.5th Percentile)
threshold = np.percentile(df['composite_risk_score'], 97.5)
df['statistical_anomaly_flag'] = np.where(df['composite_risk_score'] >= threshold, 1, 0)

print(f"Statistical Threshold (97.5th Percentile): {threshold:.4f}")
print(f"Total Anomalies Flagged: {df['statistical_anomaly_flag'].sum()} out of {len(df)} records")

# 4. Generate Visualization
plt.figure(figsize=(10, 6))
sns.scatterplot(
    data=df,
    x='domain_age_days',
    y='daily_spend_usd',
    hue='statistical_anomaly_flag',
    palette={0: '#2b5c8f', 1: '#d93025'},
    alpha=0.6
)
plt.axvline(x=7, color='black', linestyle='--', label='Domain Age Threshold (7 Days)')
plt.title('Google Ads Content Safety: Spend Velocity vs Domain Age Anomaly Detection', fontsize=12)
plt.xlabel('Domain Age (Days)')
plt.ylabel('Daily Spend (USD)')
plt.legend(title='Statistical Risk Flag', labels=['Normal Traffic', 'High Risk Anomaly'])
plt.grid(True, linestyle=':', alpha=0.6)
plt.tight_layout()
plt.savefig('anomaly_scatter_plot.png', dpi=300)
plt.show()
