param ( [String] $admin = "admin", 
        [String] $adminpass = "P@ssw0rd!")

$iface=$env:VAGRANT_PRIMARY_IFACE
$domain=$env:VAGRANT_DOMAIN_NAME
# admin
$admin=$env:VAGRANT_DA_NAME
$adminpass=$env:VAGRANT_DA_PASS
# user
$domuser=$env:VAGRANT_USER_NAME
$domuserpass=$env:VAGRANT_USER_PASS

$fqdn = "dc=" +(($domain.split(".")) -join ",dc=")
############################################
# --------------------------------------
#          install RSAT tools
# --------------------------------------
# install RSAT and ADDS tools
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
# import custom GPOs by 
# 1. creating a GPO
# 2. importing settings from backup GPO to created GPO
# 3. linking the GPO to domain context
############################################
# https://adsecurity.org/?p=3377
# https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/plan/security-best-practices/audit-policy-recommendations
# backup GPO https://learn.microsoft.com/en-us/powershell/module/grouppolicy/backup-gpo?view=windowsserver2022-ps&viewFallbackFrom=win10-ps
# Backup-Gpo -Name "GPOname" -Path C:\vagrant\GPOs\
# import GPO https://learn.microsoft.com/en-us/powershell/module/grouppolicy/restore-gpo?view=windowsserver2022-ps&viewFallbackFrom=win10-ps
# -command "\\dc01\SYSVOL\shreklab.local\scripts\sysmon.exe -accepteula -i \\dc01\SYSVOL\shreklab.local\scripts\sysmonconfig.xml"

# unzip admin templates for edge gpos 
# see https://learn.microsoft.com/en-us/deployedge/configure-microsoft-edge#1-download-and-install-the-microsoft-edge-administrative-template
# Expand-Archive C:\vagrant\powershell\dc\files\PolicyDefinitions.zip -DestinationPath C:\Windows\SYSVOL\domain\Policies

iwr -useb -o C:\Windows\SYSVOL\domain\scripts\sysmonconfig.xml https://raw.githubusercontent.com/Neo23x0/sysmon-config/master/sysmonconfig-export.xml
iwr -useb -o C:\Windows\SYSVOL\domain\scripts\sysmon.exe https://live.sysinternals.com/Sysmon.exe

new-gpo -name Auditing
new-gpo -name Sysmon
new-gpo -name "Powershell script block logging"
new-gpo -name "Edge Adblocker"

Import-GPO -BackupGpoName Auditing -TargetName Auditing -Path "C:\vagrant\gpos" #"\\VBOXSVR\vagrant\gpos"
Import-GPO -BackupGpoName Sysmon -TargetName Sysmon -Path "C:\vagrant\gpos" #"\\VBOXSVR\vagrant\gpos"
Import-GPO -BackupGpoName "Powershell script block logging" -TargetName "Powershell script block logging" -Path "C:\vagrant\gpos" #"\\VBOXSVR\vagrant\gpos"
Import-GPO -BackupGpoName "Edge Adblocker" -TargetName "Edge Adblocker" -Path "C:\vagrant\gpos"

new-gplink -name Auditing -Target $fqdn
new-gplink -name Sysmon -Target $fqdn
new-gplink -name "Powershell script block logging" -Target $fqdn
new-gplink -name "Edge Adblocker" -Target $fqdn

# deploy sysmon immediate task
# see for immediate task creation https://4sysops.com/archives/run-powershell-scripts-as-immediate-scheduled-tasks-with-group-policy/ or https://support.huntress.io/hc/en-us/articles/4404012795027-Deploying-Huntress-with-Group-Policy-GPO-and-Immediate-Scheduled-Task 
# c:\windows\system32\windowspowershell\v1.0\powershell.exe
# -command "new-item -type directory C:\Windows\Temp\sysmon; iwr -useb -o C:\Windows\Temp\sysmon\config.xml https://raw.githubusercontent.com/Neo23x0/sysmon-config/master/sysmonconfig-export.xml; iwr -useb -o C:\Windows\Temp\sysmon\sysmon.exe https://live.sysinternals.com/Sysmon.exe; C:\Windows\Temp\sysmon\sysmon.exe -accepteula -i C:\Windows\Temp\sysmon\config.xml"
$wallpaperpath = "C:\users\public\wallpaper.jpg"
copy-item "C:\vagrant\powershell\dc\files\wallpaper.jpg" $wallpaperpath
new-gpo -name "Admin Wallpaper"
Import-GPO -BackupGpoName "Admin Wallpaper" -TargetName "Admin Wallpaper" -Path "C:\vagrant\gpos" #"\\VBOXSVR\vagrant\gpos"
# check OU names 'Get-ADOrganizationalUnit -Filter 'Name -like "*"' | Format-Table Name, DistinguishedName -A'
#new-gplink -name "Admin Wallpaper" -Target $("OU=Domain Controllers,"+$fqdn)
new-gplink -name "Admin Wallpaper" -Target $fqdn

############################################
# --------------------------------------
#         Users
# --------------------------------------
# create some users manually
# configure Desktop and auto logon on DC
# start customized badblood
############################################
net user $admin $adminpass /ADD /DOMAIN /Y
net group "Domain Admins" $admin /add /Y
net group "Enterprise Admins" $admin /add /Y
# net group "Domain Admins" vagrant /add /Y # dis for ADCS error fix? -> resolved by generating session as Enterprise admin
net user $domuser $domuserpass /ADD /DOMAIN /Y

# https://shrek.fandom.com/wiki/Category:Characters
# https://github.com/davidprowe/BadBlood
# install DSInternals to create SIDHistory attackable objects with BadBlood
Write-host "###############"
Write-host "starting bad blood"
# Install-Module DSInternals -Force
cd C:\Windows\Temp
iwr -useb -o badblood.zip https://github.com/mncmb/BadBlood/archive/refs/heads/master.zip
expand-archive badblood.zip 
cd badblood\Badblood-master
. .\Invoke-BadBlood.ps1 -NonInteractive
cd C:\Windows\Temp

############################################
# --------------------------------------
#         install ADCS
# --------------------------------------
############################################
Write-host "###############"
Write-host "installing AD CS"
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
Write-host "ErrorId: 0  == Success"
