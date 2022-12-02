param ( [String] $domain, [String] $iface, [String] $ip_host_suffix)

$domain = "shreklab.local"
$iface  = "Ethernet 2"
$ip_host_suffix = "110"
$dc_suffix = "100"
############################################
# --------------------------------------
#          set DNS
# --------------------------------------
############################################
# see here http://woshub.com/powershell-configure-windows-networking/ 
# and here https://www.windowscentral.com/how-change-priority-order-network-adapters-windows-10
# increase Metrix of chosen Interface, so that it is used preferably. This is necessary to resolve names via DNS of the domain
Set-NetIPInterface -InterfaceAlias $iface -InterfaceMetric 10
# get current IP address depending on chosen interface and set DNS resolver to DC 
$ipv4 = (Get-NetIPAddress -InterfaceAlias $iface | Where-Object {$_.AddressState -eq "Preferred" -and $_.ValidLifetime -lt "24:00:00"}).IPAddress
Set-DNSClientServerAddress -InterfaceAlias $iface -ServerAddresses ($ipv4.Substring(0, $ipv4.LastIndexOf(".")) + "." + $dc_suffix)
# Get-NetIPConfiguration
#Get-DNSClientServerAddress


############################################
# --------------------------------------
#          joining domain
# --------------------------------------
############################################
$user = "$domain\vagrant"
$pass = ConvertTo-SecureString "vagrant" -AsPlainText -Force
$DomainCred = New-Object System.Management.Automation.PSCredential $user, $pass
Add-Computer -DomainName $domain -credential $DomainCred


restart-computer