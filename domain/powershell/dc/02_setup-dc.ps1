param ( [String] $admin = "shrek", 
        [String] $adminpass = "Swamp2022!")

$iface=$env:VAGRANT_PRIMARY_INTERFACE
$domain=$env:VAGRANT_DOMAIN_NAME

$fqdn = "dc=" +(($domain.split(".")) -join ",dc=")
############################################
# --------------------------------------
#          install RSAT tools
# --------------------------------------
############################################
Install-WindowsFeature RSAT-ADDS
Write-host "RSAT ADDS installed"
add-WindowsFeature RSAT-ADDS-Tools
Write-host "RSAT ADDS TOOLS added"
# Set-DNSClientServerAddress -InterfaceAlias $iface -ServerAddresses $staticIP,($ipv4.Substring(0, $ipv4.LastIndexOf(".")) + ".1")
sleep 5

############################################
# --------------------------------------
#          importing GPOs
# --------------------------------------
############################################
# https://adsecurity.org/?p=3377
# https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/plan/security-best-practices/audit-policy-recommendations
# backup GPO https://learn.microsoft.com/en-us/powershell/module/grouppolicy/backup-gpo?view=windowsserver2022-ps&viewFallbackFrom=win10-ps
# import GPO https://learn.microsoft.com/en-us/powershell/module/grouppolicy/restore-gpo?view=windowsserver2022-ps&viewFallbackFrom=win10-ps
# -command "\\dc01\SYSVOL\shreklab.local\scripts\sysmon.exe -accepteula -i \\dc01\SYSVOL\shreklab.local\scripts\sysmonconfig.xml"
iwr -useb -o C:\Windows\SYSVOL\domain\scripts\sysmonconfig.xml https://raw.githubusercontent.com/Neo23x0/sysmon-config/master/sysmonconfig-export.xml
iwr -useb -o C:\Windows\SYSVOL\domain\scripts\sysmon.exe https://live.sysinternals.com/Sysmon.exe

new-gpo -name Auditing
new-gpo -name Sysmon
new-gpo -name "Powershell script block logging"
Import-GPO -BackupGpoName Auditing -TargetName Auditing -Path "C:\vagrant\gpos" #"\\VBOXSVR\vagrant\gpos"
Import-GPO -BackupGpoName Sysmon -TargetName Sysmon -Path "C:\vagrant\gpos" #"\\VBOXSVR\vagrant\gpos"
Import-GPO -BackupGpoName "Powershell script block logging" -TargetName "Powershell script block logging" -Path "C:\vagrant\gpos" #"\\VBOXSVR\vagrant\gpos"
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
net user $admin $adminpass /ADD /DOMAIN /Y
net group "Domain Admins" $admin /add /Y
net group "Enterprise Admins" $admin /add /Y
# net group "Domain Admins" vagrant /add /Y # dis for ADCS error fix?
# net user donkey "Passw0rd!" /ADD /DOMAIN /Y

# https://shrek.fandom.com/wiki/Category:Characters
# https://github.com/davidprowe/BadBlood
# install DSInternals to create SIDHistory attackable objects with BadBlood
Install-Module DSInternals -Force
cd C:\Windows\Temp
iwr -useb -o badblood.zip https://github.com/mncmb/BadBlood/archive/refs/heads/master.zip
expand-archive badblood.zip 
cd badblood\Badblood-master
. .\Invoke-BadBlood.ps1 -NonInteractive
# --------------------------------------
#         install ADCS
# --------------------------------------
############################################

# generate session as Enterprise admin, so that adcs enterprise cert can be installed later
$username = "$domain\$admin";
$password = $adminpass;
$securePassword = ConvertTo-SecureString $password -AsPlainText -Force; 
$credential = New-Object System.Management.Automation.PSCredential $username, $securePassword;
$sess = New-PSSession -Credential $credential

# adding ADCS
# taken partly from https://github.com/jfmaes/x33fcon-workshop/blob/main/dc/add-ons.ps1
Install-WindowsFeature Adcs-Cert-Authority -IncludeManagementTools
Invoke-Command -ScriptBlock {Install-AdcsCertificationAuthority -CAType EnterpriseRootCa -Force} -Session $sess
# ErrorId: 0  == Success
Install-PackageProvider NuGet -Force
Set-PSRepository PSGallery -InstallationPolicy Trusted
Install-Module ADCSTemplate -Force
add-WindowsFeature Adcs-Web-Enrollment
Install-AdcsWebEnrollment -Force
