@dlt.table(
  name="policy_raw",
  table_properties={"quality": "bronze"}
)
def policy_raw():
    return (
        spark.read
        .format("csv")
        .option("header", "true")
        .option("inferSchema", "true")
        .load("/Volumes/workspace/default/project/policy.csv")
    )