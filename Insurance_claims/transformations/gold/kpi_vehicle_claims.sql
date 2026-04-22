CREATE OR REFRESH MATERIALIZED VIEW kpi_vehicle_claims
COMMENT "Vehicle-based claims analysis by make, model, year with risk assessment"
AS
SELECT 
    v.auto_make,
    v.auto_model,
    v.auto_year,
    CASE 
        WHEN v.auto_year >= 2020 THEN 'New (2020+)'
        WHEN v.auto_year BETWEEN 2015 AND 2019 THEN 'Recent (2015-2019)'
        WHEN v.auto_year BETWEEN 2010 AND 2014 THEN 'Mid-Age (2010-2014)'
        ELSE 'Older (Pre-2010)'
    END AS vehicle_age_category,
    COUNT(*) AS total_claims,
    SUM(f.total_claim_amount) AS total_amount,
    AVG(f.total_claim_amount) AS avg_claim_amount,
    SUM(f.vehicle_claim) AS total_vehicle_damage,
    ROUND(SUM(CASE WHEN f.fraud_flag = 'Y' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS fraud_rate_pct,
    AVG(i.number_of_vehicles_involved) AS avg_vehicles_in_incident
FROM fact_claims f
INNER JOIN dim_vehicle v ON f.vehicle_id = v.vehicle_id
INNER JOIN dim_incident i ON f.incident_id = i.incident_id
GROUP BY ALL
ORDER BY total_amount DESC;
