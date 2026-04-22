@dlt.table(
  name="incident_raw",
  table_properties={"quality": "bronze"}
)
def incident_raw():
    return (
        spark.read
        .format("csv")
        .option("header", "true")
        .option("inferSchema", "true")
        .load("/Volumes/workspace/default/project/incident.csv")
    )