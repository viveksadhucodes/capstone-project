from pyspark.sql.functions import current_timestamp, lit
def clean_columns(df):
    return df.toDF(*[
        c.strip()
         .replace("-", "_")
         .replace(" ", "_")
        for c in df.columns
    ])
@dlt.table(name="claim_raw", table_properties={"quality": "bronze"})
def claim_raw():
    df = spark.read.format("csv") \
        .option("header", "true") \
        .option("inferSchema", "true") \
        .load("/Volumes/workspace/default/project/insurance_claims.csv")

    df = clean_columns(df)

    return df.withColumn("processing_time", current_timestamp()) \
             .withColumn("source_file", lit("insurance_claims.csv"))