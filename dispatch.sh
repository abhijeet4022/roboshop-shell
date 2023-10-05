#We need to setup a new service in systemd so systemctl can manage this service
#Setup SystemD Payment Service
cp dispatch.service /etc/systemd/system/dispatch.service

# Change the hostname
#hostnamectl set-hostname dispatch
# Put  sleep for 5S so hostname fully propagate before running the next script.
#sleep 5

#Developer has chosen GoLang, Check with developer which version of GoLang is needed.
#Install GoLang
dnf install bash-completion golang -y

#Add application User
useradd roboshop

#Lets setup an app directory.
mkdir /app

# Download the application code to created app directory.
curl -L -o /tmp/dispatch.zip https://roboshop-artifacts.s3.amazonaws.com/dispatch.zip
unzip -o /tmp/dispatch.zip -d /app/

#Every application is developed by development team will have some common software's that they use as libraries.
# This application also have the same way of defined dependencies in the application configuration.
#Lets download the dependencies & build the software.

cd /app || return # From outside we can't run these command so need to navigate to that directory
go mod init dispatch    #dispatch is the module name we can change it but we have to modify in config file also
go get
go build

#Load the service.
systemctl daemon-reload

#Start the service.
systemctl enable dispatch
systemctl restart dispatch

echo "-----------Script Run Successfully-----------"