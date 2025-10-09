#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[37m"

LOGS_FOLDER="/var/log/shell-roboshop"
SCRIPT_NAME=$( echo $0 | cut -d "." -f1)
SCRIPT_DIR=$PWD
MONGODB_HOST=mongodb.kaws86s.shop
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

dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "disabling nodejs"
dnf module enable nodejs:20 -y &>>$LOG_FILE
VALIDATE $? "enabling nodejs"
dnf install nodejs -y  &>>$LOG_FILE
VALIDATE $? "installing nodejs"

id roboshop
if [ $? -ne 0 ];then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop  &>>$LOG_FILE
    VALIDATE $? "Creating system user"
else
    echo -e "user already exist... $Y SKIPPING $N"
fi

mkdir -p /app 
VALIDATE $? "Creating app directory"
curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip  &>>$LOG_FILE
VALIDATE $? "Downloading catalogue application"

rm -rf /app/*
VALIDATE $? "Removing existing code"

cd /app
VALIDATE $? "changing app directory"

unzip /tmp/catalogue.zip  &>>$LOG_FILE
VALIDATE $? "Unzip catalogue"

npm install  &>>$LOG_FILE
VALIDATE $? "install dependencies"

cp $SCRIPT_DIR/catalogue.service /etc/systemd/system/catalogue.service
VALIDATE $? "copy systemctl service"

systemctl daemon-reload
systemctl enable catalogue  &>>$LOG_FILE
VALIDATE $? "Enable catalogue"

cp mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "Copy mongo.repo"

dnf install mongodb-mongosh -y  &>>$LOG_FILE
VALIDATE $? "install mongoDB client"

mongosh --host $MONGODB_HOST </app/db/master-data.js &>>$LOG_FILE
VALIDATE $? "Load catalogue products"

systemctl restart catalogue
VALIDATE $? "restarted catalogue"

