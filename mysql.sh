# Change the hostname
#hostnamectl set-hostname mysql
# Put  sleep for 5S so hostname fully propagate before running the next script.
#sleep 5

# Developer has chosen the database MySQL. Hence, we are trying to install it up and configure it.
# CentOS-8 Comes with MySQL 8 Version by default, However our application needs MySQL 5.7. So lets disable MySQL 8 version.
dnf module disable mysql -y

# Setup the MySQL5.7 repo file
cp mysql.repo /etc/yum.repos.d/mysql.repo

#Install MySQL Server
dnf install mysql-community-server bash-completion -y

# Start MySQL Service
systemctl enable mysqld
systemctl restart mysqld

# We need to change the default root password in order to start using the database service. Use password RoboShop@1 or any other as per your choice.
mysql_secure_installation --set-root-pass RoboShop@1

echo "-----------Script Run Successfully-----------"