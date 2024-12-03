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

yum install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y &>>$LOGFILE

validate $? "repo has downloaded"

yum module enable redis:remi-6.2 -y &>>$LOGFILE

validate $? "enabled redis"


yum install redis -y &>>$LOGFILE

validate $? "redis installed"

sed -i 's/127.0.0.1/0.0.0.0/' /etc/redis.conf &>>$LOGFILE

validate $? "config file updated"

systemctl enable redis &>>$LOGFILE

validate $? "enabled redis"

systemctl start redis &>>$LOGFILE

validate $? "redis started"