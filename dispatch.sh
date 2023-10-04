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

#Every application is developed by development team will have some common softwares that they use as libraries.
# This application also have the same way of defined dependencies in the application configuration.
#Lets download the dependencies & build the software.
go mod init dispatch -d /app/
go get -d /app/
go build /app/


#We need to setup a new service in systemd so systemctl can manage this service
#Setup SystemD Payment Service
cp dispatch.service /etc/systemd/system/dispatch.service

#Load the service.
systemctl daemon-reload

#Start the service.
systemctl enable dispatch
systemctl start dispatch