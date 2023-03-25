#!/bin/bash

export DEBIAN_FRONTEND=noninteractive 
sudo apt update
sudo DEBIAN_FRONTEND=noninteractive apt install -y jq gobuster seclists remmina code-oss docker.io ffuf 
sudo DEBIAN_FRONTEND=noninteractive apt install -y sliver starkiller
sudo DEBIAN_FRONTEND=noninteractive apt install -y golang-go mingw-w64 rustc nim
sudo DEBIAN_FRONTEND=noninteractive apt install -y ghidra 

# TODO
# look into havoc jenkins build script, this post about jenkins automation https://blog.sunggwanchoi.com/half-automating-powersharppack/
# and powersharppack and sharpcollection for dyi automation of building and obfuscating the projects
# also take a look at offensivepipeline2

# add user to docker and virtualbox shared folder groups
sudo usermod -aG docker $USER
sudo usermod -aG vboxsf $USER

# install winim for ez windows API programming in nim 
nimble install -y winim

# install evilwinrm via gem
sudo gem install evil-winrm

# install python stuff via pip
pip3 install updog bloodhound pyinstaller pyarmor 
# needed for bloodhound-python see https://github.com/cannatag/ldap3/issues/1038
pip3 install pycryptodome

EXPORT_PATH="export PATH=/home/$USER/.local/bin"
if [[ -z $(grep -x $EXPORT_PATH:'$PATH' ~/.zshrc) ]]; then
    echo $EXPORT_PATH:'$PATH' >> ~/.zshrc
    $(echo $EXPORT_PATH:$PATH)
fi

# https://github.com/RustScan/RustScan
# install rustscan via cargo
cargo install rustscan 

EXPORT_PATH="export PATH=/home/$USER/.cargo/bin"
if [[ -z $(grep -x $EXPORT_PATH:'$PATH' ~/.zshrc) ]]; then
    echo $EXPORT_PATH:'$PATH' >> ~/.zshrc
    $(echo $EXPORT_PATH:$PATH)
fi

cd
mkdir Tools
cd Tools
#git clone https://github.com/optiv/ScareCrow
#git clone https://github.com/ropnop/kerbrute
#git clone https://github.com/blackhat-go/bhg
#git clone https://github.com/EONRaider/blackhat-python3
#git clone https://github.com/BishopFox/sliver
#git clone https://github.com/optiv/Freeze
git clone https://github.com/HavocFramework/Havoc
#git clone https://github.com/antonioCoco/ConPtyShell
#git clone https://github.com/Flangvik/SharpCollection
#git clone https://github.com/S3cur3Th1sSh1t/PowerSharpPack
#git clone https://github.com/S3cur3Th1sSh1t/WinPwn
#git clone https://github.com/byt3bl33d3r/OffensiveNim
#git clone https://github.com/zimawhit3/Bitmancer
#git clone https://github.com/trickster0/OffensiveRust
#git clone --recurse-submodules https://github.com/ajpc500/NimlineWhispers2
git clone https://github.com/chvancooten/NimPlant

cd 
mkdir knowledge
cd knowledge
#git clone https://github.com/mantvydasb/RedTeaming-Tactics-and-Techniques
#git clone https://github.com/ShutdownRepo/The-Hacker-Recipes
git clone https://github.com/carlospolop/hacktricks
#git clone https://github.com/carlospolop/hacktricks-cloud
#git clone https://github.com/swisskyrepo/PayloadsAllTheThings

#       Covenant
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~
#git clone --recurse-submodules https://github.com/cobbr/Covenant
#cd Covenant/Covenant
#docker build -t covenant .
# docker run -it -p 127.0.0.1:7443:7443 -p 80:80 -p 443:443 --name covenant -v /home/vagrant/Tools/Covenant/Covenant/Data:/app/Data covenant

#       assemblies
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~
#cd ~/Tools
#mkdir assemblies
#cd assemblies
# git clone Seatbelt
# sharphound
# pyhound
# winpeas

# setup neo4j for use with bloodhound
cd ~/Tools
mkdir -p neo4j/data
sudo docker run -d --name neo4j --env NEO4J_AUTH=neo4j/neo4j123 -p 127.0.0.1:7474:7474 -p 127.0.0.1:7687:7687 -v /home/$USER/Tools/neo4j/data:/data neo4j:latest

# wget https://github.com/BloodHoundAD/BloodHound/releases/latest/download/BloodHound-linux-x64.zip

cd 
mkdir www
cd www
# download files if they not already exist
DOWNLOAD_FILE=https://github.com/carlospolop/PEASS-ng/releases/latest/download/winPEAS.bat
if [[ ! -f $(echo $DOWNLOAD_FILE| awk -F '/' '{print $NF}') ]];then
    wget $DOWNLOAD_FILE
fi

DOWNLOAD_FILE=https://github.com/carlospolop/PEASS-ng/releases/latest/download/winPEASany.exe
if [[ ! -f $(echo $DOWNLOAD_FILE| awk -F '/' '{print $NF}') ]];then
    wget $DOWNLOAD_FILE
fi

DOWNLOAD_FILE=https://github.com/carlospolop/PEASS-ng/releases/latest/download/linpeas.sh
if [[ ! -f $(echo $DOWNLOAD_FILE| awk -F '/' '{print $NF}') ]];then
    wget $DOWNLOAD_FILE
fi

DOWNLOAD_FILE=https://raw.githubusercontent.com/411Hall/JAWS/master/jaws-enum.ps1
if [[ ! -f $(echo $DOWNLOAD_FILE| awk -F '/' '{print $NF}') ]];then
    wget $DOWNLOAD_FILE
fi


cd
# update 'locate' database
sudo updatedb
