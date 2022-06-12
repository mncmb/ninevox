
sudo apt update
sudo apt install -y gobuster golang-go seclists remmina ghidra code-oss docker.io mingw-w64
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


# update locate database
sudo updatedb