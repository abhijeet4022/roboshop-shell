rabbitmq_appuser_password=$1
if [ -z "${rabbitmq_appuser_password}" ]; then
  echo "\e[31mPlease: mention the password for RabbitMQ.\e[0m"
  exit 1
fi

# Configure YUM Repos from the script provided by vendor. this is dependency of rabbitmq
curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | bash

# Configure YUM Repos for RabbitMQ.
curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | bash

# Install RabbitMQ
dnf install rabbitmq-server bash-completion -y

# Start RabbitMQ Service
systemctl enable rabbitmq-server
systemctl restart rabbitmq-server

# RabbitMQ comes with a default username / password as guest/guest. But this user cannot be used to connect.
# Hence, we need to create one user for the application.
rabbitmqctl add_user roboshop ${rabbitmq_appuser_password}
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"

echo "-----------Script Run Successfully-----------"