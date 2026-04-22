CREATE OR REFRESH MATERIALIZED VIEW kpi_temporal_patterns
COMMENT "Temporal claim patterns by hour, day, month with seasonality analysis"
AS
SELECT 
    YEAR(i.incident_date) AS incident_year,
    MONTH(i.incident_date) AS incident_month,
    DAYOFWEEK(i.incident_date) AS day_of_week,
    CASE 
        WHEN i.incident_hour_of_the_day BETWEEN 6 AND 11 THEN 'Morning (6-11)'
        WHEN i.incident_hour_of_the_day BETWEEN 12 AND 17 THEN 'Afternoon (12-17)'
        WHEN i.incident_hour_of_the_day BETWEEN 18 AND 23 THEN 'Evening (18-23)'
        ELSE 'Night (0-5)'
    END AS time_of_day,
    i.incident_hour_of_the_day,
    COUNT(*) AS total_claims,
    SUM(f.total_claim_amount) AS total_amount,
    AVG(f.total_claim_amount) AS avg_claim_amount,
    SUM(f.injury_claim) AS total_injury_claims,
    AVG(i.bodily_injuries) AS avg_bodily_injuries,
    ROUND(SUM(CASE WHEN f.fraud_flag = 'Y' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS fraud_rate_pct
FROM fact_claims f
INNER JOIN dim_incident i ON f.incident_id = i.incident_id
GROUP BY ALL
ORDER BY incident_year, incident_month, incident_hour_of_the_day;
