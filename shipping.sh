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

dnf install maven -y &>> $LOGFILE

VALIDATE $? "installing maven"

##check roboshot user exists or not, if not there create else skip it.

id roboshop  &>> $LOGFILE #if roboshop user does not exist, then it is failure
if [ $? -ne 0 ]
then
    useradd roboshop
    VALIDATE $? "roboshop user creation"
else
    echo -e "roboshop user already exist $Y SKIPPING $N"
fi

mkdir /app

curl -L -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip &>> $LOGFILE

VALIDATE $? "downloading shipping file"

cd /app

unzip -o /tmp/shipping.zip &>> $LOGFILE

VALIDATE $? "unzpping shipping file"

cd /app

mvn clean package $>> $LOGFILE

VALIDATE $? "installing depedencies"

mv target/shipping-1.0.jar shipping.jar 

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "reloading shipping"

systemctl enable shipping &>> $LOGFILE

VALIDATE $? "enabling shipping service"

systemctl start shipping &>> $LOGFILE

VALIDATE $? "starting shipping service"

dnf install mysql -y &>> $LOGFILE

VALIDATE $? "installing mysql client"

mysql -h mysql.balajibigdatadevops.online -uroot -pRoboShop@1 < /app/schema/shipping.sql &>> $LOGFILE

VALIDATE $? "connecting mysql and loading shipping schema data"

systemctl restart shipping &>> $LOGFILE

VALIDATE $? "restarting shipping"
