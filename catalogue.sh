# Change the hostname
hostnamectl set-hostname catalogue
# Put  sleep for 5S so hostname fully propagate before running the next script.
sleep 5

# Configuring repo to download nodejs NodeJS>=18
curl -sL https://rpm.nodesource.com/setup_lts.x | bash
yum install -y bash-completion nodejs

# Setup an app directory.
mkdir /app

# Download the application code to created app directory.
curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue.zip
unzip -o /tmp/catalogue.zip -d /app/

# Every application is developed by development team will have some common software's that they use as libraries. This application also have the same way of defined dependencies in the application configuration.
#Lets download the dependencies.
npm install -C /app/ # We can install dependency without navigate to that directory.

# Add application user
useradd roboshop

# We need to setup a service in systemd so systemctl can manage this service.
# Setup SystemD Catalogue Service.
# Ensure you replace <MONGODB-SERVER-IPADDRESS> with IP address
cp catalogue.service /etc/systemd/system/catalogue.service

# Load the service.
#This command is because we added a new service, We are telling systemd to reload so it will detect new service.
systemctl daemon-reload

# Start & Enable the service.
systemctl enable catalogue
systemctl restart catalogue

#For the application to work fully functional we need to load schema to the Database.
#Schemas are usually part of application code and developer will provide them as part of development.
#We need to load the schema. To load schema we need to install mongodb client.
#To have it installed we can setup MongoDB repo and install mongodb-client.
cp mongo.repo /etc/yum.repos.d/mongo.repo
dnf install mongodb-org-shell -y

#Load Schema
#mongo --host MONGODB-SERVER-IPADDRESS </app/schema/catalogue.js

#Need to update catalogue server ip address in frontend configuration.
# Configuration file is /etc/nginx/default.d/roboshop.conf

exec bash