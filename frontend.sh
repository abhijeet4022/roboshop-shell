source common.sh
# Variables.
component=nginx
proxy=nginx-proxy

echo -e "\e[34m-->> Installing NGINX web-server\e[0m" | tee -a ${log}
yum install -y nginx bash-completion &>> ${log}
func_exit_status

echo -e "\e[34m-->> Configuring the nginx reverse-proxy .\e[0m" | tee -a ${log}
rm -rf /etc/nginx/default.d/$proxy.conf &>> ${log}
cp $proxy.conf /etc/nginx/default.d/$proxy.conf &>> ${log}
cp nginx-autorestart.service.conf /etc/systemd/system/nginx-autorestart.service &>> ${log}
func_exit_status



echo -e "\e[34m-->> Removing the existing Web-Server files.\e[0m" | tee -a ${log}
rm -rf /usr/share/nginx/html/* &>> ${log}
func_exit_status

echo -e "\e[34m-->> Downloading the  Web-Server content.\e[0m" | tee -a ${log}
curl -s -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend.zip &>> ${log}
func_exit_status

echo -e "\e[34m-->> Extracting the  Web-Server content.\e[0m" | tee -a ${log}
unzip -o /tmp/frontend.zip -d /usr/share/nginx/html/  &>> ${log}
func_exit_status

echo -e "\e[34m-->> Starting & Enabling the $component service \e[0m\n" | tee -a ${log}
systemctl daemon-reload  &>> ${log}
systemctl enable nginx-autorestart.service &>> ${log}
systemctl restart $component &>> ${log}
systemctl enable $component &>> ${log}
func_exit_status

# Repo URL "https://github.com/abhijeet4022/roboshop-shell.git"
#exec bash

echo -e "\e[33m-----------Script Run Successfully-----------\e[0m" | tee -a ${log}

