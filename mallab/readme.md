# mallab
A classical malware analysis lab environment, following the 2 box approach.   
One Windows VM is used for detonation and analysis of malware, the 2nd VM acts as a router and fakes web and other services. 

Take a look at the template directory for guides and ressources to get started with RE.

![netplan mallab](../pics/mallab.jpg)


## deployment
cd into to the mallab directory and deploy the lab with 
```bash
cd mallab
vagrant up
```

[REToolkit](https://github.com/mentebinaria/retoolkit) is downloaded during the setup of the box. You have to install it manually after download, or use another tool suite (see section `other tool suites`).


# **IMPORTANT!** 
- Make sure to disable netAdapter of the control interface (NAT interface / Network Adapter 1) after successful deployment!
- via this adapter malware could access internet ressources and potentially ressources on your internal network, so turn it off / make sure to know what you are doing

![disable_netadapter](../pics/disable_netadapter.jpg)

The `Devices > Network` menu is available from the context menu of a VM. Here you can **disable the interface by left-clicking** on it.

## getting files in and out
Virtualbox has a File Manager, which behaves like an inbuilt FTP client. You can access the File Manager from the VM context menu `Machine > File Manager`.

![disable_netadapter](../pics/virtualbox_file_manager_menu.jpg)

You need to provide valid credentials, for example user:password `vagrant:vagrant` to establish a connection and transfer files between your host system and the guest (VM).

![disable_netadapter](../pics/virtualbox_file_manager_file-view.jpg)

Alternatively, you can start up the ssh server on remnux and just `ssh` from your host to it and copy files with `scp`.

## remnux start inetsim
let remnux act as a fake router that responds to all ips (`iptables`), replies to DNS requests with its own IP (`fakedns`) and serves content on different ports and protocols (`inetsim`).
```
accept-all-ips start enp0s8
fakedns -I 10.10.10.1
inetsim --bind-address 0.0.0.0
```
Take a look at the [remnux documentation](https://docs.remnux.org/) for more information.


## how to get started with malware analysis
misc ressources
- [OALabs RE youtube tutorials](https://www.youtube.com/c/OALabs?app=desktop)
- [dumpguy trickster csharp youtube tutorials](https://www.youtube.com/@DuMpGuYTrIcKsTeR)
- [dr4k0nia blog - csharp based malware, packers and deobfuscation tools and writeups](https://dr4k0nia.github.io/)
- [laurieWired android youtube tutorials](https://www.youtube.com/@lauriewired)
- [malware unicorn RE101 - free workshop](https://malwareunicorn.org/workshops/re101.html#0)
- [MAS - malware analysis series - in depth blog series](https://exploitreversing.com/2021/12/03/malware-analysis-series-mas-article-1/)
- [c3rb3ru5d3d53c misc articles](https://c3rb3ru5d3d53c.github.io/posts/)
- [practical malware analysis & triage - paid but very affordable course](https://academy.tcm-sec.com/p/practical-malware-analysis-triage)
- [zero2auto paid course](https://courses.zero2auto.com/beginner-bundle) 


## other tool suites
- [sentinelLabs malware lab setup guide ](https://www.sentinelone.com/labs/building-a-custom-malware-analysis-lab-environment/) - provides a script for an alternate tool setup, blog also covers setting up a https proxy
- [flareVM - all in one tooling VM](https://github.com/mandiant/flare-vm) If you prefer FlareVM, you can deploy it as an alternative tool suite


---


## vagrant box creation 
Box creation followed a pretty manual approach but I was kind of annoyed that there was no recent remnux version up on vagrant.
- downloaded current remnux and manually prepared it according to this documentation 
https://developer.hashicorp.com/vagrant/docs/providers/virtualbox/boxes

Essentially this boils down to
1. create vagrant user
2. add to sudoers group and configure NOPASSWD
3. install virtualbox guest additions
4. activate ssh

### pack the box
```powershell
vagrant package --base my_remnux
vagrant box add --force --name my_remnux ./package.box
```
- upload box to vagrant cloud ([example tutorial](https://blog.ycshao.com/2017/09/16/how-to-upload-vagrant-box-to-vagrant-cloud/)- but its rather straight forward)

### init and test the box
```powershell
vagrant init my-remnux
vagrant up
```

