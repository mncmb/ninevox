param ( [String] $arg1 = "100", 
        [String] $arg2)

$iface=$env:VAGRANT_PRIMARY_IFACE
$domain=$env:VAGRANT_DOMAIN_NAME
$dcip=$env:VAGRANT_DC_IP
$hostip=$env:VAGRANT_HOST_IP

# user
$domuser="vagrant"#$env:VAGRANT_USER_NAME
$domuserpass="vagrant"#$env:VAGRANT_USER_PASS

if ((gwmi win32_computersystem).Domain -eq $domain) {
    write-host "already joind domain $domain, skipping..."
    exit
}


write-host started join-domain with the following args
write-host $domain, $iface, $dcip, $hostip

# [System.Environment]::SetEnvironmentVariable($key_name, $value)
# [System.Environment]::SetEnvironmentVariable($key_name, $value, [System.EnvironmentVariableTarget]::Machine)
# [System.Environment]::SetEnvironmentVariable($key_name, $value, [System.EnvironmentVariableTarget]::User)

# fs 
# .\join-domain.ps1 shreklab.local "Ethernet 2" 100 110

# ws
# .\join-domain.ps1 shreklab.local "Ethernet 2" 100 
############################################
# --------------------------------------
#          setting static IP and DNS
# --------------------------------------
# set static IP for given interface.
# set priority of given interface, so that
# it will be used for DNS and everything else
# 
############################################
# see here http://woshub.com/powershell-configure-windows-networking/ 
# and here https://www.windowscentral.com/how-change-priority-order-network-adapters-windows-10
# increase metric of chosen Interface, so that it is used preferably. This is necessary to resolve names via DNS of the domain
function Set-StaticIPandDNS($domain, $iface, $dcip, $hostip){
    write-host iface: $iface
    Set-NetIPInterface -InterfaceAlias $iface -InterfaceMetric 10
    # get current IP address depending on chosen interface
    $ipv4 = (Get-NetIPAddress -InterfaceAlias $iface -AddressFamily IPv4 | Where-Object {$_.AddressState -eq "Preferred"}).IPAddress
    write-host "Current IPv4 is: $ipv4"
    # check if static_ip suffix is set https://stackoverflow.com/questions/48643250/how-to-check-if-a-powershell-optional-argument-was-set-by-caller
    if ($hostip){
        #$static_ip = $ipv4.Substring(0, $ipv4.LastIndexOf(".")) + "." + $static_suffix
        $static_ip = $hostip
        write-host "setting IP to $static_ip"
        # get current getway, so we can reuse that
        # $gateway = (Get-NetIPConfiguration -InterfaceAlias $iface ).IPv4DefaultGateway.Nexthop
        $gateway = $hostip.Substring(0, $hostip.LastIndexOf(".")) + "." + "1"

        write-host "setting gateway to $gateway"
        # set static IP if it is not already set
        #Get-NetIPAddress
        if (!($ipv4 -eq $static_ip)) {
            try { 
            New-NetIPAddress -IPAddress $static_ip -DefaultGateway $gateway -InterfaceAlias $iface -PrefixLength 24 -ErrorAction Stop 
            }
            catch { Write-Host "[ERROR]:" $_ }
        }#Get-NetIPConfiguration
        #Restart-NetAdapter -InterfaceAlias $iface
        Set-NetIPAddress -IPAddress $static_ip -InterfaceAlias $iface -PrefixLength 24
    }
    #$dnsserver = ($ipv4.Substring(0, $ipv4.LastIndexOf(".")) + "." + $dc_suffix)
    $dnsserver = $dcip
    Write-Host "Setting DNS to $dnsserver"
    Set-DNSClientServerAddress -InterfaceAlias $iface -ServerAddresses $dnsserver
    #Get-DNSClientServerAddress
}

Set-StaticIPandDNS $domain $iface $dcip $hostip
# this sleep timer is like The Incredible Machine - do not touch kek
# setting adapter is finicky af
sleep 10
write-host "check ipconfig after 10s sleep" 
ipconfig
#sleep 3
#Write-Host "Starting second try of setting interface"
#Set-StaticIPandDNS $domain $iface $dc_suffix $static_suffix
#sleep 1
############################################
# --------------------------------------
#          joining domain
# --------------------------------------
############################################
# https://stackoverflow.com/questions/4409043/how-to-find-if-the-local-computer-is-in-a-domain
if ((gwmi win32_computersystem).partofdomain -eq $false) {
    $user = "$domain\$domuser"
    $pass = ConvertTo-SecureString "$domuserpass" -AsPlainText -Force
    $DomainCred = New-Object System.Management.Automation.PSCredential $user, $pass
    Add-Computer -DomainName $domain -credential $DomainCred

    restart-computer -Force
}