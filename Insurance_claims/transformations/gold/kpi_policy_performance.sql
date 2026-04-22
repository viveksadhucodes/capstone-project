CREATE OR REFRESH MATERIALIZED VIEW kpi_policy_performance
COMMENT "Policy performance metrics including claim ratios and profitability indicators"
AS
SELECT 
    p.policy_state,
    p.policy_csl,
    CASE 
        WHEN p.policy_deductable < 500 THEN 'Low (<500)'
        WHEN p.policy_deductable BETWEEN 500 AND 1000 THEN 'Medium (500-1000)'
        ELSE 'High (>1000)'
    END AS deductible_category,
    COUNT(DISTINCT f.policy_id) AS total_policies,
    COUNT(*) AS total_claims,
    SUM(f.total_claim_amount) AS total_claims_paid,
    SUM(p.policy_annual_premium) AS total_premiums,
    ROUND(SUM(f.total_claim_amount) / NULLIF(SUM(p.policy_annual_premium), 0), 2) AS loss_ratio,
    AVG(f.total_claim_amount) AS avg_claim_amount,
    AVG(p.policy_annual_premium) AS avg_premium,
    AVG(p.umbrella_limit) AS avg_umbrella_limit,
    AVG(p.months_as_customer) AS avg_customer_tenure_months,
    ROUND(SUM(CASE WHEN f.fraud_flag = 'Y' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS fraud_rate_pct
FROM fact_claims f
INNER JOIN dim_policy p ON f.policy_id = p.policy_id
GROUP BY ALL
ORDER BY loss_ratio DESC;
