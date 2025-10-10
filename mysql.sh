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
 dnf install mysql-server -y
 VALIDATE $? "Installing mysql server"

 systemctl enable mysqld
 VALIDATE $? "enabling mysql"

systemctl start mysqld
VALIDATE $? "started mysql"  

mysql_secure_installation --set-root-pass RoboShop@1
VALIDATE $? "setting up root password"