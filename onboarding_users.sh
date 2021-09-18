#!/bin/bash

sudo groupadd developer

nameList=$(cat ./names.csv)
groupName="developer"

user_Check(){
if [ $(id -u "$1" 2> /dev/null) ]
then
	echo "User $1 does exist"
	ssh_setup $1
else
	echo "User $1 does NOT exist"
	echo "Creating $1"
	user_create $1
	ssh_setup $1
fi
}

user_create(){
sudo useradd -m $1 -p $1
sudo usermod -g $groupName $1
}

#For Testing
user_delete(){
sudo userdel $1
sudo groupdel $1
sudo rm -r /home/$1
}

ssh_setup(){
if [ ! -d "/home/$1/.ssh" ]; then
  echo ".ssh does not exists."
  echo "Doing .ssh setup for user $1"
  #sudo mkdir /home/$1/.ssh
  #sudo cp /home/$USER/.ssh/authorized_keys /home/$1/.ssh/authorized_keys
  sudo cp -r /home/$USER/.ssh /home/$1/.ssh
  sudo chown $1 /home/$1/.ssh
  sudo chown $1 /home/$1/.ssh/authorized_keys
fi
}

#Looping through names
for name in $nameList
do
	user_Check $name
	#user_delete $name
done 
