# execute common tasks
.\generic_setup.ps1

$deviceIP = "10.0.2.21"

New-NetIPAddress -IPAddress $deviceIP -DefaultGateway 10.0.2.2 -InterfaceAlias Ethernet -PrefixLength 24
Set-DnsClientServerAddress -InterfaceAlias Ethernet -ServerAddresses ("10.0.2.10","10.0.2.1")
Get-NetIPConfiguration
Restart-NetAdapter -InterfaceAlias Ethernet

nslookup dc-babay.shreklab.local


$Secure_String_Pwd = ConvertTo-SecureString "Passw0rd!" -AsPlainText -Force
add-computer -domainname shreklab.local -Credential shreklab\johnd -restart -force