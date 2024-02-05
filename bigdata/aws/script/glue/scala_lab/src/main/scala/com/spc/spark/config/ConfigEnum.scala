package com.spc.spark.config

import com.spc.spark.config.impl.{ConfigAWSGlue, ConfigLocalUbuntu}

object ConfigEnum extends Enumeration {
    protected case class Val(name: String, environment: String, description: String) extends super.Val(name)

    implicit def getInstance(x: Value): IConfig = {
        val valueEnum = x.asInstanceOf[Val]

        var instance : IConfig = null
        if (LOCAL_UBUNTU.name.equals(valueEnum.name))  instance = new ConfigLocalUbuntu()
        if (AWS_GLUE.name.equals(valueEnum.name)) instance = new ConfigAWSGlue()

        instance
    }

    val LOCAL_UBUNTU = Val("LOCAL_UBUNTU", "LOCAL", "Utilizado para testes no ambiente do desenvolvedor")
    val AWS_GLUE = Val("AWS_GLUE", "AWS", "Utilizado para processamento no ambiente da AWS")
}