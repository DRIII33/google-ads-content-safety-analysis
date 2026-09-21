# ==============================================================================
# SCRIPT 01: SYNTHETIC DATA GENERATION (GOOGLE COLAB / PYTHON 3.10+)
# PURPOSE: Generate 100,000 ad records modeling benign traffic + AI fraud ring
# ==============================================================================

import pandas as pd
import numpy as np
from datetime import datetime, timedelta
import random

# Set seed for reproducibility
np.random.seed(2026)
random.seed(2026)

NUM_RECORDS = 100000
FRAUD_RATIO = 0.025  # 2.5% malicious traffic
NUM_FRAUD = int(NUM_RECORDS * FRAUD_RATIO)
NUM_BENIGN = NUM_RECORDS - NUM_FRAUD

print(f"Generating {NUM_BENIGN} benign and {NUM_FRAUD} fraudulent ad traffic records...")

# Generate Benign Data
start_date = datetime(2026, 7, 1)
timestamps = [start_date + timedelta(minutes=random.randint(0, 100000)) for _ in range(NUM_BENIGN)]

benign_df = pd.DataFrame({
    'ad_id': [f"AD-BENIGN-{i:07d}" for i in range(NUM_BENIGN)],
    'account_id': [f"ACC-{random.randint(100000, 999999)}" for _ in range(NUM_BENIGN)],
    'timestamp': timestamps,
    'vertical': np.random.choice(['E-Commerce', 'SaaS', 'Travel', 'Local Services', 'Education'], size=NUM_BENIGN),
    'domain_age_days': np.random.exponential(scale=365, size=NUM_BENIGN).astype(int) + 14,
    'daily_spend_usd': np.round(np.random.lognormal(mean=3.5, sigma=1.0, size=NUM_BENIGN), 2),
    'click_through_rate': np.round(np.random.beta(a=2, b=40, size=NUM_BENIGN), 4),
    'user_report_count': np.random.poisson(lam=0.05, size=NUM_BENIGN),
    'ai_generated_flag': np.random.choice([0, 1], size=NUM_BENIGN, p=[0.7, 0.3]),
    'ai_label_compliant': np.random.choice([1, 0], size=NUM_BENIGN, p=[0.95, 0.05]),
    'ip_subnet': [f"192.168.{random.randint(1, 254)}" for _ in range(NUM_BENIGN)],
    'destination_tld': np.random.choice(['.com', '.org', '.net', '.co', '.io'], size=NUM_BENIGN),
    'policy_violation_category': 'None'
})

# Generate Fraudulent Data (Operation GhostForge Cluster)
fraud_timestamps = [start_date + timedelta(minutes=random.randint(40000, 100000)) for _ in range(NUM_FRAUD)]
ghostforge_subnets = ['10.104.12', '10.104.13', '10.104.14']

fraud_df = pd.DataFrame({
    'ad_id': [f"AD-FRAUD-{i:07d}" for i in range(NUM_FRAUD)],
    'account_id': [f"ACC-GHOST-{random.randint(100, 999)}" for _ in range(NUM_FRAUD)],
    'timestamp': fraud_timestamps,
    'vertical': 'Financial Services',
    'domain_age_days': np.random.randint(1, 6, size=NUM_FRAUD),
    'daily_spend_usd': np.round(np.random.uniform(low=800.0, high=4500.0, size=NUM_FRAUD), 2),
    'click_through_rate': np.round(np.random.uniform(low=0.12, high=0.35, size=NUM_FRAUD), 4),
    'user_report_count': np.random.poisson(lam=4.2, size=NUM_FRAUD),
    'ai_generated_flag': 1,
    'ai_label_compliant': 0,
    'ip_subnet': np.random.choice(ghostforge_subnets, size=NUM_FRAUD),
    'destination_tld': np.random.choice(['.xyz', '.top', '.click', '.site', '.live'], size=NUM_FRAUD),
    'policy_violation_category': np.random.choice(
        ['Misrepresentation: Financial Scam', 'Unlabeled AI Creative', 'Malicious Software Destination'],
        size=NUM_FRAUD, p=[0.60, 0.25, 0.15]
    )
})

# Concatenate and Shuffle
full_df = pd.concat([benign_df, fraud_df], ignore_index=True).sample(frac=1, random_state=2026).reset_index(drop=True)

# Export to CSV
full_df.to_csv('google_ads_q3_traffic.csv', index=False)
print("Dataset generated successfully: 'google_ads_q3_traffic.csv' (100,000 rows)")
