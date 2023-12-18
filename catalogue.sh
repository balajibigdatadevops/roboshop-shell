#!/bin/bash

ID=$(id -u)

R="\e[31m"
G="\e[32m"
N="\e[0m"

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"
MONGODHOST=""

echo "Script started at exeucint $TIMESTAMP" &>> $LOGFILE

VALIDATE() 
 {
 if [ $1 -ne 0 ]
  then
    echo -e "$2 ... $R FAILED $N"
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

dnf module disable nodejs -y &>> $LOGFILE
validate $? "disabling NodeJS current version..." 

dnf module enable nodejs:18 -y
validate $? "enabling Nodejs:18 version..."

dnf install nodejs -y &>> $LOGFILE
validate $? "Installing NodeJS..."


useradd roboshop
validate $? "creating roboshop user..."

mkdir -p /app

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip &>> $LOGFILE

validate $? "downloading catalogue file"

cd /app

unzip -o /tmp/catalogue.zip &>> $LOGFILE

validate $? "creating roboshop user..."

cd /app

npm install &>> $LOGFILE

validate $? "installing npn depedencies..."

cp catalogue.service /etc/systemd/system/catalogue.service

validate $? "copying catalogued service file..."

systemctl daemon-reload &>> $LOGFILE

validate $? "reloading the service file changes..."

systemctl enable catalogue &>> $LOGFILE

validate $? "enabling catalogue service file..."

systemctl start catalogue &>> LOGFILE

validate $? "starting catalogue service..."

cp mongo.repo /etc.yum.repos.d/mongo.repo &>> LOGFILE

validate $? "copying repo file"

dnf install mongodb-org-shell -y

mongo --host $MONGODHOST </app/schema/catalogue.js



