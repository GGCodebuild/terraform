#!/bin/bash

mkdir -p temp

file_read=$1
file_conf="temp/conf_credentials_aws.sh"

echo "#!/bin/bash" > $file_conf

getValue () {
  VAR_KEY="$1"
  VAR_SIMBOL="$3"
  VAR_VALUE="$4"
  echo "${VAR_KEY}${VAR_SIMBOL}${VAR_VALUE}" | sed 's/ //g'
}

while read line;
do
    case $line in
      "region"*)
        echo "export $(getValue "AWS_DEFAULT_REGION" $line)" >> $file_conf;;
      "access_key"*)
        echo "export $(getValue "AWS_ACCESS_KEY_ID" $line)" >> $file_conf;;
      "secret_key"*)
        echo "export $(getValue "AWS_SECRET_ACCESS_KEY" $line)" >> $file_conf;;
      "token"*)
        echo "export $(getValue "AWS_SESSION_TOKEN" $line)" >> $file_conf;;
    esac
done < $file_read

