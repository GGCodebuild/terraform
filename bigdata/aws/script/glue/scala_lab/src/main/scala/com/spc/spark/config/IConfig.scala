package com.spc.spark.config

import org.apache.spark.sql.{DataFrame, SparkSession}

trait IConfig {
    def initSpark(): SparkSession

    def getbucketName(sysArgs: Array[String]): Map[String, String]
}