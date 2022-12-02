param ( [String] $domain, [String] $iface, [String] $ip_host_suffix, [String] $dc_suffix)

$domain = "shreklab.local"
$iface  = "Ethernet 2"
$ip_host_suffix = "100"

############################################
# --------------------------------------
#          importing GPOs
# --------------------------------------
############################################
# https://adsecurity.org/?p=3377
# https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/plan/security-best-practices/audit-policy-recommendations
# backup GPO https://learn.microsoft.com/en-us/powershell/module/grouppolicy/backup-gpo?view=windowsserver2022-ps&viewFallbackFrom=win10-ps
# import GPO https://learn.microsoft.com/en-us/powershell/module/grouppolicy/restore-gpo?view=windowsserver2022-ps&viewFallbackFrom=win10-ps

new-gpo -name Auditing
new-gpo -name Sysmon
new-gpo -name "Powershell script block logging"
Import-GPO -BackupGpoName Auditing -TargetName Auditing -Path "C:\vagrant\gpos"#"\\VBOXSVR\vagrant\gpos"
Import-GPO -BackupGpoName Sysmon -TargetName Sysmon -Path "C:\vagrant\gpos"#"\\VBOXSVR\vagrant\gpos"
Import-GPO -BackupGpoName "Powershell script block logging" -TargetName Sysmon -Path "C:\vagrant\gpos"#"\\VBOXSVR\vagrant\gpos"
$fqdn = "dc=" +(($domain.split(".")) -join ",dc=")
new-gplink -name Auditing -Target $fqdn
new-gplink -name Sysmon -Target $fqdn
new-gplink -name "Powershell script block logging" -Target $fqdn

# deploy sysmon immediate task
# see for immediate task creation https://4sysops.com/archives/run-powershell-scripts-as-immediate-scheduled-tasks-with-group-policy/ or https://support.huntress.io/hc/en-us/articles/4404012795027-Deploying-Huntress-with-Group-Policy-GPO-and-Immediate-Scheduled-Task 
# c:\windows\system32\windowspowershell\v1.0\powershell.exe
# -command "new-item -type directory C:\Windows\Temp\sysmon; iwr -useb -o C:\Windows\Temp\sysmon\config.xml https://raw.githubusercontent.com/Neo23x0/sysmon-config/master/sysmonconfig-export.xml; iwr -useb -o C:\Windows\Temp\sysmon\sysmon.exe https://live.sysinternals.com/Sysmon.exe; C:\Windows\Temp\sysmon\sysmon.exe -accepteula -i C:\Windows\Temp\sysmon\config.xml"

# all clients that join will land in the following OU
# redircmp "OU=Clients, OU=Computers, OU=PRACTICALTH, DC=practicalth, DC=com"

############################################
# --------------------------------------
#         Users
# --------------------------------------
############################################
net user shrek "Swamp2022!" /ADD /DOMAIN /Y
net group "Domain Admins" shrek /add /Y
net group "Domain Admins" vagrant /add /Y # dis for ADCS error fix?
net user donkey "Passw0rd!" /ADD /DOMAIN /Y


# adding ADCS
# taken from https://github.com/jfmaes/x33fcon-workshop/blob/main/dc/add-ons.ps1
Install-WindowsFeature Adcs-Cert-Authority -IncludeManagementTools
Install-AdcsCertificationAuthority -CAType EnterpriseRootCa -Force
Install-PackageProvider NuGet -Force
Set-PSRepository PSGallery -InstallationPolicy Trusted
Install-Module ADCSTemplate -Force
add-WindowsFeature Adcs-Web-Enrollment
Install-AdcsWebEnrollment -Force
