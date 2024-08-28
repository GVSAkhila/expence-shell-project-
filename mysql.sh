#!/bin/bash

LOG_Folder="/var/log/expense" 
SCRIPT_NAME=$( echo $0 | cut -d '.' -f1)
TIME_STAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOG_FILE="$LOG_Folder/$SCRIPT_NAME-$TIME_STAMP.log"
mkdir -p "$LOG_Folder"

# Define color codes
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

USERID=$(id -u)

if [ $USERID -ne 0 ]; then
  echo -e "${R}Please run this script with the root user.${N}" | tee -a "$LOG_FILE"
  exit 1
fi

VALIDATE() {
  if [ $1 -ne 0 ]; then
    echo -e "${2}...${R}failed${N}" | tee -a "$LOG_FILE"
  else
    echo -e "${2}...${G}success${N}" | tee -a "$LOG_FILE"
  fi
}

echo "Script started executing at: $(date)" | tee -a $LOG_FILE

dnf install mysql-server -y &>>$LOG_FILE
VALIDATE $? "installing mysql server"

systemctl enable mysqld &>>$LOG_FILE
VALIDATE $? "enable mysql server"

systemctl start mysqld &>>$LOG_FILE
VALIDATE $? "start mysql server" 

mysql_secure_installation --set-root-pass ExpenseApp@1

VALIDATE $? "setting the root password" 

