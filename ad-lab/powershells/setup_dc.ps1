.\generic_setup.ps1

$deviceIP = "10.0.2.10"



# check if powershell version5 is available
$PSVersionTable.PSVersion
get-host
# rename system
# Rename-Computer -newname "dc-babay"
# install AD - close server manager
Install-windowsfeature AD-domain-services
# install forest
import-module ADDSDeployment
# might change this to "P@ssW0rD!" to make this easier to attack
$Secure_String_Pwd = ConvertTo-SecureString "S3cUr3P@ssW0rD!" -AsPlainText -Force
Install-ADDSForest -NoRebootOnCompletion -CreateDnsDelegation:$false -SafeModeAdministratorPassword $Secure_String_Pwd -DatabasePath "C:\Windows\NTDS" -DomainMode "Win2012R2" -DomainName "shreklab.local" -ForestMode "Win2012R2" -InstallDns:$true -LogPath "C:\Windows\NTDS" -NoRebootOnCompletion:$false -SysvolPath "C:\Windows\SYSVOL" -Force:$true

# install RSAT
Install-WindowsFeature RSAT-ADDS

# add some users
net user adminJoe Shreklab2022! /ADD /DOMAIN
net group "Domain Admins" adminJoe /add

net user websvc Passw0rd! /ADD /DOMAIN
net group "Domain Admins" websvc /add
setspn -s http/shreklab.local:80 websvc

net user johnd Passw0rd! /ADD /DOMAIN

# check users
net users /domain
net group /domain "Domain Admins" 



# do networking stuff
# see here http://woshub.com/powershell-configure-windows-networking/
Get-NetIPConfiguration
# $ifaceIdx = get-NetIpconfiguration | where {$_.IPv4DefaultGateway} | select InterfaceIndex
# Set-NetIPInterface -InterfaceAlias Ethernet -Dhcp Disabled
# Set-DnsClientServerAddress -InterfaceAlias Ethernet -ResetServerAddresses
New-NetIPAddress -IPAddress $deviceIP -DefaultGateway 10.0.2.2 -InterfaceAlias Ethernet -PrefixLength 24
Set-DNSClientServerAddress -InterfaceAlias Ethernet -ServerAddresses 127.0.0.1,::1
Get-NetIPConfiguration
# if something like a defaultgateway has to be removed use this:
# Remove-NetIPAddress -InterfaceAlias Ethernet -DefaultGateway 10.0.2.1
Restart-NetAdapter -InterfaceAlias Ethernet