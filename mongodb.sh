#!/bin/bash

DATE=$(date +%F)
LOGSDIR=/tmp
SCRIPT_NAME=$0
LOGFILE=$LOGSDIR/$(basename $SCRIPT_NAME)-$DATE.log
USERID=$(id -u)
R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"

# Check if the script is run with root privileges
if [ $USERID -ne 0 ]; then
    echo -e "$R ERROR:: Please run this script with root access $N"
    exit 1
fi

# Validate function
VALIDATE(){
    if [ $1 -ne 0 ]; then
        echo -e "$2 ... $R FAILURE $N"
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N"
    fi
}

# Step 1: Update the package list
sudo apt update -y &>> $LOGFILE
VALIDATE $? "Updated package list"

# Step 2: Add MongoDB 4.2 repository (for Ubuntu)
echo "deb [arch=amd64] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/4.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.2.list &>> $LOGFILE
VALIDATE $? "Added MongoDB 4.2 repository"

# Step 3: Import MongoDB public key (if not already done)
wget -qO - https://www.mongodb.org/static/pgp/server-4.2.asc | sudo apt-key add - &>> $LOGFILE
VALIDATE $? "Imported MongoDB public key"

# Step 4: Update the package list again after adding the repository
sudo apt update -y &>> $LOGFILE
VALIDATE $? "Updated package list after adding MongoDB repository"

# Step 5: Install MongoDB
sudo apt install -y mongodb-org &>> $LOGFILE
VALIDATE $? "Installed MongoDB"

# Step 6: Enable MongoDB service to start on boot
systemctl enable mongod &>> $LOGFILE
VALIDATE $? "Enabled MongoDB service"

# Step 7: Start MongoDB service
systemctl start mongod &>> $LOGFILE
VALIDATE $? "Started MongoDB service"

# Step 8: Allow external connections by editing the MongoDB configuration
sed -i 's/127.0.0.1/0.0.0.0/' /etc/mongod.conf &>> $LOGFILE
VALIDATE $? "Edited MongoDB configuration"

# Step 9: Restart MongoDB to apply configuration changes
systemctl restart mongod &>> $LOGFILE
VALIDATE $? "Restarted MongoDB"

echo "MongoDB 4.2 installation and configuration completed successfully!"
