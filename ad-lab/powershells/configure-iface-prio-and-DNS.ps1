param ([String] $dns, $setdns = $true)
$dnsprefix = $dns.split(".")[0,1] -join(".")
# check out what interfaces are there
$iface = Get-NetIPAddress | ?{ $_.AddressFamily -eq "IPv4" -and ($_.IPAddress -match $dnsprefix)} | select InterfaceAlias
# check if it is the right interface based on IP 
Get-NetIPConfiguration -InterfaceAlias $iface.InterfaceAlias
# set the interfaceMetric priority higher than other interfaces
# lower number means higher priority
Write-Host "setting Interfacemetric of $($iface.InterfaceAlias) to 10"
Set-NetIPInterface -InterfaceAlias $iface.InterfaceAlias -InterfaceMetric 10
# set DNS server
if ([System.Convert]::ToBoolean($setdns)) {
    Write-host "Setting DNS server to $dns"
    Set-DnsClientServerAddress -InterfaceAlias $iface.InterfaceAlias -ServerAddresses $dns
}
# check if domain can be reached
# nslookup <mydomain.name>