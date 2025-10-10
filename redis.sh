#!/bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[37m"

USERID=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop"
SCRIPT_NAME=$( echo $0 | cut -d "." -f1)
LOG_FILE=$LOGS_FOLDER/$SCRIPT_NAME.log

mkdir -p $LOGS_FOLDER
echo "script started executed at: $(date)" | tee -a $LOG_FILE

if [ $USERID -ne 0 ];then
    echo  "ERROR:: please run script with root user privilege"
    exit 1
fi

VALIDATE(){
    if [ $1 -ne 0 ];then
        echo -e "  $2...$R Failure $N" | tee -a $LOG_FILE
        exit 1
    else
        echo -e "  $2...$G Success $N" | tee -a $LOG_FILE
    fi
}

dnf module disable redis -y &>>$LOG_FILE
VALIDATE "disabling redis"

dnf module enable redis:7 -y &>>$LOG_FILE
VALIDATE "enabling redis"

dnf install redis -y &>>$LOG_FILE
VALIDATE "installing redis"

systemctl enable redis &>>$LOG_FILE
VALIDATE "Enabling redis"

systemctl start redis &>>$LOG_FILE
VALIDATE "Redis started"

sed -i -e 's/127.0.0.1/0.0.0.0/g' -e '/protected-mode/ c /protected-mode no/' /etc/redis/redis.conf
