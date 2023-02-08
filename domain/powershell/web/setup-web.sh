# cat /etc/netplan/00-installer-config.yaml
# heredoc https://stackoverflow.com/questions/23929235/multi-line-string-with-extra-space-preserved-indentation
# heredoc opens another subprocess, so sudo is tricky
# https://askubuntu.com/questions/1008571/how-can-i-configure-default-route-metric-with-dhcp-and-netplan
# metric lower than 100 is picked before metric 100
cat > /tmp/00-installer-config.yaml << EOM
network:
  version: 2
  renderer: networkd
  ethernets:
    enp0s3:
      dhcp4: true
    enp0s8:
      dhcp4: no
      addresses: [172.16.0.10/24]
      gateway4: 172.16.0.1
      nameservers:
       addresses: [172.16.0.1,8.8.8.8]
      routes:
        - to: 0.0.0.0/0
          via: 172.16.0.1
          metric: 50
EOM

sudo mv /tmp/00-installer-config.yaml /etc/netplan/00-installer-config.yaml
sudo netplan apply

#sudo ip route del default via 10.0.2.2
#sudo ip route del 10.0.2.0/24 dev enp0s3
cron_min='*/5 * * * * sudo ip route del default via 10.0.2.2'
cron_boot='@reboot sudo ip route del default via 10.0.2.2'
cron_entry=$(sudo crontab -l) 
if [[ "$cron_entry" != *"$cron_min"* ]]; then
  printf '%s\n' "$cron_entry" "$cron_min" "$cron_boot" | sudo crontab -
fi

cron_min='*/5 * * * * sudo ip route del 10.0.2.0/24 dev enp0s3'
cron_boot='@reboot sudo ip route del 10.0.2.0/24 dev enp0s3'
cron_entry=$(sudo crontab -l) 
if [[ "$cron_entry" != *"$cron_min"* ]]; then
  printf '%s\n' "$cron_entry" "$cron_min" "$cron_boot" | sudo crontab -
fi

# default via 172.16.0.1 dev enp0s8 proto static 
# default via 172.16.0.1 dev enp0s8 proto static metric 50
# default via 10.0.2.2 dev enp0s3 proto dhcp src 10.0.2.15 metric 100
# 10.0.2.0/24 dev enp0s3 proto kernel scope link src 10.0.2.15
# 10.0.2.2 dev enp0s3 proto dhcp scope link src 10.0.2.15 metric 100
# 172.16.0.0/24 dev enp0s8 proto kernel scope link src 172.16.0.10



# sudo apt update 
# sudo DEBIAN_FRONTEND=noninteractive apt install -y docker.io docker-compose
# ## setup crAPI
# # https://github.com/OWASP/crAPI
# 
# mkdir ~/crapi
# cd ~/crapi
# 
# curl -o docker-compose.yml https://raw.githubusercontent.com/OWASP/crAPI/main/deploy/docker/docker-compose.yml
# 
# sed -i docker-compose.yml \
#         -e "s/127.0.0.1:8888:80/80:80/" \
#         -e "s/127.0.0.1:8025:8025/8025:8025/"
# 
# docker-compose pull
# docker-compose -f docker-compose.yml --compatibility up -d