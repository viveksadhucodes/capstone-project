CREATE OR REFRESH MATERIALIZED VIEW kpi_claims_by_state
COMMENT "Geographic distribution of claims by state with fraud rates and severity"
AS
SELECT 
    i.incident_state,
    COUNT(*) AS total_claims,
    SUM(f.total_claim_amount) AS total_amount,
    AVG(f.total_claim_amount) AS avg_claim_amount,
    SUM(CASE WHEN f.fraud_flag = 'Y' THEN 1 ELSE 0 END) AS fraud_claims,
    ROUND(SUM(CASE WHEN f.fraud_flag = 'Y' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS fraud_rate_pct,
    SUM(CASE WHEN i.incident_severity = 'Major Damage' THEN 1 ELSE 0 END) AS major_damage_count,
    SUM(CASE WHEN i.incident_severity = 'Total Loss' THEN 1 ELSE 0 END) AS total_loss_count,
    AVG(p.policy_annual_premium) AS avg_premium
FROM fact_claims f
INNER JOIN dim_incident i ON f.incident_id = i.incident_id
INNER JOIN dim_policy p ON f.policy_id = p.policy_id
GROUP BY ALL
ORDER BY total_amount DESC;
