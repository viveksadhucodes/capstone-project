@dlt.table(
  name="customer_raw",
  table_properties={"quality": "bronze"}
)
def customer_raw():
    return (
        spark.read   # ✅ NOT readStream
        .format("csv")
        .option("header", "true")
        .option("inferSchema", "true")
        .load("/Volumes/workspace/default/project/customers.csv")
    )