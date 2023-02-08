$admin=$env:VAGRANT_DA_NAME
$adminpass=$env:VAGRANT_DA_PASS
$domain=$env:VAGRANT_DOMAIN_NAME
$dcip=$env:VAGRANT_DC_IP
############################################
# --------------------------------------
#         customize admin
# --------------------------------------
# create some users manually
# configure Desktop and auto logon on DC
# start customized badblood
############################################

# does not seem to work 
# Remote Desktop Auto Login Powershell Script to create user dir https://gist.github.com/jdforsythe/48a022ee22c8ec912b7e
# cmdkey /generic:TERMSRV/$dcip /user:$domain\$admin /pass:$adminpass
# mstsc /v:$dcip
# set autologon as admin on DC
Write-host "###############"
Write-host "trying to set autologon"
set-ItemProperty -path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\" -name AutoAdminLogon -value 1 -force 
set-ItemProperty -path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\" -name DefaultUserName -value $admin -force 
set-ItemProperty -path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\" -name DefaultPassword -value $adminpass -force 
set-ItemProperty -path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\" -name DefaultDomainName -value $domain -force 

# set wallpaper, see here https://www.reddit.com/r/PowerShell/comments/selwdy/changing_the_desktop_background_for_a_specific/
#$HKU = Get-PSDrive HKU -ea silentlycontinue
##check HKU branch mount status
#if (!$HKU ) {
# # recreate a HKU as a PSDrive and navigate to it
# New-PSDrive -Name HKU -PsProvider Registry HKEY_USERS | out-null
#}
#$adminSID = (New-Object System.Security.Principal.NTAccount($admin)).Translate([System.Security.Principal.SecurityIdentifier]).Value
#copy-item "C:\vagrant\powershell\dc\files\wallpaper.jpg" $wallpaperpath
## new-item "HKU:\$($adminSID)\Control Panel\Desktop"
#Set-ItemProperty "HKU:\$($adminSID)\Control Panel\Desktop" -name "Wallpaper" -Value $wallpaperpath -force -Verbose

# add greeting
$action = New-ScheduledTaskAction -Execute "powershell.exe" -argument "start microsoft-edge:https://www.youtube.com/watch?v=L_jWHffIx5E"
$trigger = New-ScheduledTaskTrigger -AtLogon
$principal = New-ScheduledTaskPrincipal -UserId "$domain\$admin"
$settings = New-ScheduledTaskSettingsSet
$task = New-ScheduledTask -Action $action -Principal $principal -Trigger $trigger -Settings $settings
Register-ScheduledTask "Hey now" -InputObject $task