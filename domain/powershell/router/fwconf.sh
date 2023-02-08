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
      dhcp4: yes
    enp0s9:
      dhcp4: no
      addresses: [172.16.0.1/24]
    enp0s10:
      dhcp4: no
      addresses: [10.0.9.1/24]
EOM

sudo mv /tmp/00-installer-config.yaml /etc/netplan/00-installer-config.yaml
sudo netplan apply

# sudo reboot
################################

sudo sed -i '/net.ipv4.ip_forward/s/^#//' /etc/sysctl.conf
grep net.ipv4.ip_forward /etc/sysctl.conf
# apply changes
sudo sysctl -p
sudo sysctl net.ipv4.ip_forward

# configure fwding from LAN enp0s8 and enp0s9 to wan enpo0s3 
#sudo iptables -A FORWARD -i enp0s9 -o enp0s3 -j ACCEPT
#sudo iptables -A FORWARD -i enp0s10 -o enp0s3 -j ACCEPT

sudo iptables -A FORWARD -i enp0s9 -o enp0s8 -j ACCEPT
sudo iptables -A FORWARD -i enp0s10 -o enp0s8 -j ACCEPT

#sudo iptables -A FORWARD -i enp0s3 -o enp0s9 -m state --state RELATED,ESTABLISHED -j ACCEPT
#sudo iptables -A FORWARD -i enp0s3 -o enp0s10 -m state --state RELATED,ESTABLISHED -j ACCEPT

sudo iptables -A FORWARD -i enp0s8 -o enp0s9 -m state --state RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A FORWARD -i enp0s8 -o enp0s10 -m state --state RELATED,ESTABLISHED -j ACCEPT

# configure NATing
sudo iptables -t nat -A POSTROUTING -o enp0s3 -j MASQUERADE
sudo iptables -t nat -A POSTROUTING -o enp0s8 -j MASQUERADE
sudo iptables -t nat -A POSTROUTING -o enp0s9 -j MASQUERADE
sudo iptables -t nat -A POSTROUTING -o enp0s10 -j MASQUERADE

sudo apt update 
sudo DEBIAN_FRONTEND=noninteractive apt install -y iptables-persistent bind9 net-tools

# setup DNS
cat > /tmp/named.conf.options << EOM
options {
        directory "/var/cache/bind";

        // If there is a firewall between you and nameservers you want
        // to talk to, you may need to fix the firewall to allow multiple
        // ports to talk.  See http://www.kb.cert.org/vuls/id/800113

        // If your ISP provided one or more IP addresses for stable
        // nameservers, you probably want to use them as forwarders.
        // Uncomment the following block, and insert the addresses replacing
        // the all-0's placeholder.

        forwarders {
                8.8.8.8;
        };

        //========================================================================
        // If BIND logs error messages about the root key being expired,
        // you will need to update your keys.  See https://www.isc.org/bind-keys
        //========================================================================
        dnssec-validation auto;

        listen-on-v6 { any; };
};
EOM
sudo mv /tmp/named.conf.options /etc/bind/named.conf.options

#sudo route delete default gw 10.0.2.2 enp0s3
#sudo ip route del 10.0.2.0/24 dev enp0s3

# netplan documentation
# https://netplan.readthedocs.io/en/latest/examples/#using-multiple-addresses-with-multiple-gateways
# https://stackoverflow.com/questions/69984065/add-to-crontab-if-not-already-exists-using-bash-script
cron_min='*/5 * * * * sudo route delete default gw 10.0.2.2 enp0s3'
cron_boot='@reboot sudo route delete default gw 10.0.2.2 enp0s3'
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
