import com.spc.process.IProcess
import com.spc.process.impl.MainProcess
import com.spc.spark.config.ConfigEnum

object LocalUbuntu {
    def main(sysArgs: Array[String]): Unit = {
        val config = ConfigEnum.getInstance(ConfigEnum.LOCAL_UBUNTU)
        val spark = config.initSpark()
        val bucketName = config.getbucketName(sysArgs)
        val process: IProcess = new MainProcess()
        process.execute(spark, bucketName)
    }
}