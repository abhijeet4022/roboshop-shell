# Change the hostname
#hostnamectl set-hostname mongodb
# Put  sleep for 5S so hostname fully propagate before running the next script.
#sleep 5


#Developer has chosen the database MongoDB. Hence, we are trying to install it up and configure it.
#Setup the MongoDB repo file
cp mongo.repo /etc/yum.repos.d/mongo.repo

#Install MongoDB
yum install -y mongodb-org bash-completion

#Start & Enable MongoDB Service
systemctl start mongod
systemctl enable mongod

#Update listen address from 127.0.0.1 to 0.0.0.0
sed -i 's/127.0.0.1/0.0.0.0/' /etc/mongod.conf


#Usually MongoDB opens the port only to localhost(127.0.0.1), meaning this service can be accessed by the application
#that is hosted on this server only. However, we need to access this service to be accessed by another server, So we need to
# change the config accordingly.
#Update listen address from 127.0.0.1 to 0.0.0.0 in /etc/mongod.conf


#Restart the service to make the changes effected.
systemctl restart mongod

# Repo URL "https://github.com/abhijeet4022/roboshop-shell.git"

#exec bash

echo "-----------Script Run Successfully-----------"

