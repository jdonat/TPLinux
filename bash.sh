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
	cp ./template.conf /etc/nginx/sites-available/$1
 	export HTTP_PORT =$2
  	export SITE_NAME = $1
	envsubst < /etc/nginx/sites-available/$1
}

function get_template_config() {
	cp /etc/nginx/sites-available/default ./template.conf
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
	*)
	echo -e "Erreur : le 1er parametre passé au script doit être ∕nuser pour crer un nouvel utilisateur∕nou install pour mettre a jour les repositories et installer nginx"
	;;
esac

