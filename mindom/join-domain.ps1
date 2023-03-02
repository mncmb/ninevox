param ( [String] $domain ,[String] $dcip, $iface)

$iface = "Ethernet 2"

# user
$domuser="vagrant"#$env:VAGRANT_USER_NAME
$domuserpass="vagrant"#$env:VAGRANT_USER_PASS

# https://stackoverflow.com/questions/4409043/how-to-find-if-the-local-computer-is-in-a-domain
if ((gwmi win32_computersystem).partofdomain -eq $true) {
    write-host "already joind domain $domain, skipping..."
    exit
}

Set-NetIPInterface -InterfaceAlias $iface -InterfaceMetric 10
Set-DNSClientServerAddress -InterfaceAlias $iface -ServerAddresses $dcip
sleep 10    # magic 10 seconds to make DNS update work

$user = "$domain\$domuser"
$pass = ConvertTo-SecureString "$domuserpass" -AsPlainText -Force
$DomainCred = New-Object System.Management.Automation.PSCredential $user, $pass
Add-Computer -DomainName $domain -credential $DomainCred #-ErrorAction Stop