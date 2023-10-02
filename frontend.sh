hostnamectl set-hostname frontend
yum install -y bash-completion
yum install nginx
systemctl start nginx
systemctl enable nginx
rm -rf /usr/share/nginx/html/*
curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend.zip
unzip -o /tmp/frontend.zip -d /usr/share/nginx/html/
systemctl restart nginx

