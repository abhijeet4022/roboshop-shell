#Declareing the variable.
component=payment

#Linked/Export with Source file.
source common.sh

rabbitmq_appuser_password=$1
if [ -z "${rabbitmq_appuser_password}" ]; then
  echo -e "\e[31mInput: RabbitMQ AppUser password is missing.\e[0m"
  exit 1
fi
#this will call the func_python function from common.sh file.
func_python



