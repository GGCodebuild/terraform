import com.spc.process.IProcess
import com.spc.process.impl.MainProcess
import com.spc.spark.config.ConfigEnum

object AWSGlue {
    def main(sysArgs: Array[String]): Unit = {
        val config = ConfigEnum.getInstance(ConfigEnum.AWS_GLUE)
        val spark = config.initSpark()
        val bucketName = config.getbucketName(sysArgs)
        val process: IProcess = new MainProcess()
        process.execute(spark, bucketName)
    }
}