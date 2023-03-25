# sh.rek.lab
![](../pics/shreklab.jpg)

## arch overview
![](../pics/labnetwork.jpg)

| box | IP | notes |
| ---| ---| ---|
| domain controller dc01 | 10.0.9.10 | BadBlood with custom settings, GPOs for better logging, ADCS installed |
| file server fs01 | 10.0.9.20 | 2 file shares - anon access and authenticated access, MSSQL server |
| iis server srv01 | 10.0.9.25 | IIS with fileupload vuln, Windows Server core |
| web server web01 | 172.16.0.10 | docker conainer with OWASP crAPI [completely ridiculous API](https://github.com/OWASP/crAPI) |
| ubuntu based FW | 10.0.9.1, 172.16.0.1, 192.168.55.x (DHCP) | firewall using iptables & netplan | 

## Hardware reqs
VMs are provisioned with the following specs:
| box | cores | memory |
| ---| ---| ---|
| dc01 | 2 | 3600 |
| fs01 | 2 | 3600 |
| srv01 | 2 | 2048 |
| web01 | 1 | 1024 |
| router | 1 | 512 | 

Overall around ~11 GB of memory + core utilization (4 phys cores with SMT should be enough) + probably around 100 GB of disk storage.   

If you have only access to low specced systems, you could comment out `fs01` and probably downsize srv01 Memory to around 1400 meg. This would put the memory requirements below 7 GB.  

Keep in mind you probably still have to setup a Kali VM or something similar.


## elastic EDR
- checkout elastic container project
- https://www.elastic.co/de/security-labs/the-elastic-container-project
- https://github.com/peasead/elastic-container


## networking
Some weird things that had to be considered when doing networking with windows and vagrant:
- vagrant seems to require a NAT adapter for the first interface so that it can connect and provision the system (SSH, WinRM). For this reason every box has NAT for its first interface
- Windows boxes seem to prioritize the first interface for network interactions. This leads to issues when they are connected to a domain. DNS should then be resolved over the Domain Controller, but since interface 1 is prioritized and interface 1 needs to be NAT (see point 1 above), there will be issues. To fix this, network adapter priorization is set for every system, so that "Ethernet 2" aka adapter 2 is prioritized.
- Windows domain controllers cannot be reached by vagrant after DC promotion, unless specific WinRM options are set. (see inventory.yml and Vagrantfile)
- For firewalling I initially wanted to use OpnSense, PFSense, OpenWRT or something like that. Unfortunately there are no (working) up to date versions of those available in the default vagrant box repository. For this reason I decided to go with a simple linux box and iptables.
- Routes to NAT Network segment: The original plan is to limit access to *server network*, so that a host in the *DMZ zone* has to be used for pivoting. Currently this works if you place your attacking machine into the NatNetwork `ShrekNat`. But it only works, because routing preferences of windows servers in *server network* prioritize the NAT adapter on ehternet 1. If you disable that adapter, routing tables will be updated and *server network* systems can easily access DMZ and *outside/ nat network*. Will be fixed in a future update.


## users
Since this is a vagrant deployment you can connect to every system with `vagrant:vagrant`.   
Additionally, users `shrek:Swamp2023!` and `donkey:Passw0rd!` are defined for administrative and general testing purposes in `inventory.yml` under `VAGRANT_DA_NAME` and `VAGRANT_USER_NAME`.


## todo 
- something, something build pipeline  
    for inspiration take a look at: 
    - jenkins container, see https://blog.sunggwanchoi.com/half-automating-powersharppack/ 
    - havoc build scripts
    - offensivepipeline
- ~~add FW~~ 
- add mailserver for pw spraying and internal payload delivery
- ~~do some network segmentation~~
- ~~set domain name on each host via env var, so that argument passing to scripts can be cleaned up~~ 
- ~~create user name list based on movie with namemash.py, combined with badblood functionality~~ same but different
- check similar projects for common GPOs, check if there are any public source repos regarding reallive GPOs -> still nothing found
- add elasticcontainerproject https://www.elastic.co/de/security-labs/the-elastic-container-project 
- add velocistack https://github.com/weslambert/velocistack
- ~~change the powershell function that sets env variables so that it sets all env variables in one call, instead of one per env variable (see ruby arrays in vagrantfile for keeping it as yaml defined in inventory)~~
- modify CreateOUStructure.ps1 in badblood to reduce clutter and change 3lettercodes so they fit thematically `. .\Invoke-BadBlood.ps1 -NonInteractive`
    - for "location names" see here, maybe there is a use for it https://shrek.fandom.com/wiki/Shrek_universe
- add documents to file share that have to do with the franchise
- add theWaffler, pencilHead and King as users
- ~~change interfaces for all systems~~
- ~~change/remove environment scripts -> not linux compatible and not necessarily needed~~
- ~~make it work~~
- ~~pretty stuff up~~
- port fwd from NatNetwork to DMZ
- fw rules & routes for server zone
- create GPO for defender exclusions, sample submissions, etc.
- clean up GPOs
- ~~test natnetwork auto creation, see https://docs.oracle.com/en/virtualization/virtualbox/6.0/user/vboxmanage-natnetwork.html~~
- setup crAPI on webserver
- setup something else on webserver to get code exec
- domain join the linux webserver, see https://www.redhat.com/sysadmin/linux-active-directory
- add more vulns and misconfigs
    - bring in interesting AD misconfigs, see https://github.com/Orange-Cyberdefense/GOAD and https://github.com/Marshall-Hallenbeck/red_team_attack_lab
- add ADCS vulns
- add webclient service to servers
- add donkey as local admin to servers
- add DVWP (wordpress) on webserver