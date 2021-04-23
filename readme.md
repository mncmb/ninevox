# init
Vagrant files for the setup of different dev / test environments. They use the shell provisioner at the moment.

Current contents:

## Win10Dev

Dev environment based on windows10 90 day trial image for IE / Edge developers. 

This Vagrant config allows for automatic deployment and configuration of a fresh Windows 10 box with 90 days of trial use. Additionally it sets up the box for RDP and SSH access and installs chocolatey and some applications useful for development. More customization can be done by installing additional packages, see chocolatey documentation: https://chocolatey.org/packages. 

Since, I regularly came across the problem that my dev and test environments expired, I wanted to reduce the amount of maintenance. So automatic provisioning was the logical choice. And while there is a Windows box available over on the vagrant hub (https://app.vagrantup.com/gusztavvargadr/boxes/windows-10) this introduces unknown dependencies (and most importantly it doesn't let me get acquainted with most of the technology used here). This box righte here comes directly from Microsoft and has WinRM already enabled. 

### Register box with Vagrant

In order to use the box, the following setup is required:

+ execute the `build.sh` script from the _build_vagrant-win10_base_ directory

This does the following:

1. Fetches a Vagrant VirtualBox VM image from the Microsoft Edge Developer pages https://developer.microsoft.com/en-us/microsoft-edge/tools/vms/
2. download the image and unzip it once the donwload has completed
3. registers the VM with vagrant (`vagrant box add ...`) 

### Deploy 
Go to directory and issue
```
vagrant up
``` 
to deploy the box. The default credentials for the Windows Edge Developer VM are: `IEUser:Passw0rd!`.




## kali

This config sets up the official kali image from https://app.vagrantup.com/kalilinux/boxes/rolling.

Afterwards the user `kali` with password `kali` is created and a handful of applications are installed and repositories cloned.


--------------------
Sources:
https://gist.github.com/santrancisco/a7183470efa0e3412222670d0bfb3da5
