# Change the hostname
#hostnamectl set-hostname shipping
# Put  sleep for 5S so hostname fully propagate before running the next script.
#sleep 5

#Shipping service is responsible for finding the distance of the package to be shipped and calculate the price based on that.
#Shipping service is written in Java, Hence we need to install Java.
#Maven is a build or Java Packaging software, Hence we are going to install maven, This indeed takes care of java installation.
#Developer has chosen Maven, Check with developer which version of Maven is needed. Here for our requirement java >= 1.8 & maven >=3.5 should work.

dnf install maven -y

#We keep application in one standard location. This is a usual practice that runs in the organization.
#Lets setup an app directory.
mkdir /app

# Download the application code to created app directory.
curl -L -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping.zip
unzip -o /tmp/shipping.zip -d /app/

#Every application is developed by development team will have some common software's that they use as libraries.
# This application also have the same way of defined dependencies in the application configuration.
#Lets download the dependencies & build the application
mvn clean package -f /app/pom.xml
mv /app/target/shipping-1.0.jar /app/shipping.jar

#We need to setup a new service in systemd so systemctl can manage this service
# Setup SystemD Shipping Service
cp shipping.service /etc/systemd/system/shipping.service

#Load the service.
systemctl daemon-reload

# Start the service.
systemctl enable shipping
systemctl start shipping

# For this application to work fully functional we need to load schema to the Database.
# To load schema we need to install mysql client.
#To have it installed we can use

dnf install mysql -y
mysql -h <MYSQL-SERVER-IPADDRESS> -uroot -pRoboShop@1 </app/schema/shipping.sql

# Restart the service to apply the changes.
systemctl restart shipping