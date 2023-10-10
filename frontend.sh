# Variables.
log=/tmp/roboshop.log
component=nginx
proxy=nginx-proxy

cp $proxy.conf /etc/nginx/default.d/$proxy.conf
cp nginx-autorestart.service.conf /etc/systemd/system/nginx-autorestart.service

yum install -y nginx bash-completion

systemctl start $component
systemctl enable $component

rm -rf /usr/share/nginx/html/*
curl -os /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend.zip
unzip -o /tmp/frontend.zip -d /usr/share/nginx/html/  &>> ${log}


systemctl daemon-reload
systemctl enable nginx-autorestart.service
systemctl restart $component

# Repo URL "https://github.com/abhijeet4022/roboshop-shell.git"
#exec bash

echo -e "\e[33m-----------Script Run Successfully-----------\e[0m" | tee -a ${log}

