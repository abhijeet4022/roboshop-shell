# Log Variable.
    log=/tmp/roboshop.log
func_exit_status(){
  if [ $? -eq 0 ]; then
    echo -e "\e[32m Success \e[0m"
  else
    echo -e "\e[31m Failure \e[0m"
  fi
}

func_appprerequisite(){
    #We need to setup a new service in systemd so systemctl can manage this service
    ## Setup SystemD Shipping Service
    echo -e "\e[34m-->> Deleting The old service /etc/systemd/system/$component.service file.\e[0m" | tee -a ${log}
    rm -rf /etc/systemd/system/$component.service  &>> ${log}
    func_exit_status

    echo -e "\e[34m-->> Copying The $component.service to /etc/systemd/system/$component.service.\e[0m" | tee -a ${log}
    cp $component.service /etc/systemd/system/$component.service  &>> ${log}
    func_exit_status

    # Add application user
    echo -e "\e[34m-->> Creating Application User- roboshop.\e[0m" | tee -a ${log}
    id roboshop  &>> ${log}
    if [ $? -ne 0 ]; then
    useradd roboshop  &>> ${log}
    fi
    func_exit_status

    # Setup an app directory.
    echo -e "\e[34m-->> Removing the existing application directory.\e[0m" | tee -a ${log}
    rm -rf /app &>> ${log}
    func_exit_status

    echo -e "\e[34m-->> Creating Application Directory- /app.\e[0m" | tee -a ${log}
    mkdir /app  &>> ${log}
    func_exit_status

    # Download the application code to created app directory.
    echo -e "\e[34m-->> Downloading the Application code.\e[0m" | tee -a ${log}
    curl -o /tmp/$component.zip https://roboshop-artifacts.s3.amazonaws.com/$component.zip &>> ${log}
    func_exit_status

    echo -e "\e[34m-->> Extracting the Application code.\e[0m" | tee -a ${log}
    unzip -o /tmp/$component.zip -d /app/ &>> ${log}
    func_exit_status

    echo -e "\e[35m**** func_appprerequisite Function Completed****\e[0m" | tee -a ${log}
    func_exit_status
}



func_systemd() {
    # Load the service.
    #This command is because we added a new service, We are telling systemd to reload so it will detect new service.
    echo -e "\e[34m-->> Starting & Enabling the $component service.\e[0m" | tee -a ${log}
    systemctl daemon-reload  &>> ${log}
    # Start & Enable the service.
    systemctl enable $component  &>> ${log}
    systemctl restart $component  &>> ${log}
    func_exit_status

    echo -e "\e[35m**** func_systemd Function Completed****\e[0m" | tee -a ${log}
}




func_schema_setup(){
   #For the application to work fully functional we need to load schema to the Database.
   #Schemas will push the user information and application data to the database

  if [ "${schema_type}" == "mongodb" ]; then

  echo -e "\e[34m-->> Configuring the repo for mongodb.\e[0m" | tee -a ${log}
  cp mongo.repo /etc/yum.repos.d/mongo.repo  &>> ${log}
  func_exit_status

  echo -e "\e[34m-->> Installing the mongodb-org-shell package.\e[0m" | tee -a ${log}
  dnf install mongodb-org-shell -y  &>> ${log}
  func_exit_status

  #Load Schema
  echo -e "\e[34m-->> Loading the mongodb schema.\e[0m" | tee -a ${log}
  mongo --host mongodb.learntechnology.tech </app/schema/$component.js  &>> ${log}
  func_exit_status

  fi


  if [ "${schema_type}" == "mysql" ]; then

  echo -e "\e[34m-->> Installing the MYSQL client.\e[0m" | tee -a ${log}
  dnf install mysql -y   &>> ${log}
  func_exit_status

  echo -e "\e[34m-->> Loading the schema.\e[0m" | tee -a ${log}
  mysql -h mysql.learntechnology.tech -uroot -pRoboShop@1 </app/schema/$component.sql   &>> ${log}
  func_exit_status

  fi

  echo -e "\e[35m**** func_schema_setup Function Completed****\e[0m" | tee -a ${log}
}


