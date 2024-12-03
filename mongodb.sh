#!/bin/bash

DATE=$(date +%F)
LOGSDIR=/tmp
# /home/centos/shellscript-logs/script-name-date.log
SCRIPT_NAME=$0
LOGFILE=$LOGSDIR/$0-$DATE.log
USERID=$(id -u)
R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"

if [ $USERID -ne 0 ];
then
    echo -e "$R ERROR:: Please run this script with root access $N"
    exit 1
fi

VALIDATE(){
    if [ $1 -ne 0 ];
    then
        echo -e "$2 ... $R FAILURE $N"
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N"
    fi
}

sudo apt update -y &>> $LOGFILE
VALIDATE $? "updated"
sudo apt install -y wget gnupg &>> $LOGFILE
validate $? "installed required dependnecies"

wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | sudo apt-key add - &>> $LOGFILE
validate $? "imported pub key"

echo "deb [arch=amd64] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/6.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list &>> $LOGFILE
validate $? "done"

sudo apt update -y &>> $LOGFILE
validate $? "done"

cp mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE

VALIDATE $? "Copied MongoDB repo into yum.repos.d"

apt install mongodb-org -y &>> $LOGFILE


VALIDATE $? "Installation of MongoDB"

systemctl enable mongod &>> $LOGFILE

VALIDATE $? "Enabling MongoDB"

systemctl start mongod &>> $LOGFILE

VALIDATE $? "Starting MongoDB"

sed -i 's/127.0.0.1/0.0.0.0/' /etc/mongod.conf &>> $LOGFILE

VALIDATE $? "Edited MongoDB conf"

systemctl restart mongod &>> $LOGFILE

VALIDATE $? "Restarting MonogoDB"