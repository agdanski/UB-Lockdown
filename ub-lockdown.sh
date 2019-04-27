#!/bin/bash

change_root_pass(){
    rm "report.txt" 2> /dev/null
    sudo apt-get install pwgen
    password=$( pwgen 20 1 )
    echo "root:$password" | chpasswd
    echo "The root password is $password." >> report.txt
    echo "The new password for root is $password."
}

delete_logs(){
    rm "$HOME/.bash_history"
}

make_backup_user(){
    useradd 'backup'
    password=$( pwgen 20 1)
    echo "backup:$password" | chpasswd
    echo "A user has been created with the credentials: User: backup Password: $password" 
    echo "Backup user password is: $password." >> report.txt
    sudo usermod -aG sudo backup
}

disable_cron(){
    sudo /etc/init.d/crond stop
}

reinstall_packages(){
    sudo apt-get remove coreutils
    sudo apt-get remove net-tools
    sudo apt-get remove lsof
    sudo apt-get remove procps
    sudo apt-get remove build-essential
    sudo apt-get remove openssh-server
    sudo apt-get autoremove
    sudo apt-get install coreutils
    sudo apt-get install net-tools
    sudo apt-get install lsof
    sudo apt-get install procps
    sudo apt-get install build-essential
    sudo apt-get install openssh-server
}



setup_iptables(){
    sudo apt-get install iptables-persistent
    #flush iptables to remove current rules
    sudo iptables -F 
    #allow current and related packets
    sudo iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
    #allow loopback connections
    sudo iptables -I INPUT 1 -i lo -j ACCEPT
    #allow input from port 22 and 80.  we can add other services to this
    sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT
    sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT
    #not sure if i need this
    sudo iptables -A INPUT -p tcp --dport 443 -j ACCEPT
    #drop anything that isnt this stuff
    sudo iptables -A INPUT -j DROP
}

run_updates(){
    sudo apt-get update && sudo apt-get upgrade
}

echo "Changing root password"
change_root_pass
echo "making backup user"
make_backup_user
echo "disabling cron"
disable_cron
echo "reinstalling core packages"
reinstall_packages
echo "Setting up iptables"
setup_iptables
echo "running updates"
run_updates
echo "done"
echo "some info stored in report.txt"
