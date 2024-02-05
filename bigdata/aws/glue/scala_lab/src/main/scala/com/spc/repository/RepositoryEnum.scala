package com.spc.repository

import com.spc.repository.impl.AWSS3Repository

object RepositoryEnum extends Enumeration {
    protected case class Val(name: String, region: String, description: String) extends super.Val(name)

    implicit def getInstance(x: Value): IRepository = {
        val valueEnum = x.asInstanceOf[Val]

        var instance: IRepository = null

        if (AWS_S3_SA_EAST_1.name.equals(valueEnum.name)) instance = new AWSS3Repository(valueEnum.region);

        instance
    }

    val AWS_S3_SA_EAST_1 = Val("AWS_S3_SA_EAST_1", "sa-east-1", "SA East (S. Paulo)")
}