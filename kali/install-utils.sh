
sudo apt update
sudo apt install -y gobuster golang-go seclists remmina ghidra code-oss docker.io mingw-w64 #neo4j bloodhound
sudo usermod -aG docker $(whoami)

sudo gem install evil-winrm
pip3 install updog
 
cd
mkdir Tools
cd Tools
git clone https://github.com/optiv/ScareCrow
git clone https://github.com/BishopFox/sliver
git clone --recursive https://github.com/n1nj4sec/pupy
git clone https://github.com/ropnop/kerbrute
git clone https://github.com/carlospolop/PEASS-ng
git clone https://github.com/blackhat-go/bhg
git clone https://github.com/EONRaider/blackhat-python3

git clone --recurse-submodules https://github.com/cobbr/Covenant
cd Covenant/Covenant
docker build -t covenant .
# docker run -it -p 127.0.0.1:7443:7443 -p 80:80 -p 443:443 --name covenant -v /home/vagrant/Tools/Covenant/Covenant/Data:/app/Data covenant

# setup neo4j for use with bloodhound
cd ../..
mkdir -p neo4j/data
docker run -p 127.0.0.1:7474:7474 -p 127.0.0.1:7687:7687 -v neo4j/data:/data neo4j
wget https://github.com/BloodHoundAD/BloodHound/releases/latest/download/BloodHound-linux-x64.zip

wget https://github.com/carlospolop/PEASS-ng/releases/latest/download/winPEAS.bat
wget https://github.com/carlospolop/PEASS-ng/releases/latest/download/linpeas.sh

# update locate database
sudo updatedb