@dlt.table(
  name="claim_raw",
  table_properties={"quality": "bronze"}
)
def claim_raw():
    return (
        spark.read
        .format("csv")
        .option("header", "true")
        .option("inferSchema", "true")
        .load("/Volumes/workspace/default/project/insurance_claims.csv")
    )