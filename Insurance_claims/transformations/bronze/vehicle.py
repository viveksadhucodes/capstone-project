@dlt.table(
  name="vehicle_raw",
  table_properties={"quality": "bronze"}
)
def vehicle_raw():
    return (
        spark.read
        .format("csv")
        .option("header", "true")
        .option("inferSchema", "true")
        .load("/Volumes/workspace/default/project/vehicle.csv")
    )