param ( [String] $dc_suffix= "100", 
        [String] $ip_host_suffix= "100")

$iface=$env:VAGRANT_PRIMARY_INTERFACE
$domain=$env:VAGRANT_DOMAIN_NAME

write-host "starting `$domain: $domain, `$iface: $iface, `$dc_suffix: $dc_suffix, `$ip_host_suffix: $ip_host_suffix"
# $ErrorActionPreference = "Stop"               # set global erroractionpref to catch errors
############################################
# --------------------------------------
#          setting static IP and DNS
# --------------------------------------
############################################
# see here http://woshub.com/powershell-configure-windows-networking/ 
# and here https://www.windowscentral.com/how-change-priority-order-network-adapters-windows-10
# increase metric of chosen Interface, so that it is used preferably. This is necessary to resolve names via DNS of the domain
Set-NetIPInterface -InterfaceAlias $iface -InterfaceMetric 10
# get current IP address depending on chosen interface 
$ipv4 = (Get-NetIPAddress -InterfaceAlias $iface -AddressFamily IPv4 | Where-Object {$_.AddressState -eq "Preferred"}).IPAddress
write-host "`$ipv4: $ipv4"
$staticIP = $ipv4.Substring(0, $ipv4.LastIndexOf(".")) + "." + $ip_host_suffix
write-host setting IP to $staticIP
# get current getway, so we can reuse that
Get-NetIPConfiguration -InterfaceAlias $iface
$gateway = (Get-NetIPConfiguration -InterfaceAlias $iface).IPv4DefaultGateway.Nexthop
if (! $gateway){ 
        $gateway = $ipv4.Substring(0, $ipv4.LastIndexOf(".")) + ".2"
        write-host "no default gateway IP was found, setting default gateway to $gateway"
        } # default for nat network in Vbox is 10.0.2.2
# set static IP
New-NetIPAddress -IPAddress $staticIP -DefaultGateway $gateway -InterfaceAlias $iface -PrefixLength 24
Restart-NetAdapter -InterfaceAlias $iface

# set DNS resolver to gateway at this stage - will be changed in "setup-dc.ps1" script 
Set-DNSClientServerAddress -InterfaceAlias $iface -ServerAddresses ($ipv4.Substring(0, $ipv4.LastIndexOf(".")) + ".1")

# sleep some time to wait for interface configuration
sleep 5
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
Import-Module ServerManager
Add-WindowsFeature RSAT-AD-PowerShell,RSAT-AD-AdminCenter
Install-windowsfeature AD-domain-services
import-module ADDSDeployment
$Secure_String_Pwd = ConvertTo-SecureString $safemodeAdminPW -AsPlainText -Force
write-host "setting up domain"

# vagrant attempts to do graceful shutdown after ADDSForest 
# "==> dc01: Attempting graceful shutdown of VM..."
# also ends with a "WinRM::WinRMAuthorizationError"
# https://github.com/dbroeglin/windows-lab/issues/1
# https://stackoverflow.com/questions/69482240/provisioning-windows-vm-with-vagrant-cannot-execute-remote-winrm-commands
# https://groups.google.com/g/vagrant-up/c/JNMOCYpHSt8
# 
# probably related to some winrm timeout until after VM is restarted
try {
        Install-ADDSForest `
                -SafeModeAdministratorPassword $Secure_String_Pwd `
                -DomainMode $domainMode `
                -DomainName $domain `
                -ForestMode $domainMode `
                -InstallDns `
                -Force `
                -NoRebootOnCompletion `
                -ErrorAction Stop

}
catch {
        Write-Host "[ERROR]:" $_ 
}
Write-host "AD installed, DC promoted. Installing windows features"

# Restart-computer -force