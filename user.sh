#!/bin/bash
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

DATE=$(date +%F)
LOGSDIR=/tmp
SCRIPT_NAME=$0
LOGFILE=$LOGSDIR/$SCRIPT_NAME-$DATE.log #to get logs regarding the format

USERID=$(id -u)

if [ $USERID -ne 0 ];
then
   echo -e "$R Error: please user root access $N"
   exit 1
fi
VALIDATE(){
    if [ $1 -ne 0 ];
    then
      echo -e "$2..$R faailure $N"
      exit 1
    else
       echo -e "$2..$G success $N"
    fi
     
}

curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>$LOGFILE
VALIDATE $? "NODEJS REPO DOWNLOADED"


yum install nodejs -y &>>$LOGFILE
VALIDATE $? "NODE JS INSTALLED"


useradd roboshop  &>>$LOGFILE
VALIDATE $? "USER CREATED"

mkdir /app  &>>$LOGFILE
VALIDATE $? "DIRECTORY CREATED"

curl -L -o /tmp/user.zip https://roboshop-builds.s3.amazonaws.com/user.zip &>>$LOGFILE
VALIDATE $? "DOWNLOADED APPLICATION"


cd /app &>>$LOGFILE
VALIDATE $? "DIRECTORY CHANGED"


unzip /tmp/user.zip &>>$LOGFILE
VALIDATE $? "UNZIPED THE FILE AND DOWNLOADED"

npm install  &>>$LOGFILE
VALIDATE $? "NPM INSTALLED"

cp /home/ubuntu/roboshop-shell/user.service /etc/systemd/system/user.service &>>$LOGFILE

VALIDATE $? "SUCCESSFULLY COPIED"

systemctl daemon-reload &>>$LOGFILE
VALIDATE $? "DEAMON-RELOADED"

systemctl enable user  &>>$LOGFILE

VALIDATE $? "ENABLED-USER"

systemctl start user &>>$LOGFILE

VALIDATE $? "USER STARTED"

cp /home/ubuntu/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo &>>$LOGFILE

VALIDATE $? "SUCCESSFULLY COPIED"

yum install mongodb-org-shell -y &>>$LOGFILE
VALIDATE $? "INSTALLING MANGO CLIENT"

mongo --host  mangodb.roboshop.com </app/schema/user.js &>>$LOGFILE
VALIDATE $? "LODING SCHEMA"