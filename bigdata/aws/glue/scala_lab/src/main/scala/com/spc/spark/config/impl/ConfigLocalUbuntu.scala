package com.spc.spark.config.impl

import com.spc.spark.config
import com.amazonaws.services.s3.AmazonS3ClientBuilder
import com.amazonaws.services.s3.model.{ListObjectsRequest, ObjectListing, S3ObjectSummary}
import com.spc.spark.config.IConfig
import org.apache.spark.sql.{DataFrame, SparkSession}

class ConfigLocalUbuntu extends IConfig {
    def initSpark(): SparkSession = {

    SparkSession.builder()
        .appName("scala-csv-to-parquet")
        .master("local[*]")
        .config("spark.hadoop.fs.s3a.access.key", "[ACCESS]")
        .config("spark.hadoop.fs.s3a.secret.key", "[SECRET]")
        .config("spark.hadoop.fs.s3a.aws.credentials.provider", "org.apache.hadoop.fs.s3a.SimpleAWSCredentialsProvider")
        .config("spark.hadoop.fs.s3a.impl", "org.apache.hadoop.fs.s3a.S3AFileSystem")
        .getOrCreate()
    }

    def getbucketName(sysArgs: Array[String]): Map[String, String] = {
        Map("landingZone" -> "insert-bucket-landing-zone",
        "raw" -> "insert-bucket-raw")
    }
}