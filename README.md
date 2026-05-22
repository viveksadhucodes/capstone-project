# Insurance Claims Analytics Lakehouse

> A corporate-grade insurance claims data platform built to transform raw policy and incident data into decision-ready intelligence.

![Architecture](https://img.shields.io/badge/Architecture-Bronze%20%7C%20Silver%20%7C%20Gold-0B3D91)
![Model](https://img.shields.io/badge/Model-Star%20Schema-1F6FEB)
![Serving](https://img.shields.io/badge/Serving-KPI%20Views-0F766E)

An end-to-end insurance claims analytics pipeline built on a bronze-silver-gold architecture. The project ingests raw claims data, standardizes it into a reusable star schema, and publishes business-ready KPI views for underwriting, fraud oversight, customer analysis, and operational reporting.

## Project Snapshot

| Dimension | Details |
| --- | --- |
| Domain | Insurance claims analytics |
| Architecture | Bronze - Silver - Gold |
| Core Modeling Pattern | Star schema |
| Serving Layer | KPI materialized views |
| Primary Outcomes | Fraud visibility, loss analysis, customer profiling, policy performance |

## Table of Contents

- [Executive Summary](#executive-summary)
- [Why This Matters](#why-this-matters)
- [Architecture Overview](#architecture-overview)
- [ER Diagram](#er-diagram)
- [Data Pipeline](#data-pipeline)
- [KPI Portfolio](#kpi-portfolio)
- [Executive Outcomes](#executive-outcomes)
- [Repository Structure](#repository-structure)
- [Implementation Notes](#implementation-notes)
- [What Makes It Strong](#what-makes-it-strong)
- [Business Value](#business-value)

## Executive Summary

This solution turns a single insurance claims dataset into an analytics-ready model with three clear layers:

- Bronze captures the raw source with lightweight normalization and ingestion metadata.
- Silver reshapes the data into a dimensional model with customer, vehicle, incident, policy, and fact tables.
- Gold publishes focused KPI materialized views that answer the most important business questions immediately.

The result is a structured foundation for executive dashboards, risk monitoring, and claims intelligence.

## Why This Matters

This project is designed to support the questions leadership actually asks:

- Where are losses concentrated?
- Which customer, policy, vehicle, and incident segments are the most risky?
- How often does fraud appear, and what patterns precede it?
- Which business segments create the highest claims pressure relative to premium intake?

By separating ingestion, conformance, and reporting, the pipeline makes the answers traceable, reusable, and easy to scale.

## Architecture Overview

```mermaid
flowchart LR
    A[Source CSV\ninsurance_claims.csv] --> B[Bronze Layer\nclaim_raw]
    B --> C[Silver Layer\nbase_claims]
    C --> D1[dim_customer]
    C --> D2[dim_vehicle]
    C --> D3[dim_incident]
    C --> D4[dim_policy]
    C --> F[fact_claims]

    D1 --> G1[kpi_customer_segments]
    D1 --> G2[kpi_customer_value]
    D2 --> G3[kpi_vehicle_claims]
    D3 --> G4[kpi_claims_by_state]
    D3 --> G5[kpi_claims_by_severity]
    D3 --> G6[kpi_temporal_patterns]
    D3 --> G7[kpi_incident_type_analysis]
    D3 --> G8[kpi_collision_analysis]
    D4 --> G9[kpi_policy_performance]
    F --> G10[kpi_total_claims]
    F --> G11[kpi_fraud_analysis]
    F --> G1
    F --> G2
    F --> G3
    F --> G4
    F --> G5
    F --> G6
    F --> G7
    F --> G8
    F --> G9
```

## ER Diagram

```mermaid
erDiagram
    claim_raw {
        string source_file
        timestamp processing_time
    }

    base_claims {
        string policy_id
        string policy_state
        string insured_sex
        string auto_make
        string incident_type
        string incident_state
        string fraud_reported
        number total_claim_amount
    }

    dim_customer {
        number customer_id
        string policy_id
        number age
        string insured_sex
        string insured_education_level
        string insured_occupation
        string insured_relationship
        number capital_gains
        number capital_loss
    }

    dim_vehicle {
        number vehicle_id
        string policy_id
        string auto_make
        string auto_model
        number auto_year
    }

    dim_incident {
        number incident_id
        string policy_id
        date incident_date
        string incident_type
        string collision_type
        string incident_severity
        string incident_state
        string incident_city
        number incident_hour_of_the_day
        number number_of_vehicles_involved
        number bodily_injuries
        number witnesses
        string police_report_available
    }

    dim_policy {
        string policy_id
        string policy_state
        string policy_csl
        number policy_deductable
        number policy_annual_premium
        number umbrella_limit
        number months_as_customer
    }

    fact_claims {
        number claim_id
        string policy_id
        number customer_id
        number vehicle_id
        number incident_id
        number total_claim_amount
        number injury_claim
        number property_claim
        number vehicle_claim
        string fraud_flag
    }

    claim_raw ||--|| base_claims : cleans into
    base_claims ||--o{ dim_customer : derives
    base_claims ||--o{ dim_vehicle : derives
    base_claims ||--o{ dim_incident : derives
    base_claims ||--|| dim_policy : derives
    base_claims ||--o{ fact_claims : enriches
    dim_customer ||--o{ fact_claims : customer_id
    dim_vehicle ||--o{ fact_claims : vehicle_id
    dim_incident ||--o{ fact_claims : incident_id
    dim_policy ||--o{ fact_claims : policy_id
```

## Data Pipeline

### Bronze

The bronze layer ingests the raw CSV from `/Volumes/workspace/default/project/insurance_claims.csv`, standardizes column names, and adds operational metadata:

- `processing_time` records when the pipeline processed the row.
- `source_file` preserves data provenance.
- Column names are normalized by trimming spaces and replacing spaces or hyphens with underscores.

### Bronze Output

The bronze table provides a governed landing zone for the source data and is the first checkpoint in the pipeline before any dimensional modeling begins.

### Silver

The silver layer creates the reusable analytical model:

- `base_claims` acts as the source-of-truth cleaned table.
- `dim_customer` captures insured demographic and financial attributes.
- `dim_vehicle` captures vehicle make, model, and year.
- `dim_incident` captures incident timing, type, severity, location, and police-report context.
- `dim_policy` captures coverage, deductibles, premium, and tenure.
- `fact_claims` links the dimensions and preserves claim measures such as claim amount, injury claim, property claim, vehicle claim, and fraud flag.

### Gold

The gold layer produces business-facing materialized views designed for reporting and analysis:

- `kpi_total_claims` for enterprise-wide claim volume and total claim amount.
- `kpi_claims_by_state` for geographic distribution, severity mix, and fraud rate.
- `kpi_claims_by_severity` for severity-driven damage and injury analysis.
- `kpi_temporal_patterns` for hourly, daily, and monthly claim behavior.
- `kpi_policy_performance` for loss ratio, premium efficiency, and deductible segmentation.
- `kpi_incident_type_analysis` for collision and incident pattern analysis.
- `kpi_fraud_analysis` for fraud prevalence and fraudulent claim characteristics.
- `kpi_customer_value` for retention, lifetime premium, and loss ratio insights.
- `kpi_customer_segments` for demographic segmentation and risk profiling.
- `kpi_collision_analysis` for collision impact, injuries, and police-report behavior.
- `kpi_vehicle_claims` for vehicle age, make, model, and damage risk.

## KPI Portfolio

| View | Primary Question Answered |
| --- | --- |
| `kpi_total_claims` | What is the total claims count and total paid amount? |
| `kpi_claims_by_state` | Which states generate the most claims, loss, and fraud? |
| `kpi_claims_by_severity` | How do severity levels influence injuries and damage types? |
| `kpi_temporal_patterns` | When do claims occur most often? |
| `kpi_policy_performance` | Which policy segments generate the highest loss ratios? |
| `kpi_incident_type_analysis` | Which incident and collision types are most costly? |
| `kpi_fraud_analysis` | What is the fraud rate and how does fraud differ from legitimate claims? |
| `kpi_customer_value` | Which customer segments produce the best or worst lifetime economics? |
| `kpi_customer_segments` | Which demographic segments are most exposed to claim and fraud risk? |
| `kpi_collision_analysis` | How do collision patterns affect injuries, police reports, and fraud? |
| `kpi_vehicle_claims` | Which vehicle categories drive the largest claim losses? |

## Executive Outcomes

- Faster claims monitoring through pre-aggregated KPI views.
- Better underwriting and portfolio decisions through policy and customer segmentation.
- Clearer fraud detection patterns through consistent fraud-rate calculations.
- Reduced model ambiguity by standardizing the source into conformed dimensions and a single fact table.

## Repository Structure

```text
Insurance_claims/
  transformations/
    bronze/
      insurance_claims.py
    silver/
      star_schema.py
    gold/
      kpi_claims_by_severity.sql
      kpi_claims_by_state.sql
      kpi_collision_analysis.sql
      kpi_customer_segments.sql
      kpi_customer_value.sql
      kpi_fraud_analysis.sql
      kpi_incident_type_analysis.sql
      kpi_policy_performance.sql
      kpi_temporal_patterns.sql
      kpi_total_claims.sql
      kpi_vehicle_claims.sql
```

## Delivery Highlights

- A clean bronze-to-gold flow that is easy to explain to both technical and business audiences.
- A dimensional model that supports both analytical joins and focused KPI publishing.
- A metrics layer that is already aligned to common insurance leadership questions.
- A documentation-first presentation that can stand on its own in a portfolio, interview, or stakeholder review.

## Implementation Notes

- The bronze ingestion is implemented with Delta Live Tables.
- The silver layer uses surrogate keys for analytical joins while keeping `policy_id` as the business anchor.
- The gold layer is intentionally metric-focused, with each materialized view designed to power a specific business conversation.
- The design keeps raw ingestion, conformed modeling, and reporting separated so changes in one layer do not ripple unnecessarily into the others.

## What Makes It Strong

- The model is intentionally simple to understand but rich enough for serious analytics.
- The gold views cover both operational monitoring and strategic analysis.
- The diagrams map directly to the code, so the README doubles as a reliable technical handoff.

## Business Value

This architecture gives stakeholders three things at once: traceable ingestion, a consistent analytics model, and a ready-made KPI layer for dashboarding. It is suitable for executive reporting, claims triage, fraud monitoring, and customer profitability analysis.
