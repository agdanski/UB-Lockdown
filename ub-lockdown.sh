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
    #crontab -l > cron_backup.txt
    #echo "Cron backup stored at cron_backup.txt"
    #crontab -r
    sudo /etc/init.d/crond stop

}

disable_scheduled_task(){
    # im assuming this is a windows thing
}

setup_iptables(){
    sudo iptables -A INPUT -i lo -j ACCEPT
    sudo iptables -A OUTPUT -o lo -j ACCEPT
    
}