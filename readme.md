# init
Vagrant files for the setup of different dev / test environments. These use the shell provisioner at the moment.

Current contents:

## win10vxdev

Dev environment based on windows10 90 day trial image for IE / Edge developers. 

This Vagrant config allows for automatic deployment and configuration of a fresh Windows 10 box with 90 days of trial use. Additionally it sets up the box for RDP and SSH access and installs chocolatey and some applications useful for development, DFIR and light reversing. Application names can be looked up via chocolatey documentation: https://chocolatey.org/packages. 

Since, I regularly came across the problem that my dev and test environments expired, I wanted to reduce the amount of maintenance. So automatic provisioning was the logical choice. And while there is a Windows box available over on the vagrant hub (https://app.vagrantup.com/gusztavvargadr/boxes/windows-10) this introduces unknown dependencies. This box comes directly from Microsoft.

So in order to use the box, the following setup is required:
+ go over to the Microsoft Edge Developer pages https://developer.microsoft.com/en-us/microsoft-edge/tools/vms/
+ from the drop downs select `Win10` and `Vagrant` as the VM platform
+ download the image and unzip it once the donwload has completed
+ register the VM with vagrant:
```
vagrant box add windows/win10-edge 'MSEdge - Win10.box'
```
+ go to the location of the Vagrantfile and enter
```
vagrant up
``` 
to deploy the box. The default credentials for the Windows Edge Developers VM are: `IEUser:Passw0rd!`.

Most of the heavy lifting required to set this up is based on this [gist](https://gist.github.com/santrancisco/a7183470efa0e3412222670d0bfb3da5).


## kali

This config sets up the official kali image from https://app.vagrantup.com/kalilinux/boxes/rolling.

Afterwards the user `kali` with password `kali` is created and a handful of applications are installed and repositories cloned.

