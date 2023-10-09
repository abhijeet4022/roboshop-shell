# We need to setup a service in systemd so systemctl can manage this service.
# Setup SystemD Catalogue Service.
# Ensure you replace <MONGODB-SERVER-IPADDRESS> with IP address
echo -e "\e[34mDeleting The existing  /etc/systemd/system/catalogue.service file.\e[0m" | tee -a /tmp/roboshop.log
rm -rf /etc/systemd/system/catalogue.service &>> /tmp/roboshop.log

echo -e "\e[34mCopying The Catalogue.service to /etc/systemd/system/catalogue.service.\e[0m" | tee -a /tmp/roboshop.log
cp catalogue.service /etc/systemd/system/catalogue.service  &>> /tmp/roboshop.log

# Change the hostname
#hostnamectl set-hostname catalogue
# Put  sleep for 5S so hostname fully propagate before running the next script.
#sleep 5

# Configuring repo to download nodejs NodeJS>=18
echo -e "\e[34mConfiguring the repo for NodeJS.\e[0m" | tee -a /tmp/roboshop.log
curl -sL https://rpm.nodesource.com/setup_lts.x | bash  &>> /tmp/roboshop.log

echo -e "\e[34mInstalling NodeJS & bash-completion package.\e[0m" | tee -a /tmp/roboshop.log
yum install -y bash-completion nodejs  &>> /tmp/roboshop.log

# Setup an app directory.
echo -e "\e[34mRemoving the existing /app directory.\e[0m" | tee -a /tmp/roboshop.log
rm -rf /app &>> /tmp/roboshop.log

echo -e "\e[34mCreating Application Directory- /app.\e[0m" | tee -a /tmp/roboshop.log
mkdir /app  &>> /tmp/roboshop.log

# Download the application code to created app directory.
echo -e "\e[34mDownloading the Application code.\e[0m" | tee -a /tmp/roboshop.log
curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue.zip &>> /tmp/roboshop.log

echo -e "\e[34mExtracting the Application code.\e[0m" | tee -a /tmp/roboshop.log
unzip -o /tmp/catalogue.zip -d /app/ &>> /tmp/roboshop.log

# Every application is developed by development team will have some common software's that they use as libraries. This application also have the same way of defined dependencies in the application configuration.
#Lets download the dependencies.
echo -e "\e[34mInstalling the dependencies for the Application- /app/package.json.\e[0m" | tee -a /tmp/roboshop.log
npm install -C /app/  &>> /tmp/roboshop.log # We can install dependency without navigate to that directory.


# Add application user
echo -e "\e[34mCreating Application User- roboshop.\e[0m" | tee -a /tmp/roboshop.log
useradd roboshop  &>> /tmp/roboshop.log


# Load the service.
#This command is because we added a new service, We are telling systemd to reload so it will detect new service.
echo -e "\e[34mStarting & Enabling the catalogue service.\e[0m" | tee -a /tmp/roboshop.log
systemctl daemon-reload  &>> /tmp/roboshop.log

# Start & Enable the service.
systemctl enable catalogue  &>> /tmp/roboshop.log
systemctl start catalogue  &>> /tmp/roboshop.log

#For the application to work fully functional we need to load schema to the Database.
#Schemas are usually part of application code and developer will provide them as part of development.
#We need to load the schema. To load schema we need to install mongodb client.
#To have it installed we can setup MongoDB repo and install mongodb-client.

echo -e "\e[34mConfiguring the repo for mongodb.\e[0m" | tee -a /tmp/roboshop.log
cp mongo.repo /etc/yum.repos.d/mongo.repo  &>> /tmp/roboshop.log

echo -e "\e[34mInstalling the mongodb-org-shell package.\e[0m" | tee -a /tmp/roboshop.log
dnf install mongodb-org-shell -y  &>> /tmp/roboshop.log

#Load Schema
echo -e "\e[34mLoading the mongodb schema.\e[0m" | tee -a /tmp/roboshop.log
mongo --host mongodb.learntechnology.tech </app/schema/catalogue.js  &>> /tmp/roboshop.log

#Need to update catalogue server ip address in frontend configuration.
# Configuration file is /etc/nginx/default.d/roboshop.conf

#exec bash
# Restart the service.
echo -e "\e[34mRestarting the catalogue service.\e[0m" | tee -a /tmp/roboshop.log
systemctl restart catalogue  &>> /tmp/roboshop.log

echo -e "\e[34m-----------Script Run Successfully-----------\e[0m" | tee -a /tmp/roboshop.log