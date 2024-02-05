ThisBuild / version := "0.1.0-SNAPSHOT"

ThisBuild / scalaVersion := "2.12.16"

val awsVersion = "1.12.276"
val awsHadoop = "3.2.3"

licenses ++= Seq(
  ("Amazon Software License",  url("http://aws.amazon.com/asl/"))
)

resolvers ++= Seq(
  Resolver.sonatypeRepo("releases"),
  "Secured Central Repository" at "https://repo1.maven.org/maven2",
  "aws-glue-etl-artifacts" at "https://aws-glue-etl-artifacts.s3.amazonaws.com/release/"
)

excludeDependencies ++= Seq(
  ExclusionRule("org.apache.avro", "org.apache.avro")
)

libraryDependencies ++= Seq(
  "org.apache.spark" %% "spark-core" % "3.2.1",
  "org.apache.spark" %% "spark-sql" % "3.2.1",
  "com.amazonaws" % "aws-java-sdk" % awsVersion,
  "com.amazonaws" % "aws-java-sdk-glue" % awsVersion,
  "org.apache.hadoop" % "hadoop-aws" %  awsHadoop,
  "com.amazonaws" % "AWSGlueETL" % "3.0.0" exclude("org.apache.avro", "avro-mapred")
)

lazy val root = (project in file("."))
  .settings(
    name := "scala-lab"
  )