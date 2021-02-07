#!/bin/bash
apt update
DEBIAN_FRONTEND=noninteractive apt install -y seclists powershell-empire starkiller gobuster

# install vscode
apt install curl gpg software-properties-common apt-transport-https 
curl -sSL https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" | sudo tee /etc/apt/sources.list.d/vscode.list
DEBIAN_FRONTEND=noninteractive apt install -y code

## kali 2020.4 doesn't want to run xrdp atleast not with a non root user
## if you still want xrdp, you might activate the block and set a password for root

	#apt-get install -y xrdp
	#apt install -y virtualbox-guest-x11
	#systemctl enable xrdp
	#echo xfce4-session >~/.xsession
	#sudo sed -i 's/console/anyone/g' /etc/X11/Xwrapper.config
	#service xrdp restart
	
	
# set keyboard layout to ger
sed -i 's/KBLAYOUT="us"/KBLAYOUT="de"/g' /etc/default/keyboard
#DEBIAN_FRONTEND=noninteractive apt -y upgrade

# create default user kali with password kali 
# and change hostname to something that sounds less alerting
# you should change password after first login
USER_NAME=kali
HOST_NAME="Carla-PC"
sudo adduser $USER_NAME --disabled-password --gecos ""
echo $USER_NAME:$USER_NAME | sudo chpasswd
sudo adduser $USER_NAME sudo
hostnamectl set-hostname $HOSTNAME

cp /home/setup/user_setup.sh /home/$USER_NAME/user_setup.sh
chmod ugo+x /home/$USER_NAME/user_setup.sh
# switch to kali user and execute the following setup in the new context
su $USER_NAME -c /home/$USER_NAME/user_setup.sh
rm -rf /home/$USER_NAME/user_setup.sh
