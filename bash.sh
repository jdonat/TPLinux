#!/bin/bash

mode=$1
username=$2
password=$3
site=$username

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
	cp /etc/nginx/sites-available/default /etc/nginx/sites-available/$1
}

case $mode in
	"user")
	createUser $username $password
	;;

	"install")
	updateRepo
	;;
	"configure_site")
	config_site $site
	;;
	*)
	echo -e "Erreur : le 1er parametre passé au script doit être ∕nuser pour crer un nouvel utilisateur∕nou install pour mettre a jour les repositories et installer nginx"
	;;
esac

