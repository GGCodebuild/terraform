package com.spc.repository.impl

import com.amazonaws.services.s3.AmazonS3ClientBuilder
import com.amazonaws.services.s3.model.{ListObjectsRequest, ObjectListing, S3ObjectSummary}
import com.spc.repository.IRepository
import org.apache.spark.sql.{DataFrame, SparkSession}

class AWSS3Repository(region: String) extends IRepository {
    def verifyPath(bucketName: String, bucketPath: String): Boolean = {
        val s3 = AmazonS3ClientBuilder.standard.withRegion(region).build
        val listObjectsRequest = new ListObjectsRequest().withBucketName(bucketName).withPrefix(bucketPath);
        val bucketListing = s3.listObjects(listObjectsRequest);

        (bucketListing != null && bucketListing.getObjectSummaries() != null
        && bucketListing.getObjectSummaries().size() > 1)
    }

    def generateFromCSVToDataframe(spark: SparkSession, path: String): DataFrame = {
        spark.read.format("csv").option("header", "true").load(path)
    }

    def persistParquet(path: String, dataFrame: DataFrame): Unit = {
        dataFrame.write.mode("append").parquet(path)
    }

    def getObject(bucketName: String, bucketPath: String): ObjectListing = {
        val s3 = AmazonS3ClientBuilder.standard.withRegion(region).build
        val listObjectsRequest = new ListObjectsRequest().withBucketName(bucketName).withPrefix(bucketPath);
        s3.listObjects(listObjectsRequest);
    }

    def moveObjects(sourceBucketName: String, sourceBucketPath: String, targetBucketName: String, targetBucketPath: String): Unit = {
        val listObjectsRequest = getObject(sourceBucketName, sourceBucketPath).getObjectSummaries()
        listObjectsRequest.forEach((element: S3ObjectSummary) => {
            if (!sourceBucketPath.equals(element.getKey())) {
                moveObject(sourceBucketName, element.getKey(), targetBucketName, targetBucketPath)
            }
        })
    }

    private def moveObject(sourceBucketName: String, sourceBucketPath: String, targetBucketName: String, targetBucketPath: String): Unit = {
        val filename = sourceBucketPath.split('/').last;
        val targetFilePath: String = targetBucketPath + filename;

        println("-------------------------------");
        println(filename);
        println("-------------------------------");

        val s3 = AmazonS3ClientBuilder.standard.withRegion(region).build
        s3.copyObject(sourceBucketName, sourceBucketPath, targetBucketName, targetFilePath);
        removeFiles(sourceBucketName, sourceBucketPath)
    }

    private def removeFiles(bucketName: String, bucketPath: String): Unit ={
        val s3 = AmazonS3ClientBuilder.standard.withRegion(region).build
        val listObjectsRequest =  s3.listObjects(bucketName, bucketPath).getObjectSummaries()

        listObjectsRequest.forEach((element: S3ObjectSummary) => {
            s3.deleteObject(bucketName, element.getKey())
        })
    }
}
