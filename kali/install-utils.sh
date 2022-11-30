#!/bin/bash 
sudo apt update
sudo apt install -y jq gobuster golang-go seclists remmina ghidra code-oss docker.io mingw-w64
sudo apt install -y sliver 

echo TODO
# TODO
# add empire and starkiller
# add havoc 
# add ffuf 
# add rustscan


# add user to docker and virtualbox shared folder groups
sudo usermod -aG docker $USER
sudo usermod -aG vboxsf $USER

sudo gem install evil-winrm
pip3 install updog bloodhound pyinstaller pyarmor 
# needed for bloodhound-python see https://github.com/cannatag/ldap3/issues/1038
pip3 install pycryptodome
echo 'export PATH=/home/$USER/.local/bin:$PATH' >> ~/.zshrc
 
cd
mkdir Tools
cd Tools
git clone https://github.com/optiv/ScareCrow
git clone --recursive https://github.com/n1nj4sec/pupy
git clone https://github.com/ropnop/kerbrute
git clone https://github.com/carlospolop/PEASS-ng
git clone https://github.com/blackhat-go/bhg
git clone https://github.com/EONRaider/blackhat-python3

git clone --recurse-submodules https://github.com/cobbr/Covenant
cd Covenant/Covenant
docker build -t covenant .
# docker run -it -p 127.0.0.1:7443:7443 -p 80:80 -p 443:443 --name covenant -v /home/vagrant/Tools/Covenant/Covenant/Data:/app/Data covenant
cd ~/Tools
mkdir assemblies
cd assemblies
# git clone Seatbelt
# sharphound
# pyhound
# winpeas

# setup neo4j for use with bloodhound
cd ~/Tools
mkdir -p neo4j/data
docker run --name neo4j -p 127.0.0.1:7474:7474 -p 127.0.0.1:7687:7687 -v /home/$USER/Tools/neo4j/data:/data neo4j
wget https://github.com/BloodHoundAD/BloodHound/releases/latest/download/BloodHound-linux-x64.zip

cd ~/Public
wget https://github.com/carlospolop/PEASS-ng/releases/latest/download/winPEAS.bat
wget https://github.com/carlospolop/PEASS-ng/releases/latest/download/winPEASany.exe
wget https://github.com/carlospolop/PEASS-ng/releases/latest/download/linpeas.sh
wget https://raw.githubusercontent.com/411Hall/JAWS/master/jaws-enum.ps1

# update 'locate' database
sudo updatedb
