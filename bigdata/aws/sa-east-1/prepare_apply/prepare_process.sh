#!/bin/bash

mkdir -p temp

file_read=$1
file_conf="temp/conf_credentials_aws.sh"


getValue () {
  VAR_VALUE="$3"
  echo "${VAR_VALUE}" | sed 's/ //g'
}

while read line;
do
    case $line in
      "region"*)
        AWS_REGION=$(getValue $line);;
      "access_key"*)
        AWS_ACCESS_KEY_ID=$(getValue $line);;
      "secret_key"*)
        AWS_ACCESS_KEY_SECRET=$(getValue $line);;
      "token"*)
        TOKEN=$(getValue $line);;
    esac

done < $file_read

PROLIFE="\"default\""
OUTPUT="\"json\""

echo "aws configure --profile $PROLIFE set aws_access_key_id $AWS_ACCESS_KEY_ID" > $file_conf
echo "aws configure --profile $PROLIFE set aws_secret_access_key $AWS_ACCESS_KEY_SECRET" >> $file_conf
echo "aws configure --profile $PROLIFE set region $AWS_REGION" >> $file_conf
echo "aws configure --profile $PROLIFE set output $OUTPUT" >> $file_conf




