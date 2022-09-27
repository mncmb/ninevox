param ( [String] $domain)

$domain = "shreklab.local"
############################################
# --------------------------------------
#           creating the domain 
# --------------------------------------
############################################

# install AD - close server manager
Install-windowsfeature AD-domain-services
# install forest
import-module ADDSDeployment
# might change this to "P@ssW0rD!" to make this easier to attack
$Secure_String_Pwd = ConvertTo-SecureString "S3cUr3P@ssW0rD!" -AsPlainText -Force
Install-ADDSForest -NoRebootOnCompletion -CreateDnsDelegation:$false -SafeModeAdministratorPassword $Secure_String_Pwd -DatabasePath "C:\Windows\NTDS" -DomainMode "Win2012R2" -DomainName $domain -ForestMode "Win2012R2" -InstallDns:$true -LogPath "C:\Windows\NTDS" -SysvolPath "C:\Windows\SYSVOL" -Force:$true
# install RSAT
Install-WindowsFeature RSAT-ADDS

# for AD to work, restart is required
Restart-computer

############################################
# --------------------------------------
#          setting static IP and DNS
# --------------------------------------
############################################
# see here http://woshub.com/powershell-configure-windows-networking/
$ipv4 = (Get-NetIPAddress | Where-Object {$_.AddressState -eq "Preferred" -and $_.ValidLifetime -lt "24:00:00"}).IPAddress
$ipv4.Substring(0, $ipv4.LastIndexOf("."))
$staticIP = $ipv4.Substring(0, $ipv4.LastIndexOf(".")) + ".10"
$gateway = (Get-NetIPConfiguration).IPv4DefaultGateway.Nexthop
# creates something like $staticIP = "10.0.2.10"
New-NetIPAddress -IPAddress $staticIP -DefaultGateway $gateway -InterfaceAlias Ethernet -PrefixLength 24
# Get-NetIPConfiguration
# Restart-NetAdapter -InterfaceAlias Ethernet

Set-DNSClientServerAddress -InterfaceAlias Ethernet -ServerAddresses 127.0.0.1,8.8.8.8,::1
Get-DNSClientServerAddress

############################################
# --------------------------------------
#          importing GPOs
# --------------------------------------
############################################
# https://adsecurity.org/?p=3377
# https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/plan/security-best-practices/audit-policy-recommendations

# backup GPO https://learn.microsoft.com/en-us/powershell/module/grouppolicy/backup-gpo?view=windowsserver2022-ps&viewFallbackFrom=win10-ps
# Backup-GPO -Name Auditing -Path \\VBOXSVR\vagrant\gpos

# import GPO https://learn.microsoft.com/en-us/powershell/module/grouppolicy/restore-gpo?view=windowsserver2022-ps&viewFallbackFrom=win10-ps
# Restore-GPO -BackupId 0fc29b3c-fb83-4076-babb-6194c1b4fc26 -Path "\\Server1\Backups"
new-gpo -name Auditing
new-gpo -name Sysmon
Import-GPO -BackupGpoName Auditing -TargetName Auditing -Path \\VBOXSVR\vagrant\gpos
Import-GPO -BackupGpoName Sysmon -TargetName Sysmon -Path \\VBOXSVR\vagrant\gpos
$fqdn = "dc=" +(($domain.split(".")) -join ",dc=")
new-gplink -name Auditing -Target $fqdn
new-gplink -name Sysmon -Target $fqdn

# deploy sysmon immediate task
# see for immediate task creation https://4sysops.com/archives/run-powershell-scripts-as-immediate-scheduled-tasks-with-group-policy/ or https://support.huntress.io/hc/en-us/articles/4404012795027-Deploying-Huntress-with-Group-Policy-GPO-and-Immediate-Scheduled-Task 
# c:\windows\system32\windowspowershell\v1.0\powershell.exe
# -command "new-item -type directory C:\Windows\Temp\sysmon; iwr -useb -o C:\Windows\Temp\sysmon\config.xml https://raw.githubusercontent.com/Neo23x0/sysmon-config/master/sysmonconfig-export.xml; iwr -useb -o C:\Windows\Temp\sysmon\sysmon.exe https://live.sysinternals.com/Sysmon.exe; C:\Windows\Temp\sysmon\sysmon.exe -accepteula -i C:\Windows\Temp\sysmon\config.xml"

# all clients that join will land in the following OU
# redircmp "OU=Clients, OU=Computers, OU=PRACTICALTH, DC=practicalth, DC=com"