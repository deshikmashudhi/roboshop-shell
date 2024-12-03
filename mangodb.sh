#!/bin/bash
R="\e[32m"
G="\e[31m"
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

cp mangodb.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE

validate $? "copied mango repo to yum.repos.d"

apt install mangodb-org -y &>> $LOGFILE

validate $? "installed mangodb"

systemtcl enable mangodb &>> $LOGFILE

validate $? "enabled mangodb"

systemctl start mangod &>> $LOGFILE

validate $? "started mangodb"

sed -i 's/127.0.0.1/0.0.0.0/' /etc/mangodb.conf &>> $LOGFILE

validate $? "edited mangodb conf"

systemctl restart mangodb &>> $LOGFILE

validate $? "Restarting mangodb"