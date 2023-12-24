#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"


echo "script started executing at $TIMESTAMP" &>> $LOGFILE

VALIDATE ()
{
    if [ $1 -ne 0 ]
    then
        echo -e "$2 ... $R FAILED $N"
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N"
    fi
}

if [ $ID -ne 0 ]
then
    echo -e "$R ERROR:: Please run this script with root access $N"
    exit 1 # you can give other than 0
else
    echo "You are root user"
fi # fi means reverse of if, indicating condition end

dnf module disable nodejs -y  &>> $LOGFILE

VALIDATE $? "disabling nodejs current version"

dnf module enable nodejs:18 -y &>> $LOGFILE

VALIDATE $? "enabling nodejs:18 version"

dnf install nodejs -y &>> $LOGFILE

VALIDATE $? "installing nodejs:18 version"

##check roboshot user exists or not, if not there create else skip it.

id roboshop  &>> $LOGFILE #if roboshop user does not exist, then it is failure
if [ $? -ne 0 ]
then
    useradd roboshop
    VALIDATE $? "roboshop user creation"
else
    echo -e "roboshop user already exist $Y SKIPPING $N"
fi

mkdir -p /app

curl -L -o /tmp/cart.zip https://roboshop-builds.s3.amazonaws.com/cart.zip &>> $LOGFILE

VALIDATE $? "downloading cart zipfile"

cd /app 

unzip -o /tmp/cart.zip &>> $LOGFILE

cd /app 

npm install &>> $LOGFILE

VALIDATE $? "installing nodejs dependencies"

VALIDATE $? "Installing dependencies"

# use absolute, because cart.service exists there
cp /home/centos/roboshop-shell/cart.service /etc/systemd/system/cart.service &>> $LOGFILE

VALIDATE $? "Copying cart service file"

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "cart daemon reload"

systemctl enable cart &>> $LOGFILE

VALIDATE $? "Enable cart"

systemctl start cart &>> $LOGFILE

VALIDATE $? "Starting cart"