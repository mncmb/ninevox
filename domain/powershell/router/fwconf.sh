# based on this https://kifarunix.com/configure-ubuntu-20-04-as-linux-router/

# cat /etc/netplan/00-installer-config.yaml
# heredoc https://stackoverflow.com/questions/23929235/multi-line-string-with-extra-space-preserved-indentation
# heredoc opens another subprocess, so sudo is tricky
cat > /tmp/00-installer-config.yaml << EOM
network:
  version: 2
  renderer: networkd
  ethernets:
    enp0s3:
      dhcp4: yes
    enp0s8:
      dhcp4: no
      addresses: [172.16.0.1/24]
    enp0s9:
      dhcp4: no
      addresses: [10.10.100.1/24]
EOM

sudo mv /tmp/00-installer-config.yaml /etc/netplan/00-installer-config.yaml

# sudo reboot
################################

sudo sed -i '/net.ipv4.ip_forward/s/^#//' /etc/sysctl.conf
grep net.ipv4.ip_forward /etc/sysctl.conf
# apply changes
sudo sysctl -p
sudo sysctl net.ipv4.ip_forward

# configure fwding from LAN enp0s8 and enp0s9 to wan enpo0s3 
sudo iptables -A FORWARD -i enp0s8 -o enp0s3 -j ACCEPT
sudo iptables -A FORWARD -i enp0s9 -o enp0s3 -j ACCEPT

sudo iptables -A FORWARD -i enp0s3 -o enp0s8 -m state --state RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A FORWARD -i enp0s3 -o enp0s9 -m state --state RELATED,ESTABLISHED -j ACCEPT

# configure NATing
sudo iptables -t nat -A POSTROUTING -o enp0s3 -j MASQUERADE
sudo iptables -t nat -A POSTROUTING -o enp0s8 -j MASQUERADE
sudo iptables -t nat -A POSTROUTING -o enp0s9 -j MASQUERADE

sudo apt update 
sudo DEBIAN_FRONTEND=noninteractive apt install -y iptables-persistent