# Log Variable.
    log=/tmp/roboshop.log


func_appprerequisite(){
    # Add application user
    echo -e "\e[34m-->> Creating Application User- roboshop.\e[0m" | tee -a ${log}
    useradd roboshop  &>> ${log}

    # Setup an app directory.
    echo -e "\e[34m-->> Removing the existing application directory.\e[0m" | tee -a ${log}
    rm -rf /app &>> ${log}

    echo -e "\e[34m-->> Creating Application Directory- /app.\e[0m" | tee -a ${log}
    mkdir /app  &>> ${log}

    # Download the application code to created app directory.
    echo -e "\e[34m-->> Downloading the Application code.\e[0m" | tee -a ${log}
    curl -o /tmp/$component.zip https://roboshop-artifacts.s3.amazonaws.com/$component.zip &>> ${log}

    echo -e "\e[34m-->> Extracting the Application code.\e[0m" | tee -a ${log}
    unzip -o /tmp/$component.zip -d /app/ &>> ${log}
}



func_systemd() {
    # Load the service.
    #This command is because we added a new service, We are telling systemd to reload so it will detect new service.
    echo -e "\e[34m-->> Starting & Enabling the $component service.\e[0m" | tee -a ${log}
    systemctl daemon-reload  &>> ${log}

    # Start & Enable the service.
    systemctl enable $component  &>> ${log}
    systemctl restart $component  &>> ${log}
}



func_nodejs(){
  # We need to setup a service in systemd so systemctl can manage this service.
  # Setup SystemD $component Service.
  # Ensure you replace <MONGODB-SERVER-IPADDRESS> with IP address

  echo -e "\e[34m-->> Deleting The old service file  /etc/systemd/system/$component.service file.\e[0m" | tee -a ${log}
  rm -rf /etc/systemd/system/$component.service &>> ${log}

  echo -e "\e[34m-->> Copying The $component.service to /etc/systemd/system/$component.service.\e[0m" | tee -a ${log}
  cp $component.service /etc/systemd/system/$component.service  &>> ${log}

  #Change the hostname
  #hostnamectl set-hostname $component
  #Put  sleep for 5S so hostname fully propagate before running the next script.
  #sleep 5

  # Configuring repo to download nodejs NodeJS>=18
  echo -e "\e[34m-->> Configuring the repo for NodeJS.\e[0m" | tee -a ${log}
  curl -sL https://rpm.nodesource.com/setup_lts.x | bash  &>> ${log}

  echo -e "\e[34m-->> Installing NodeJS & bash-completion package.\e[0m" | tee -a ${log}
  yum install -y bash-completion nodejs  &>> ${log}

  # Calling the function
  echo -e "\e[34m-->> Calling the func_appprerequisite function.\e[0m" | tee -a ${log}
  func_appprerequisite


  # Every application is developed by development team will have some common software's that they use as libraries. This application also have the same way of defined dependencies in the application configuration.
  #Lets download the dependencies.
  echo -e "\e[34m-->> Installing the dependencies for the Application- /app/package.json.\e[0m" | tee -a ${log}
  npm install -C /app/  &>> ${log} # We can install dependency without navigate to that directory.


  #For the application to work fully functional we need to load schema to the Database.
  #Schemas are usually part of application code and developer will provide them as part of development.
  #We need to load the schema. To load schema we need to install mongodb client.
  #To have it installed we can setup MongoDB repo and install mongodb-client.

  echo -e "\e[34m-->> Configuring the repo for mongodb.\e[0m" | tee -a ${log}
  cp mongo.repo /etc/yum.repos.d/mongo.repo  &>> ${log}

  echo -e "\e[34m-->> Installing the mongodb-org-shell package.\e[0m" | tee -a ${log}
  dnf install mongodb-org-shell -y  &>> ${log}

  #Load Schema
  echo -e "\e[34m-->> Loading the mongodb schema.\e[0m" | tee -a ${log}
  mongo --host mongodb.learntechnology.tech </app/schema/$component.js  &>> ${log}

  #Need to update $component server ip address in frontend configuration.
  # Configuration file is /etc/nginx/default.d/roboshop.conf



  # Calling the function
  echo -e "\e[34m-->> Calling the func_systemd function.\e[0m" | tee -a ${log}
  func_systemd

  echo -e "\e[33m-----------Script Run Successfully-----------\e[0m" | tee -a ${log}
}




func_java(){
  #We need to setup a new service in systemd so systemctl can manage this service
  # Setup SystemD Shipping Service
  echo -e "\e[34m-->> Deleting The old service file  /etc/systemd/system/$component.service file.\e[0m" | tee -a ${log}
  rm -rf /etc/systemd/system/$component.service  &>> ${log}

  echo -e "\e[34m-->> Copying The $component.service to /etc/systemd/system/$component.service.\e[0m" | tee -a ${log}
  cp $component.service /etc/systemd/system/$component.service  &>> ${log}

  # Change the hostname
  #hostnamectl set-hostname shipping
  # Put  sleep for 5S so hostname fully propagate before running the next script.
  # sleep 5

  #Shipping service is responsible for finding the distance of the package to be shipped and calculate the price based on that.
  #Shipping service is written in Java, Hence we need to install Java.
  #Maven is a build or Java Packaging software, Hence we are going to install maven.
  #Developer has chosen Maven, Check with developer which version of Maven is needed. Here for our requirement java >= 1.8 & maven >=3.5 should work.

  echo -e "\e[34m-->> Installing the MAVAN package.\e[0m" | tee -a ${log}
  dnf install maven bash-completion -y  &>> ${log}

  #Calling the function.
  echo -e "\e[34m-->> Calling the func_appprerequisite function.\e[0m" | tee -a ${log}
  func_appprerequisite

  #Every application is developed by development team will have some common software's that they use as libraries.
  # This application also have the same way of defined dependencies in the application configuration.
  #Lets download the dependencies & build the application
  echo -e "\e[34m-->> Building the $component service.\e[0m" | tee -a ${log}
  mvn clean package -f /app/pom.xml  &>> ${log}
  mv /app/target/$component-1.0.jar /app/$component.jar  &>> ${log}


  # For this application to work fully functional we need to load schema to the Database.
  # To load schema we need to install mysql client.
  # To have it installed we can use
  echo -e "\e[34m-->> Installing the MYSQL client.\e[0m" | tee -a ${log}
  dnf install mysql -y   &>> ${log}

  echo -e "\e[34m-->> Loading the schema.\e[0m" | tee -a ${log}
  mysql -h mysql.learntechnology.tech -uroot -pRoboShop@1 </app/schema/$component.sql   &>> ${log}

  # Calling the function
  echo -e "\e[34m-->> --->> Calling the func_systemd function.\e[0m" | tee -a ${log}
  func_systemd

  echo -e "\e[33m-----------Script Run Successfully-----------\e[0m" | tee -a ${log}
}