#Catalogue, User & Cart Service
func_nodejs(){

  # Configuring repo to download nodejs NodeJS>=18
  echo -e "\e[34m-->> Configuring the repo for NodeJS.\e[0m" | tee -a ${log}
  curl -sL https://rpm.nodesource.com/setup_lts.x | bash  &>> ${log}
  func_exit_status

  echo -e "\e[34m-->> Installing NodeJS & bash-completion package.\e[0m" | tee -a ${log}
  yum install -y bash-completion nodejs  &>> ${log}
  func_exit_status

  # Calling the function
  echo -e "\e[35m**** Calling the func_appprerequisite function.****\e[0m" | tee -a ${log}
  func_appprerequisite



  # Every application is developed by development team will have some common software's that they use as libraries. This application also have the same way of defined dependencies in the application configuration.
  #Lets download the dependencies.
  echo -e "\e[34m-->> Installing the dependencies for the Application- /app/package.json.\e[0m" | tee -a ${log}
  npm install -C /app/  &>> ${log} # We can install dependency without navigate to that directory.
  func_exit_status

  # Calling the function
  echo -e "\e[35m**** Calling the func_schema_setup function to setup mongodb.****\e[0m" | tee -a ${log}
  func_schema_setup


  #Need to update catalogue server ip address in frontend configuration.
  # Configuration file is /etc/nginx/default.d/roboshop.conf



  # Calling the function
  echo -e "\e[35m**** Calling the func_systemd function.****\e[0m" | tee -a ${log}
  func_systemd

  echo -e "\e[33m-----------Script Run Successfully-----------\e[0m" | tee -a ${log}
}



#Shipping Service
func_java(){

  #Shipping service is responsible for finding the distance of the package to be shipped and calculate the price based on that.
  #Shipping service is written in Java, Hence we need to install Java.
  #Maven is a build or Java Packaging software, Hence we are going to install maven.
  #Developer has chosen Maven, Check with developer which version of Maven is needed. Here for our requirement java >= 1.8 & maven >=3.5 should work.

  echo -e "\e[34m-->> Installing the MAVAN package.\e[0m" | tee -a ${log}
  dnf install maven bash-completion -y  &>> ${log}
  func_exit_status

  #Calling the function.
  echo -e "\e[35m**** Calling the func_appprerequisite function.****\e[0m" | tee -a ${log}
  func_appprerequisite


  #Every application is developed by development team will have some common software's that they use as libraries.
  # This application also have the same way of defined dependencies in the application configuration.
  #Lets download the dependencies & build the application
  echo -e "\e[34m-->> Building the $component service.\e[0m" | tee -a ${log}
  mvn clean package -f /app/pom.xml  &>> ${log}
  mv /app/target/$component-1.0.jar /app/$component.jar  &>> ${log}
  func_exit_status

  # Calling the function
  echo -e "\e[35m**** Calling the func_schema_setup function to setup MYSQL.****\e[0m" | tee -a ${log}
  func_schema_setup


  # Calling the function
  echo -e "\e[35m**** Calling the func_systemd function.****\e[0m" | tee -a ${log}
  func_systemd


  echo -e "\e[33m-----------Script Run Successfully-----------\e[0m" | tee -a ${log}
}



#Payment Service
func_python(){

  # Developer has chosen Python, Check with developer which version of Python is needed.
  # Install Python 3.6
  echo -e "\e[34m-->> Installing the Python package.\e[0m" | tee -a ${log}
  dnf install python36 gcc python3-devel bash-completion -y   &>> ${log}
  func_exit_status

  #Calling the function.
  echo -e "\e[35m**** Calling the func_appprerequisite function.****\e[0m" | tee -a ${log}
  func_appprerequisite

  sed -i "s/rabbitmq_appuser_password/${rabbitmq_appuser_password}/" /etc/systemd/system/${component}.service


  # Every application is developed by development team will have some common software's that they use as libraries.
  # This application also have the same way of defined dependencies in the application configuration.
  # Lets download the dependencies.

  echo -e "\e[34m-->> Building the $component service.\e[0m" | tee -a ${log}
  pip3.6 install -r /app/requirements.txt &>> ${log}
  func_exit_status

  echo -e "\e[35m**** Calling the func_systemd function.****\e[0m" | tee -a ${log}
  func_systemd


  echo -e "\e[33m-----------Script Run Successfully-----------\e[0m" | tee -a ${log}
}


#Dispatch Service
func_golang(){

  #Developer has chosen GoLang, Check with developer which version of GoLang is needed.
  #Install GoLang
  echo -e "\e[34m-->> Installing the golang package.\e[0m" | tee -a ${log}
  dnf install bash-completion golang -y  &>> ${log}
  func_exit_status

  #Calling the function.
  echo -e "\e[35m**** Calling the func_appprerequisite function.****\e[0m" | tee -a ${log}
  func_appprerequisite
  func_exit_status

  #Every application is developed by development team will have some common software's that they use as libraries.
  # This application also have the same way of defined dependencies in the application configuration.
  #Lets download the dependencies & build the software.
  echo -e "\e[34m-->> Building the Application Package.\e[0m" | tee -a ${log}
  cd /app  &>> ${log} # From outside we can't run these command so need to navigate to that directory
  # if first command fail then it will exit || means or operator
  go mod init dispatch   &>> ${log} #dispatch is the module name we can change it but we have to modify in config file also
  go get  &>> ${log}
  go build  &>> ${log}
  func_exit_status

  echo -e "\e[35m**** Calling the func_systemd function.****\e[0m" | tee -a ${log}
  func_systemd


  echo -e "\e[33m-----------Script Run Successfully-----------\e[0m" | tee -a ${log}
}
