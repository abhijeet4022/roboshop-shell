# Change the hostname
#hostnamectl set-hostname payment
# Put  sleep for 5S so hostname fully propagate before running the next script.
#sleep 5

# Developer has chosen Python, Check with developer which version of Python is needed.
# Install Python 3.6
dnf install python36 gcc python3-devel bash-completion -y

#Lets setup an app directory.
mkdir /app

#Download the application code to created app directory.
curl -L -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment.zip
unzip -o /tmp/payment.zip -d /app/

# Every application is developed by development team will have some common softwares that they use as libraries.
# This application also have the same way of defined dependencies in the application configuration.
# Lets download the dependencies.
pip3.6 install -r /app/requirements.txt

#Add application User
useradd roboshop

#We need to setup a new service in systemd so systemctl can manage this service
# Setup SystemD Payment Service
cp payment.service /etc/systemd/system/payment.service

#Load the service.
systemctl daemon-reload

#Start the service.
systemctl enable payment
systemctl restart payment

echo "-----------Script Run Successfully-----------"