CREATE MATERIALIZED VIEW kpi_total_claims
COMMENT "Total claims and total claim amount"
AS
SELECT 
    SUM(total_claim_amount) AS total_claim_amount,
    COUNT(*) AS total_claims
FROM LIVE.fact_claims;