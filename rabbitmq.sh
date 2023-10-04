# Change the hostname
#hostnamectl set-hostname rabbitmq
# Put  sleep for 5S so hostname fully propagate before running the next script.
#sleep 5

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
rabbitmqctl add_user roboshop roboshop123
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"

echo "-----------Script Run Successfully-----------"