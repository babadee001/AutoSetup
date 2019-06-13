#!/bin/bash
echo ' ####################################### Starting script... #########################################'
echo 'Enter your instance public IP'
read ip
echo 'Enter your server name like this ===> example.com'
read serverName

nodeSetup(){
    echo '############################### Settting up Node Environment ################################'
    curl -sL https://deb.nodesource.com/setup_8.x -o nodesource_setup.sh
    sudo bash nodesource_setup.sh
    sudo apt-get install nodejs -y
    sudo npm install babel-cli -g
}

nginxSetup(){
    echo '############################## Setting up pm2, nginx and getting the repo ########################################'
    sudo npm install pm2 -g -y
    if [ -d DevOps-AWS-Intro ]; then
        echo '####################### Removing existing folder ######################'
        sudo rm -rf DevOps-AWS-Intro
    fi
    git clone https://github.com/babadee001/DevOps-AWS-Intro
    sudo apt-get install nginx
    sudo /etc/init.d/nginx start
    
    if [ -d /etc/nginx/sites-enabled/HelloBooks ]; then
        echo ' ######################## Removing existing config for app ##############################'
        sudo rm -rf /etc/nginx/sites-available/HelloBooks
        sudo rm -rf /etc/nginx/sites-enabled/HelloBooks
    fi

    sudo bash -c 'cat > /etc/nginx/sites-available/HelloBooks <<EOF
    server {
            listen 80;
            server_name '$serverName' 'www.$serverName';
            location / {
                    proxy_pass 'http://$ip:8000';
            }
    }'
    sudo ln -s /etc/nginx/sites-available/HelloBooks /etc/nginx/sites-enabled/HelloBooks
    sudo service nginx restart
}

installDep(){
    echo '######################### Installing App Dependencies ##################################'
    cd DevOps-AWS-Intro
    sudo npm install --unsafe-perm
}


startPm2() {
    echo '############################### Starting App with pm2 ###############################'
     pm2 kill
     pm2 startOrRestart ecosystem.config.js
}

main(){
    nodeSetup
    nginxSetup
    installDep
    startPm2
}
main
