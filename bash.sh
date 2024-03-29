#!/bin/bash

function createUser() {
	echo "user: $1 created with password: $2"
	useradd -p "$2" "$1"
}

function updateRepo(){
	apt update
	apt upgrade
	apt autoremove
	apt autoclean
	apt install nginx
}

function config_site(){
	cp ./template.conf /etc/nginx/sites-available/$1.conf
	chmod 777 /etc/nginx/sites-available/$1.conf
  	sed -i "s/HTTP_PORT/$2/g" /etc/nginx/sites-available/$1.conf
  	sed -i "s/SITE_NAME/$1/g" /etc/nginx/sites-available/$1.conf
	#cat /etc/nginx/sites-available/$1.conf
	chmod 644 /etc/nginx/sites-available/$1.conf

	if [ -d "/var/www/$1" ]; then
		echo "Le dossier /var/www/$1 existe deja"
	else
		mkdir /var/www/$1;
		echo "Dossier cree : /var/www/$1"
	fi
	
	cp ./index.html /var/www/$1/index.html
	chmod 777 /var/www/$1/index.html
	sed -i "s/SITE_NAME/$1/g" /var/www/$1/index.html
	chmod 644 /var/www/$1/index.html
	#cat /var/www/$1/index.html
}
#df

function get_template_config() {
	cp /etc/nginx/sites-available/default ./template.conf
}

function activate_site() {
	if [ -f "/etc/nginx/sites-available/$1.conf" ]; then
		ln -s /etc/nginx/sites-available/$1.conf /etc/nginx/sites-enabled/$1.conf;
		#servive nginx restart;
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
	#(crontab -l 2>/dev/null; echo "*/5 * * * * echo 'helloworld' >> /home/johndoe/Bureau/TP/helloworld.txt") | crontab -
	
	echo -e "*/5 * * * * echo 'helloworld' >> /home/johndoe/Bureau/TP/helloworld.txt\n* */1 * * * bash /home/johndoe/Bureau/TP/disk_monitor.sh" > cronfile.txt
	chmod 777 cronfile.txt
	crontab cronfile.txt
	echo $?
	/etc/init.d/cron restart
	#cat cronfile.txt
	
	
	#{ crontab -l; echo "*/5 * * * * echo 'helloworld' >> /home/johndoe/Bureau/TP/helloworld.txt"; } | crontab -
	#{ crontab -l; echo "* */1 * * * bash /home/johndoe/Bureau/TP/disk_monitor.sh"; } | crontab -
	
	#crontab -l|sed "\$a* */1 * * * bash /home/johndoe/Bureau/TP/disk_monitor.sh"|crontab -
}

case $1 in
	"user")
	createUser $username $password
	;;
	"install")
	updateRepo
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
	*)
	echo -e "Erreur : le 1er parametre passé au script doit être ∕nuser pour crer un nouvel utilisateur∕nou install pour mettre a jour les repositories et installer nginx\nconfigure_site pour la config de defaut d un site\ntemplate pour recuperer dans le dossier courant un template de config pour nginx"
	;;
esac

