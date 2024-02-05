package com.spc.process

import org.apache.spark.sql.SparkSession

trait IProcess {
    def execute(spark: SparkSession, bucketName: Map[String, String]): Unit
}