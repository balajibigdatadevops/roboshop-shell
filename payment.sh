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
fi # fi me

dnf install python36 gcc python3-devel -y &>> $LOGFILE

VALIDATE $? "installing python"

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

curl -L -o /tmp/payment.zip https://roboshop-builds.s3.amazonaws.com/payment.zip &>> $LOGFILE

VALIDATE $? "downloading payment zip file"

cd /app

unzip -o /tmp/payment.zip &>> $LOGFILE

VALIDATE $? "unzipping payment file"

cd /app 

pip3.6 install -r requirements.txt &>> $LOGFILE

VALIDATE $? "installing python modules"

cp /home/centos/roboshop-shell/payment.service /etc/systemd/system/payment.service &>> $LOGFILE

VALIDATE $? "copying payment service file"

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "reloading pyament"

systemctl enable payment &>> $LOGFILE

VALIDATE $? "enabling payment"

systemctl start payment &>> $LOGFILE

VALIDATE $? "starting payment"

