import dlt
from pyspark.sql.functions import col, monotonically_increasing_id

# =========================
# BASE TABLE (SOURCE OF TRUTH)
# =========================
@dlt.table(
    name="base_claims",
    table_properties={"pipelines.autoOptimize.managed": "true"}
)
def base_claims():
    df = dlt.read("claim_raw")

    # Handle both naming possibilities safely
    if "policy_number" in df.columns:
        df = df.withColumnRenamed("policy_number", "policy_id")

    return df


# =========================
# DIM CUSTOMER
# =========================
@dlt.table(
    name="dim_customer",
    table_properties={"pipelines.autoOptimize.managed": "true"}
)
def dim_customer():
    df = dlt.read("base_claims")

    return (
        df.select(
            "policy_id",
            "age",
            "insured_sex",
            "insured_education_level",
            "insured_occupation",
            "insured_relationship",
            "capital_gains",
            "capital_loss"
        )
        .dropDuplicates()
        .withColumn("customer_id", monotonically_increasing_id())
    )


# =========================
# DIM VEHICLE
# =========================
@dlt.table(
    name="dim_vehicle",
    table_properties={"pipelines.autoOptimize.managed": "true"}
)
def dim_vehicle():
    df = dlt.read("base_claims")

    return (
        df.select(
            "policy_id",
            "auto_make",
            "auto_model",
            "auto_year"
        )
        .dropDuplicates()
        .withColumn("vehicle_id", monotonically_increasing_id())
    )


# =========================
# DIM INCIDENT
# =========================
@dlt.table(
    name="dim_incident",
    table_properties={"pipelines.autoOptimize.managed": "true"}
)
def dim_incident():
    df = dlt.read("base_claims")

    return (
        df.select(
            "policy_id",
            "incident_date",
            "incident_type",
            "collision_type",
            "incident_severity",
            "incident_state",
            "incident_city",
            "incident_hour_of_the_day",
            "number_of_vehicles_involved",
            "bodily_injuries",
            "witnesses",
            "police_report_available"
        )
        .dropDuplicates()
        .withColumn("incident_id", monotonically_increasing_id())
    )


# =========================
# DIM POLICY
# =========================
@dlt.table(
    name="dim_policy",
    table_properties={"pipelines.autoOptimize.managed": "true"}
)
def dim_policy():
    df = dlt.read("base_claims")

    return (
        df.select(
            "policy_id",
            "policy_state",
            "policy_csl",
            "policy_deductable",
            "policy_annual_premium",
            "umbrella_limit",
            "months_as_customer"
        )
        .dropDuplicates()
    )


# =========================
# FACT TABLE
# =========================
@dlt.table(
    name="fact_claims",
    table_properties={"pipelines.autoOptimize.managed": "true"}
)
def fact_claims():

    base = dlt.read("base_claims")
    customer = dlt.read("dim_customer")
    vehicle = dlt.read("dim_vehicle")
    incident = dlt.read("dim_incident")

    df = (
        base
        .join(customer, "policy_id", "left")
        .join(vehicle, "policy_id", "left")
        .join(incident, "policy_id", "left")
    )

    return df.select(
        monotonically_increasing_id().alias("claim_id"),
        "policy_id",
        "customer_id",
        "vehicle_id",
        "incident_id",
        "total_claim_amount",
        "injury_claim",
        "property_claim",
        "vehicle_claim",
        col("fraud_reported").alias("fraud_flag")
    )