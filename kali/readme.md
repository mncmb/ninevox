# kali
Current kali rolling with some small additions.

## multi NIC issues
Route adjustments from kali when using multi NIC box: `ifmetric eth0 10` to set metric value of _eth0_ to 10. if _eth1_ has a lower preference value, it will be preferred.
```shell
# set interface metric values for specific adapters to higher values so they are less prioritized
# eth1, eth2 ... are then prefered
sudo ifmetric eth0 10
sudo ifmetric docker0 10
# set ip for interface eth2
sudo ifconfig eth2 192.168.56.50/24

# check out routes
route
# delete route to a specific network for eth1 and add route to other adapter
sudo route del -net 192.168.56.0/24 eth1
sudo route add -net 192.168.56.0/24 eth2
ping 192.168.56.10 
```