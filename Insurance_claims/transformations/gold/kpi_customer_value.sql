CREATE OR REFRESH MATERIALIZED VIEW kpi_customer_value
COMMENT "Customer lifetime value analysis with profitability and retention metrics"
AS
SELECT 
    CASE 
        WHEN p.months_as_customer < 12 THEN 'New (0-11 months)'
        WHEN p.months_as_customer BETWEEN 12 AND 35 THEN 'Established (1-3 years)'
        WHEN p.months_as_customer BETWEEN 36 AND 59 THEN 'Loyal (3-5 years)'
        ELSE 'Long-term (5+ years)'
    END AS customer_tenure_category,
    c.insured_education_level,
    c.insured_occupation,
    COUNT(DISTINCT f.customer_id) AS total_customers,
    COUNT(*) AS total_claims,
    ROUND(COUNT(*) * 1.0 / COUNT(DISTINCT f.customer_id), 2) AS avg_claims_per_customer,
    SUM(f.total_claim_amount) AS total_claims_paid,
    AVG(f.total_claim_amount) AS avg_claim_amount,
    SUM(p.policy_annual_premium * p.months_as_customer / 12.0) AS estimated_total_premiums,
    ROUND(SUM(f.total_claim_amount) / NULLIF(SUM(p.policy_annual_premium * p.months_as_customer / 12.0), 0), 2) AS lifetime_loss_ratio,
    AVG(p.months_as_customer) AS avg_tenure_months,
    AVG(c.capital_gains - c.capital_loss) AS avg_net_capital,
    ROUND(SUM(CASE WHEN f.fraud_flag = 'Y' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS fraud_rate_pct
FROM fact_claims f
INNER JOIN dim_customer c ON f.customer_id = c.customer_id
INNER JOIN dim_policy p ON f.policy_id = p.policy_id
GROUP BY ALL
ORDER BY lifetime_loss_ratio DESC;
