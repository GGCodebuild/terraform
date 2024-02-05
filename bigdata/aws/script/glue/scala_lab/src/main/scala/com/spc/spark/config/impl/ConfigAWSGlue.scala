package com.spc.spark.config.impl

import org.apache.spark.sql.SparkSession
import com.amazonaws.services.glue.util.GlueArgParser
import com.spc.spark.config.IConfig

class ConfigAWSGlue() extends IConfig {
    def initSpark(): SparkSession = {
        SparkSession.builder()
            .appName("scala-csv-to-parquet")
            .getOrCreate()
    }

    def getbucketName(sysArgs: Array[String]): Map[String, String] = {
        val args = GlueArgParser.getResolvedOptions(sysArgs, Array("bucket"))
        val bucketNames = args("bucket").split(",")
        Map("landingZone" -> bucketNames.apply(0),
            "raw" -> bucketNames.apply(1))
    }
}
