
param ( [String] $domain)

############################################
# --------------------------------------
#          setting static IP and DNS
# --------------------------------------
############################################
# see here http://woshub.com/powershell-configure-windows-networking/
$ipv4 = (Get-NetIPAddress | Where-Object {$_.AddressState -eq "Preferred" -and $_.ValidLifetime -lt "24:00:00"}).IPAddress
$ipv4.Substring(0, $ipv4.LastIndexOf("."))
$dcIP = $ipv4.Substring(0, $ipv4.LastIndexOf(".")) + ".10"

Set-DNSClientServerAddress -InterfaceAlias Ethernet -ServerAddresses $dcIP,($ipv4.Substring(0, $ipv4.LastIndexOf(".")) + ".1")
Get-DNSClientServerAddress

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