#!/bin/bash
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

DATE=$(date +%F)
LOGSDIR=/tmp
LOGFILE=$LOGSDIR/$SCRIPT_NAME-$DATE.log #to get logs regarding the format
SCRIPT_NAME=$0
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

cp mongodb.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE

validate $? "copied mango repo to yum.repos.d"

apt install mongo-org -y &>> $LOGFILE

validate $? "installed mongo"

systemtcl enable mongo &>> $LOGFILE

validate $? "enabled mongo"

systemctl start mangod &>> $LOGFILE

validate $? "started mongo"

sed -i 's/127.0.0.1/0.0.0.0/' /etc/mongo.conf &>> $LOGFILE

validate $? "edited mongo conf"

systemctl restart mongo &>> $LOGFILE

validate $? "Restarting mongo"