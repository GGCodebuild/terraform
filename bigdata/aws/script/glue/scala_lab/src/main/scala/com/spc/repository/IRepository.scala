package com.spc.repository

import com.amazonaws.services.s3.model.ObjectListing
import org.apache.spark.sql.{DataFrame, SparkSession}

trait IRepository {
    def verifyPath(bucketName: String, bucketPath: String): Boolean

    def generateFromCSVToDataframe(spark: SparkSession, path: String): DataFrame

    def persistParquet(path: String, dataFrame: DataFrame): Unit

    def getObject(bucketName: String, bucketPath: String): ObjectListing

    def moveObjects(sourceBucketName: String, sourceBucketPath: String, targetBucketName: String, targetPath: String): Unit
}