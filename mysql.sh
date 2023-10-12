mysql_root_password=$1
if [ -z "${mysql_root_password}" ]; then
  echo -e "\e[31mInput: Please mention the password for MYSQL.\e[0m"
  exit 1
fi

source common.sh
# Developer has chosen the database MySQL. Hence, we are trying to install it up and configure it.
# CentOS-8 Comes with MySQL 8 Version by default, However our application needs MySQL 5.7. So lets disable MySQL 8 version.

echo -e "\e[33m**** Disable the mysql default repo. ****\e[0m" | tee -a ${log}
dnf module disable mysql -y  &>> ${log}
func_exit_status

# Setup the MySQL5.7 repo file
echo -e "\e[33m**** Configuring mysql5.7 repository repo. ****\e[0m" | tee -a ${log}
cp mysql.repo /etc/yum.repos.d/mysql.repo    &>> ${log}
func_exit_status

#Install MySQL Server
echo -e "\e[33m**** Installing the mysql-community-server package. ****\e[0m" | tee -a ${log}
dnf install mysql-community-server bash-completion -y     &>> ${log}
func_exit_status

# Start MySQL Service
echo -e "\e[33m**** Starting & Enabling the mysqld service. ****\e[0m" | tee -a ${log}
systemctl enable mysqld    &>> ${log}
systemctl restart mysqld     &>> ${log}
func_exit_status

# We need to change the default root password in order to start using the database service. Use password RoboShop@1 or any other as per your choice.
#Password = RoboShop@1
echo -e "\e[33m**** Configuring the MYSQl root password. ****\e[0m" | tee -a ${log}
mysql_secure_installation --set-root-pass ${mysql_root_password}     &>> ${log}
func_exit_status

echo -e "\e[34m-----------Script Run Successfully-----------\e[0m"