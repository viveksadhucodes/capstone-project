CREATE OR REFRESH MATERIALIZED VIEW kpi_collision_analysis
COMMENT "Collision type impact analysis with severity distribution and injury patterns"
AS
SELECT 
    i.collision_type,
    i.incident_severity,
    COUNT(*) AS total_claims,
    SUM(f.total_claim_amount) AS total_amount,
    AVG(f.total_claim_amount) AS avg_claim_amount,
    SUM(f.injury_claim) AS total_injury_claims,
    SUM(f.property_claim) AS total_property_claims,
    SUM(f.vehicle_claim) AS total_vehicle_claims,
    AVG(i.bodily_injuries) AS avg_bodily_injuries,
    AVG(i.number_of_vehicles_involved) AS avg_vehicles_involved,
    AVG(i.witnesses) AS avg_witnesses,
    SUM(CASE WHEN i.police_report_available = 'YES' THEN 1 ELSE 0 END) AS police_reports,
    ROUND(SUM(CASE WHEN i.police_report_available = 'YES' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS police_report_rate_pct,
    ROUND(SUM(CASE WHEN f.fraud_flag = 'Y' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS fraud_rate_pct,
    ROUND(SUM(CASE WHEN i.bodily_injuries > 0 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS injury_rate_pct
FROM fact_claims f
INNER JOIN dim_incident i ON f.incident_id = i.incident_id
GROUP BY ALL
ORDER BY total_amount DESC;
