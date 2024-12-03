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

validate $? "setting up npm source"

yum install nodejs -y  &>>$LOGFILE

validate $? "nodejs installed" &>>$LOGFILE
# once the user is created if you run again it will fail
#this command will deffinetly fail
#check user is exist or not 
useradd roboshop  &>>$LOGFILE

validate $? "user created"

mkdir /app  &>>$LOGFILE

validate $? "folder created" 

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip  &>>$LOGFILE

cd /app &>>$LOGFILE

unzip /tmp/catalogue.  &>>$LOGFILE

validate $? "unzip catalogue"

cd /app &>>$LOGFILE

npm install  &>>$LOGFILE

validate $? "install dependnecies"

cp /home/ubuntu/roboshop-shell/catalogue.service /etc/systemd/system/catalogue.service &>>$LOGFILE

validate $? "copy catalogue service"

systemctl daemon-reload &>>$LOGFILE

systemcl enable  &>>$LOGFILE
systemctl start catalogue  &>>$LOGFILE
cp /home/ubuntu/roboshop-shell/mongo.repo /etc/yum.repos.d/mango.repo  &>>$LOGFILE

validate $? "copy mango repo"

yum install mongodb-org-shell -y  &>>$LOGFILE

validate $? "installing mango-client"

mongo --host  mangodb.roboshop.com </app/schema/catalogue.js  &>>$LOGFILE

validate $? "loding catalogue data into mangod"

