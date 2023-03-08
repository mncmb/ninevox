sudo apt-get update

sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    jq git

sudo mkdir -m 0755 -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudo docker run hello-world

git clone https://github.com/peasead/elastic-container
cd elastic-container

sudo usermod -aG docker vagrant     # add vagrant to docker group

sed -i 's/changeme/"Passw0rd!"/g' .env
sed -i 's/WindowsDR=0/WindowsDR=1/g' .env
sed -i 's/MEM_LIMIT=.*/MEM_LIMIT=6073741824/g' .env
sudo ./elastic-container.sh start