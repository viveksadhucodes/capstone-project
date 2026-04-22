CREATE OR REFRESH MATERIALIZED VIEW kpi_fraud_analysis
COMMENT "Fraud detection metrics including rates, amounts, and risk factors"
AS
SELECT 
    COUNT(*) AS total_claims,
    SUM(CASE WHEN f.fraud_flag = 'Y' THEN 1 ELSE 0 END) AS fraud_claims,
    ROUND(SUM(CASE WHEN f.fraud_flag = 'Y' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS fraud_rate_pct,
    AVG(CASE WHEN f.fraud_flag = 'Y' THEN f.total_claim_amount END) AS avg_fraud_claim_amount,
    AVG(CASE WHEN f.fraud_flag = 'N' THEN f.total_claim_amount END) AS avg_legitimate_claim_amount,
    i.incident_severity,
    i.incident_type,
    SUM(CASE WHEN f.fraud_flag = 'Y' THEN 1 ELSE 0 END) AS fraud_count_by_type
FROM fact_claims f
INNER JOIN dim_incident i ON f.incident_id = i.incident_id
GROUP BY ALL;
