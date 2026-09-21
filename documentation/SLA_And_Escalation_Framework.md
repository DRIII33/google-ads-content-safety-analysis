# On-Call SLA & Escalation Triaging Framework

## Incident Priority Matrix & Service Level Agreements (SLAs)

| Severity Tier | Threat Description | Target Response Time | Target Resolution Time | Action Protocol |
| --- | --- | --- | --- | --- |
| **P0 - Critical** | Severe Brand Safety, Violent Extremism, Active Financial Cyber Attack, Political Interference | **< 15 Minutes** | **< 1 Hour** | Immediate auto-suspension of associated subnets; emergency page to T&S Lead, Eng, and Legal. |
| **P1 - High** | Unlabeled AI Financial Scams, Ephemeral Domain Ring, Imposter Tech Support | **< 1 Hour** | **< 4 Hours** | Automated spend throttle; queue priority routing to on-call Content Safety Analyst. |
| **P2 - Medium** | Low-spend Misrepresentation, Single User Report Spikes, Minor Policy Ambiguities | **< 24 Hours** | **< 48 Hours** | Standard review queue placement; batch processing via composite risk score. |

---

## Escalation Workflow
1. **Trigger:** Anomaly detection script or user report spike breaches $P_{\text{composite}} \ge 97.5$th percentile.
2. **Ingress:** Incident auto-populates in On-Call Incident Queue with pre-computed subnet, spend velocity, and domain age metadata.
3. **Triaging:** On-call Content Safety Analyst performs forensic account linkage using Query 02.
4. **Resolution:** If verified, analyst applies network-level suspension and updates detection rule parameters.
