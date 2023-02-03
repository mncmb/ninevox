# init
This repository currently contains the following:

| dir | comment |
| ---|---|
| win10dev | dev environment for offensive needs, got things like threatcheck, amsiTrigger, visualstudio, vscode, sysinternals, python, go, nim, c/c++ and c# build tools, x64dbg, ghidra, etc.|
| kali | kali with some additional tools, seclists, covenant docker build and neo4j/bloodhound setup |
| AD-Lab | half-assed, nowhere near finished attempt at building an AD lab, based on DetectionLab |
|  |  |

## vagrant commands
```bash
vagrant up dc01 fs01    # only deploy specified hosts
vagrant up --provision  # restart provisioning scripts


vagrant destroy -f      # destroy all machines without confirmation


vagrant halt            # stop all machines
vagrant start dc01 fs01 # start specified hosts
```

## vagrantfile ruby tricks
The following statements can be used in vagrantfiles to debug stuff or so 
```ruby
puts group          # ruby print 
test = []           # ruby array init
test.push host      # ruby array add
puts test           # print array
# shell .args   = "#{ENV['VAR1']} #{ENV['VAR2']}"  ---- see here https://stackoverflow.com/questions/19648088/pass-environment-variables-to-vagrant-shell-provisioner
```

## Active Donkey
- ~~primarily vagrant shell provisioning based for better portability (powershell scripts, so can be used with ansible, puppet or whatever)~~
- ~~since vagrant shell provisioner is such a pain - install-ADforest and reboots wont play nicely and time out - I decided to use vagrant to provision an ansible host inside the network and execute all the deployment from there on~~ fixed by finding a relevant option, see vagrantfile
- AD network is a Virtualbox NAT Network
- since this seems to be broken with vagrant port forwarding, the basic NAT adapter is kept as Interface 1. NAT network is on interface 2.
- in order for DNS to work correctly, priority of the interfaces is then adjusted, so that Ethernet 2, where NATNetwork adapter resides, is prioritized (windows)
- still keeping the powershell scripts to deploy a domain in case I want to set something up w/o vagrant & ansible

## todo 
- do something with automizing builds with jenkins container, see https://blog.sunggwanchoi.com/half-automating-powersharppack/ and some havoc build scripts
- alternatively take a look at offensivepipeline
- add FW 
- add mailserver for pw spraying and internal payload delivery
- do some network segmentation
- bring in interesting AD misconfigs, see https://github.com/Orange-Cyberdefense/GOAD and https://github.com/Marshall-Hallenbeck/red_team_attack_lab
- set domain name on each host via env var, so that argument passing to scripts can be cleaned up 
- create user name list based on da movie with namemash.py, combined with badblood functionality
- check similar projects for common GPOs, check if there are any public source repos regarding reallive GPOs
- add elasticcontainerproject https://www.elastic.co/de/security-labs/the-elastic-container-project 
- add velocistack https://github.com/weslambert/velocistack
- change the powershell function that sets env variables so that it sets all env variables in one call, instead of one per env variable (see ruby arrays in vagrantfile for keeping it as yaml defined in inventory)
- modify CreateOUStructure.ps1 to reduce clutter a bit and 3lettercodes so they fit thematically in badblood `. .\Invoke-BadBlood.ps1 -NonInteractive`
- for "location names" see here, maybe there is a use for it https://shrek.fandom.com/wiki/Shrek_universe
- add documents related to shlore
- add theWaffler, pencilHead and King as usernames -> allstar
- change interfaces for all systems
- change/remove environment scripts -> not linux compatible and not necessarily needed 
1. make it work
2. pretty stuff up