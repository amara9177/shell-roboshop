#!/bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[37m"

LOGS_FOLDER="/var/log/shell-roboshop"
SCRIPT_NAME=$( echo $0 | cut -d "." -f1)
SCRIPT_DIR=$PWD
MONGODB_HOST=mongodb.kaws86s.shop
START_TIME=$(date +%s)
LOG_FILE=$LOGS_FOLDER/$SCRIPT_NAME.log
MYSQL_HOST=mysql.kaws86s.shop

mkdir -p $LOGS_FOLDER
echo "script started executed at: $(date)" | tee -a $LOG_FILE

 USERID=$(id -u)
if [ $USERID -ne 0 ];then
    echo  "ERROR:: please run script with root user privilege"
    exit 1
fi

VALIDATE(){ #functions recieve inputs through orgs just like shell script
    if [ $1 -ne 0 ];then
        echo -e "  $2...$R Failure $N" | tee -a $LOG_FILE
        exit 1
    else
        echo -e "  $2...$G Success $N" | tee -a $LOG_FILE
    fi
}

dnf install maven -y

id roboshop &>>$LOG_FILE
if [ $? -ne 0 ];then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop  &>>$LOG_FILE
    VALIDATE $? "Creating system user"
else
    echo -e "user already exist... $Y SKIPPING $N"
fi

mkdir -p /app 
VALIDATE $? "Creating app directory"
curl -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip  &>>$LOG_FILE
VALIDATE $? "Downloading shipping application"

cd /app
VALIDATE $? "changing app directory"

rm -rf /app/*
VALIDATE $? "Removing existing code"

unzip /tmp/shipping.zip  &>>$LOG_FILE
VALIDATE $? "Unzip shipping"

mvn clean package 
mv target/shipping-1.0.jar shipping.jar 

cp $SCRIPT_DIR/shipping.service /etc/systemd/system/shipping.service

systemctl daemon-reload &>>$LOG_FILE
VALIDATE $? "daemon_reload"

systemctl enable shipping &>>$LOG_FILE
VALIDATE $? "Enabling shipping"

systemctl start shipping &>>$LOG_FILE
VALIDATE $? "Started shipping"

mysql -h mysql.kaws86s.shop -uroot -pRoboShop@1 -e 'use cities'
if [ $? -ne 0 ];then
    mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/schema.sql
    mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/app-user.sql 
    mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/master-data.sql
else
    echo -e "shipping products are already loaded...$Y SKIPPING $N"
fi

systemctl restart shipping  &>>$LOG_FILE
VALIDATE $? "Restarting shipping"
