rabbitmq_appuser_password=$1
if [ -z "${rabbitmq_appuser_password}" ]; then
  echo -e "\e[31mPlease: Mention the password for RabbitMQ.\e[0m"
  exit 1
fi

source common.sh


# Configure YUM Repos from the script provided by vendor. this is dependency of rabbitmq
echo -e "\e[33m**** Configuring the erlang repository. ****\e[0m" | tee -a ${log}
curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | bash  &>> ${log}
func_exit_status

# Configure YUM Repos for RabbitMQ.
echo -e "\e[33m**** Configuring the RabbitMQ repository. ****\e[0m" | tee -a ${log}
curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | bash  &>> ${log}
func_exit_status

# Install RabbitMQ
echo -e "\e[33m**** Installing the rabbitmq-server package. ****\e[0m" | tee -a ${log}
dnf install rabbitmq-server bash-completion -y  &>> ${log}
func_exit_status

# Start RabbitMQ Service
echo -e "\e[33m**** Starting & Enabling the rabbitmq-server service . ****\e[0m" | tee -a ${log}
systemctl enable rabbitmq-server  &>> ${log}
systemctl restart rabbitmq-server  &>> ${log}
func_exit_status

# RabbitMQ comes with a default username / password as guest/guest. But this user cannot be used to connect.
# Hence, we need to create one user for the application.
echo -e "\e[33m**** Configuring the RabbitMQ User/Pass . ****\e[0m" | tee -a ${log}
rabbitmqctl add_user roboshop ${rabbitmq_appuser_password}  &>> ${log}
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"   &>> ${log}
func_exit_status

echo "-----------Script Run Successfully-----------"