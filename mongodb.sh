#!/bin/bash

ID=$(id -u)

R="\e[31m"
G="\e[32m"
N="\e[0m"

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

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

cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE

VALIDATE $? "copying MONGO repo file"

dnf install mongodb-org -y  &>> $LOGFILE

VALIDATE $? "Installing MONGO DB Server"

systemctl enable mongod &>> $LOGFILE

VALIDATE $? "enabling mongo service"

systemctl start mongod &>> $LOGFILE

VALIDATE $? "Starting mongo service"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf &>> $LOGFILE

VALIDATE $? "replacing localhost to remote server"

systemctl restart mongod &>> $LOGFILE

VALIDATE $? "restarting mongo server"

