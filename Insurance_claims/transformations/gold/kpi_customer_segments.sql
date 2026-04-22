CREATE OR REFRESH MATERIALIZED VIEW kpi_customer_segments
COMMENT "Customer risk segmentation by age, education, occupation with claim patterns"
AS
SELECT 
    CASE 
        WHEN c.age < 25 THEN 'Under 25'
        WHEN c.age BETWEEN 25 AND 34 THEN '25-34'
        WHEN c.age BETWEEN 35 AND 44 THEN '35-44'
        WHEN c.age BETWEEN 45 AND 54 THEN '45-54'
        WHEN c.age >= 55 THEN '55+'
    END AS age_group,
    c.insured_education_level,
    c.insured_occupation,
    c.insured_sex,
    COUNT(*) AS total_claims,
    SUM(f.total_claim_amount) AS total_amount,
    AVG(f.total_claim_amount) AS avg_claim_amount,
    ROUND(SUM(CASE WHEN f.fraud_flag = 'Y' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS fraud_rate_pct,
    AVG(c.capital_gains) AS avg_capital_gains,
    AVG(c.capital_loss) AS avg_capital_loss
FROM fact_claims f
INNER JOIN dim_customer c ON f.customer_id = c.customer_id
GROUP BY ALL
ORDER BY total_amount DESC;
