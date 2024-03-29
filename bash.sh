#!/bin/bash

if [ "$EUID" -ne 0 ]; then
	echo "Run as root";
	exit
fi

function createUser() {
	useradd -p "$2" "$1"
	echo "user: $1 created with password: $2"
}

function installation(){
	apt -y update
	apt -y upgrade
	apt -y autoremove
	apt -y autoclean
	apt -y install nginx
	apt -y install php8.1-fpm
	database="dbTest"
	table="tableTest"
	create_mysql_db $database $table
}

function config_site(){
	
	if [ -f "/etc/nginx/sites-available/$1.conf" ]; then
		echo "La configuration existe deja"
		exit
	else
		if [ "$3" = "php" ]; then
			cp ./template_php.conf /etc/nginx/sites-available/$1.conf
		else
			cp ./template.conf /etc/nginx/sites-available/$1.conf
		fi
		
		chmod 777 /etc/nginx/sites-available/$1.conf
	  	sed -i "s/HTTP_PORT/$2/g" /etc/nginx/sites-available/$1.conf
	  	sed -i "s/SITE_NAME/$1/g" /etc/nginx/sites-available/$1.conf
		chmod 644 /etc/nginx/sites-available/$1.conf
	fi
	if [ -d "/var/www/$1" ]; then
		echo "Le dossier /var/www/$1 existe deja"
	else
		mkdir /var/www/$1;
		echo "Dossier cree : /var/www/$1"
	fi
	
	if [ -f "/var/www/$1/index.html" ]; then
		echo "L index existe deja"
		exit
	else
		if [ "$3" = "php" ]; then
			cp ./index.php /var/www/$1/index.php
			chmod 777 /var/www/$1/index.php
			sed -i "s/SITE_NAME/$1/g" /var/www/$1/index.php
			chmod 644 /var/www/$1/index.php
		else
			cp ./index.html /var/www/$1/index.html
			chmod 777 /var/www/$1/index.html
			sed -i "s/SITE_NAME/$1/g" /var/www/$1/index.html
			chmod 644 /var/www/$1/index.html
		fi
	fi
}

function get_template_config() {
	cp /etc/nginx/sites-available/default ./template.conf
}

function activate_site() {
	if [ -f "/etc/nginx/sites-available/$1.conf" ]; then
		ln -s /etc/nginx/sites-available/$1.conf /etc/nginx/sites-enabled/$1.conf;
		service nginx reload;
		nginx -t
		if [ "$?" != 0 ]; then
			echo "Configuration de nginx incorrecte"
		fi
	else
		echo "Aucune config n est presente"
	fi
}

function add_cron() {
	echo -e "*/5 * * * * echo 'helloworld' >> /home/johndoe/Bureau/TP/helloworld.txt\n* */1 * * * bash /home/johndoe/Bureau/TP/disk_monitor.sh" > cronfile.txt
	chmod 777 cronfile.txt
	crontab cronfile.txt
	rm cronfile.txt
	/etc/init.d/cron restart
}

function generate_ssh() {
	ssh-keygen -t rsa -b 4096 -N "My secret passphrase" -f mykey
}

function configure_php_site() {
	config_site $1 $2 php
}

function delete_site() {
	rm -r /etc/nginx/sites-available/$1.conf /etc/nginx/sites-enabled/$1.conf /var/www/$1
}

case $1 in
	"user")
	createUser $username $password
	;;
	"install")
	installation
	;;
	"configure_site")
	config_site $2 $3
	;;
 	"template")
  	get_template_config
   	;;
   	"active_site")
   	activate_site $2
   	;;
   	"add_cronjob")
   	add_cron
   	;;
   	"generate_ssh")
   	generate_ssh
   	;;
   	"configure_php_site")
   	configure_php_site $2 $3
   	;;
   	"delete_site")
   	delete_site $2
   	;;
	*)
	echo -e "Erreur : Le 1er parametre doit etre user, install, configure_site, template, active_site, add_cronjob, generate_ssh, configure_php_site"
	;;
esac

