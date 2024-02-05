package com.spc.process.impl

import com.spc.process.IProcess
import com.spc.repository.RepositoryEnum
import org.apache.spark.sql.{Row, SparkSession}
import org.apache.spark.sql.functions.{explode, udf}
import org.apache.spark.sql.expressions.UserDefinedFunction

class MainProcess extends IProcess {   
    def execute(spark: SparkSession, bucketName: Map[String, String]): Unit = {
        import spark.implicits._

        val bucketLandingZone = bucketName.get("landingZone")
        val bucketRaw = bucketName.get("raw")
        val pathBucketLandingZoneToProcess = "input/apartment-geometries/"
        val pathBucketLandingZoneProcessing = "input/apartment-geometries/work-in-progress/"
        val pathBucketLandingZoneProcessed = "input/apartment-geometries/processed/"
        val pathBucketRaw = "apartment-geometries.parquet/"
        val pathLandingZoneWorkInProgress = "s3a://" + bucketLandingZone.get + "/" + pathBucketLandingZoneProcessing
        val pathTrusted = "s3a://" + bucketRaw.get + "/" + pathBucketRaw

        val repository = RepositoryEnum.getInstance(RepositoryEnum.AWS_S3_SA_EAST_1)

        if (repository.verifyPath(bucketLandingZone.get, pathBucketLandingZoneToProcess)) {
            repository.moveObjects(bucketLandingZone.get, pathBucketLandingZoneToProcess, bucketLandingZone.get, pathBucketLandingZoneProcessing)

            val df = repository.generateFromCSVToDataframe(spark, pathLandingZoneWorkInProgress)

            repository.persistParquet(pathTrusted, df)

            repository.moveObjects(bucketLandingZone.get, pathBucketLandingZoneProcessing, bucketLandingZone.get, pathBucketLandingZoneProcessed)
        } else {
            println(f"There isn't a path ${pathBucketLandingZoneToProcess} in the bucket ${bucketLandingZone}")
        }

        println(f"Process executed successfully")
    }
}