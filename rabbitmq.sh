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

cp $SCRIPT_DIR/rabbitmq.repo //etc/yum.repos.d/rabbitmq.repo &>>$LOG_FILE
VALIDATE $? "Adding RabbitMQ repo"

dnf install rabbitmq-server -y &>>$LOG_FILE
VALIDATE $? "Inastalling Rabbitmq"

systemctl enable rabbitmq-server &>>$LOG_FILE
VALIDATE $? "Enabling Rabbitmq server"

systemctl start rabbitmq-server &>>$LOG_FILE
VALIDATE $? "Starting Rabbitmq server"

rabbitmqctl add_user roboshop roboshop123 &>>$LOG_FILE
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>$LOG_FILE
VALIDATE $? "Setting up permissions"

END_TIME=$(date +%s)
TOTAL_TIME=$(( $END_TIME - $START_TIME ))
echo -e "Script executed in: $Y $TOTAL_TIME seconds $N"