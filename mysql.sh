#!/bin/bash

LOGS_FOLDER="/var/log/expense"
SCRIPT_NAME=$(basename $0 | cut -d "." -f1)
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME-$TIMESTAMP.log"
mkdir -p $LOGS_FOLDER

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"

CHECK_ROOT(){
    if [ $USERID -ne 0 ]
    then
        echo -e "$R Please run this script with root privileges $N" | tee -a $LOG_FILE
        exit 1
    fi
}

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 is... $R FAILED $N"  | tee -a $LOG_FILE
        exit 1
    else
        echo -e "$2 is... $G SUCCESS $N" | tee -a $LOG_FILE
    fi
}

echo "Script started executing at: $(date)" | tee -a $LOG_FILE

CHECK_ROOT

# Check if MySQL is already installed
if rpm -q mysql-server &>/dev/null; then
    echo -e "MySQL Server is already installed... $Y SKIPPING $N" | tee -a $LOG_FILE
else
    dnf install mysql-server -y &>>$LOG_FILE
    VALIDATE $? "Installing MySQL Server"
fi

# Check if MySQL service is enabled
if systemctl is-enabled mysqld &>/dev/null; then
    echo -e "MySQL Server is already enabled... $Y SKIPPING $N" | tee -a $LOG_FILE
else
    systemctl enable mysqld &>>$LOG_FILE
    VALIDATE $? "Enabling MySQL Server"
fi

# Check if MySQL service is running
if systemctl is-active mysqld &>/dev/null; then
    echo -e "MySQL Server is already running... $Y SKIPPING $N" | tee -a $LOG_FILE
else
    systemctl start mysqld &>>$LOG_FILE
    VALIDATE $? "Starting MySQL Server"
fi

# Check if MySQL root password is set
mysql -h mysql.joinsankardevops.online -u root -pExpenseApp@1 -e 'show databases;' &>>$LOG_FILE
if [ $? -ne 0 ]; then
    echo "MySQL root password is not set up, setting now" | tee -a $LOG_FILE
    mysql_secure_installation --set-root-pass ExpenseApp@1
    VALIDATE $? "Setting up root password"
else
    echo -e "MySQL root password is already set... $Y SKIPPING $N" | tee -a $LOG_FILE
fi
