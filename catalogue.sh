#!/bin/bash

ID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"
MONGODHOST="mongodb.balajibigdatadevops.online"

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
VALIDATE $? "disabling NodeJS current version" 

dnf module enable nodejs:18 -y &>> $LOGFILE
VALIDATE $? "enabling Nodejs:18 version"

dnf install nodejs -y &>> $LOGFILE
VALIDATE $? "Installing NodeJS..."

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

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip &>> $LOGFILE

VALIDATE $? "downloading catalogue file"

cd /app

unzip -o /tmp/catalogue.zip &>> $LOGFILE

VALIDATE $? "creating roboshop user..."

cd /app

npm install &>> $LOGFILE

VALIDATE $? "installing npn depedencies..."

cp /home/centos/roboshop-shell/catalogue.service /etc/systemd/system/catalogue.service

VALIDATE $? "copying catalogued service file..."

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "reloading the service file changes"

systemctl enable catalogue &>> $LOGFILE

VALIDATE $? "enabling catalogue service file"

systemctl start catalogue &>> LOGFILE

VALIDATE $? "starting catalogue service"

cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo &>> LOGFILE

VALIDATE $? "copying repo file"

dnf install mongodb-org-shell -y  &>> $LOGFILE

VALIDATE $? "Installing mongodb client"

mongo --host $MONGODHOST </app/schema/catalogue.js &>> $LOGFILE

VALIDATE $? "Loading catalouge data into MongoDB"

