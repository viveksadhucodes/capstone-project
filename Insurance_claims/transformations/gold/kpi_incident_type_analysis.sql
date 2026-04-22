CREATE OR REFRESH MATERIALIZED VIEW kpi_incident_type_analysis
COMMENT "Incident type analysis with collision patterns and police involvement"
AS
SELECT 
    i.incident_type,
    i.collision_type,
    COUNT(*) AS total_claims,
    SUM(f.total_claim_amount) AS total_amount,
    AVG(f.total_claim_amount) AS avg_claim_amount,
    SUM(f.injury_claim) AS total_injury_amount,
    SUM(f.property_claim) AS total_property_amount,
    SUM(f.vehicle_claim) AS total_vehicle_amount,
    AVG(i.bodily_injuries) AS avg_bodily_injuries,
    AVG(i.witnesses) AS avg_witnesses,
    SUM(CASE WHEN i.police_report_available = 'YES' THEN 1 ELSE 0 END) AS police_reports_filed,
    ROUND(SUM(CASE WHEN i.police_report_available = 'YES' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS police_report_rate_pct,
    ROUND(SUM(CASE WHEN f.fraud_flag = 'Y' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS fraud_rate_pct
FROM fact_claims f
INNER JOIN dim_incident i ON f.incident_id = i.incident_id
GROUP BY ALL
ORDER BY total_amount DESC;
