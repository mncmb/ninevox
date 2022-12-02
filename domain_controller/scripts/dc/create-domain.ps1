param ( [String] $domain, [String] $iface, [String] $ip_host_suffix, [String] $dc_suffix)

$domain = "shreklab.local"
$iface  = "Ethernet 2"
$ip_host_suffix = "100"
############################################
# --------------------------------------
#          setting static IP and DNS
# --------------------------------------
############################################
# see here http://woshub.com/powershell-configure-windows-networking/ 
# and here https://www.windowscentral.com/how-change-priority-order-network-adapters-windows-10
# increase Metrix of chosen Interface, so that it is used preferably. This is necessary to resolve names via DNS of the domain
Set-NetIPInterface -InterfaceAlias $iface -InterfaceMetric 10
# get current IP address depending on chosen interface 
$ipv4 = (Get-NetIPAddress -InterfaceAlias $iface | Where-Object {$_.AddressState -eq "Preferred" -and $_.ValidLifetime -lt "24:00:00"}).IPAddress
$staticIP = $ipv4.Substring(0, $ipv4.LastIndexOf(".")) + "." + $ip_host_suffix
write-host setting IP to $staticIP
# get current getway, so we can reuse that
$gateway = (Get-NetIPConfiguration -InterfaceAlias $iface).IPv4DefaultGateway.Nexthop
# set static IP
New-NetIPAddress -IPAddress $staticIP -DefaultGateway $gateway -InterfaceAlias $iface -PrefixLength 24
Restart-NetAdapter -InterfaceAlias $iface

# set DNS resolver to gateway at this stage - will be changed in "setup-dc.ps1" script 
Set-DNSClientServerAddress -InterfaceAlias $iface -ServerAddresses ($ipv4.Substring(0, $ipv4.LastIndexOf(".")) + ".1")

# check configs with
# $ Get-NetIPConfiguration
# $ Get-DNSClientServerAddress

############################################
# --------------------------------------
#           creating the domain 
# --------------------------------------
############################################

# install AD
$safemodeAdminPW = "S3cUr3P@ssW0rD!"
$domainMode = "Win2012R2"
Install-windowsfeature AD-domain-services
import-module ADDSDeployment
$Secure_String_Pwd = ConvertTo-SecureString $safemodeAdminPW -AsPlainText -Force
Install-ADDSForest -NoRebootOnCompletion -SafeModeAdministratorPassword $Secure_String_Pwd -DomainMode $domainMode -DomainName $domain -ForestMode $domainMode -InstallDns -Force
Install-WindowsFeature RSAT-ADDS
Set-DNSClientServerAddress -InterfaceAlias $iface -ServerAddresses $staticIP,($ipv4.Substring(0, $ipv4.LastIndexOf(".")) + ".1")
add-WindowsFeature RSAT-ADDS-Tools

Restart-computer