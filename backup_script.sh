#!/bin/bash

username=$(id -nu)
if [ "$username" != "root" ]
then
  echo "Must be root to run \"$(basename $0)\"."
  exit 1
fi

DATE=$(date +"%Y-%m-%d_%H%M%S")
db_pass=$(cat /opt/12.5_docker_fast_GT_py-main/.env | grep MYSQL_ROOT_PASSWORD= | awk -F\" '{print $2}')
network=$(docker network ls | grep backend | awk '{print $2}')

docker run --rm \
    -v $(pwd)/backup:/backup \
    --network="$network" \
    mysql:8.0 \
    mysqldump -h db -u root -p"$db_pass" --result-file=/backup/dumps.sql virtd


if [[ ! -d /opt/backup ]]; then
  mkdir /opt/backup 2>/dev/null
fi


cp ./backup/dumps.sql /opt/backup/$DATE-dumps.sql
sudo rm -rf ./backup