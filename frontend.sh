#hostnamectl set-hostname frontend
#sleep 10
yum install -y nginx bash-completion
systemctl start nginx
systemctl enable nginx
rm -rf /usr/share/nginx/html/*
curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend.zip
unzip -o /tmp/frontend.zip -d /usr/share/nginx/html/
cp nginx-proxy.conf /etc/nginx/default.d/nginx-proxy.conf
systemctl restart nginx

# Repo URL "https://github.com/abhijeet4022/roboshop-shell.git"
#exec bash

