#!/bin/bash

change_root_pass(){
    password = $( pwgen 20 1 )
    echo "$password" | passwd --stdin root
    echo "The new password for root is $password."
}

delete_logs(){
    rm "$HOME/.bash_history"
}

make_backup_user(){
    useradd 'backup'
    password = $( pwgen 20 1)
    chpasswd 'backup' "$password"
    echo "A user has been created with the credentials: User: backup Password: $password" 
    usermod -aG sudo backup
}

disable_cron(){
    sudo /etc/init.d/crond stop
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
echo "Setting up iptables"
setup_iptables
echo "running updates"
run_updates
echo "done"