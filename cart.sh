# Change the hostname
#hostnamectl set-hostname cart
# Put  sleep for 5S so hostname fully propagate before running the next script.
#sleep 5

# Configuring repo to download nodejs NodeJS>=18
curl -sL https://rpm.nodesource.com/setup_lts.x | bash
yum install -y bash-completion nodejs

# Setup an app directory.
mkdir /app

# Download the application code to created app directory.
curl -o /tmp/cart.zip https://roboshop-artifacts.s3.amazonaws.com/cart.zip
unzip -o /tmp/cart.zip -d /app/

# Every application is developed by development team will have some common software's that they use as libraries. This application also have the same way of defined dependencies in the application configuration.
#Lets download the dependencies.
npm install -C /app/ # We can install dependency without navigate to that directory.

# Add application user
useradd roboshop

# We need to setup a service in systemd so systemctl can manage this service.
# Setup SystemD cart Service.
# Ensure you replace <MONGODB-SERVER-IPADDRESS> with IP address
cp cart.service /etc/systemd/system/cart.service


# Load the service.
#This command is because we added a new service, We are telling systemd to reload so it will detect new service.
systemctl daemon-reload

# Start & Enable the service.
systemctl enable cart
systemctl restart cart



#Need to update cart server ip address in frontend configuration.
# Configuration file is /etc/nginx/default.d/roboshop.conf

#exec bash

echo "-----------Script Run Successfully-----------"