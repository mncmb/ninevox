# sh.rek.lab
![](pics/shreklab.jpg)

This is my attempt at an active directory sandbox / lab environment.  

The project follows one simple rule:   
**Keep dependencies and requirements to a minimum**. 
  
Therefore I decided to use [VirtualBox](https://www.virtualbox.org/) + [Vagrant](https://developer.hashicorp.com/vagrant/downloads) as provider and provisioner. These are free for use in personal projects and run on every major operating system.  
As an added benefit this leads to all the configuration and setup scripts being (power)shell scripts, which makes them easily reuseable.   

Furthermore, since Vagrantfiles are ruby files, they can be used for all sorts of things - like creating and configuring NATNetworking for you.  

## arch overview
![](pics/labnetwork.jpg)

| box | IP | notes |
| ---| ---| ---|
| domain controller dc01 | 10.0.9.10 | BadBlood with custom settings, GPOs for better logging, ADCS installed |
| file server fs01 | 10.0.9.20 | 2 file shares - anon access and authenticated access, MSSQL server |
| iis server srv01 | 10.0.9.25 | IIS with fileupload vuln |
| web server web01 | 172.16.0.10 | docker conainer with OWASP crAPI [completely ridiculous API](https://github.com/OWASP/crAPI) |
| ubuntu based FW | 10.0.9.1, 172.16.0.1, 192.168.55.x (DHCP) | firewall using iptables & netplan |  


## project structure 
Answering the question: What's in those directories?

| directory | notes |
| ---|---|
| domain | Lab environment consisting of router with 2 network segments. DMZ with a nix webserver and internal net containing IIS on Server Core, MSSQL&fileshare on Server and Domain Controller |
| win10dev | dev environment for offensive tooling. Loads and installs projects and software like threatcheck, amsiTrigger, visualstudio, vscode, sysinternals, python, go, nim, c/c++ and c# build tools, x64dbg, ghidra, etc.|
| kali | kali with some additional tools, seclists, covenant docker build and neo4j/bloodhound setup |


## TLDR: how to setup?
1. install virtualbox and vagrant if not already done
2. Clone repo and `vagrant up` like so:
```
git clone https://github.com/mncmb/vagrant
cd vagrant/domain
vagrant up
```

## users
Since this is a vagrant deployment you can connect to every system with `vagrant:vagrant`.   
Additionally, there are 2 users defined for administrative and general testing purposes in `inventory.yml` under `VAGRANT_DA_NAME` and `VAGRANT_USER_NAME`.

## vagrant commands
Some useful vagrant commands.
```bash
vagrant up dc01 fs01    # only deploy specified hosts
vagrant up --provision  # restart provisioning scripts

vagrant reload web01    # restart vm 

vagrant halt            # stop all machines
vagrant destroy -f      # destroy all machines without confirmation
```

## vagrantfile ruby
Vagrant files are ruby files, so you can use all sorts of ruby features 
```ruby
puts group              # ruby print 
test = []               # ruby array init
test.push host          # ruby array add
puts test               # print array

# string interpolation, see also https://stackoverflow.com/questions/19648088/pass-environment-variables-to-vagrant-shell-provisioner
shell.args   = "#{vars['VAR1']} #{vars['VAR2']}"  

Gem.win_platform?       # check if running on windows
defined?(vboxmanage)    # check if defined
output = `id`           # execute id command on host and capture output in output
```

## VBoxManage
On Windows, if not added to the path, it can be started with the following command when installed under its default location.
```powershell
."C:\Program Files\Oracle\VirtualBox\VBoxManage.exe"
```
It can be used for many things besides configuring VMs like listing and creating Network adapters.
```powershell
vboxmanage natnetwork list 

vboxmanage natnetwork add --netname <net_adapter> --network <dhcp_range> --enable --dhcp on
```


## networking
Some weird things that had to be considered when doing networking with windows and vagrant:
- vagrant seems to require a NAT adapter for the first interface so that it can connect and provision the system (SSH, WinRM). For this reason every box has NAT for its first interface
- Windows boxes seem to prioritize the first interface for network interactions. This leads to issues when they are connected to a domain. DNS should then be resolved over the Domain Controller, but since interface 1 is prioritized and interface 1 needs to be NAT (see point 1 above), there will be issues. To fix this, network adapter priorization is set for every system, so that "Ethernet 2" aka adapter 2 is prioritized.
- Windows domain controllers cannot be reached by vagrant after DC promotion, unless specific WinRM options are set. (see inventory.yml and Vagrantfile)
- For firewalling I initially wanted to use OpnSense, PFSense, OpenWRT or something like that. Unfortunately there are no (working) up to date versions of those available in the default vagrant box repository. For this reason I decided to go with a simple linux box and iptables.
- Routes to NAT Network segment:


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
- defender exclusions and submissions
- clean up GPOs
- ~~test natnetwork auto creation, see https://docs.oracle.com/en/virtualization/virtualbox/6.0/user/vboxmanage-natnetwork.html~~
- setup crAPI on webserver
- setup something else on webserver to get code exec
- domain join the linux webserver, see https://www.redhat.com/sysadmin/linux-active-directory
- add more vulns and misconfigs
    - bring in interesting AD misconfigs, see https://github.com/Orange-Cyberdefense/GOAD and https://github.com/Marshall-Hallenbeck/red_team_attack_lab
- add ADCS vulns

## references, etc.
This project is based on or influenced by
- [Detection Lab](https://github.com/clong/DetectionLab)
- [Red Team Attack Lab](https://github.com/Marshall-Hallenbeck/red_team_attack_lab)
- [Game of Active Directory](https://github.com/Orange-Cyberdefense/GOAD)
