
param ( [String] $root= "C:\shares\", [String] $ShareDomUsers= "data",[String] $SharePublic= "public" )

$domain=$env:VAGRANT_DOMAIN_NAME
# admin
$admin=$env:VAGRANT_DA_NAME
$adminpass=$env:VAGRANT_DA_PASS

############################################
# --------------------------------------
#          create file share
# --------------------------------------
# create file share for domain users with full access
# 
############################################
# fileshare setup taken from https://github.com/jfmaes/x33fcon-workshop/blob/main/FS01/addons.ps1
# with some slight fixes
if ((Test-Path -Path "$root$ShareDomUsers") -eq $false){
    New-Item -ItemType directory -Path "$root$ShareDomUsers"
    echo "test secret" > "$root$ShareDomUsers\testpass.txt"
    New-SmbShare -Name $ShareDomUsers -Path "$root$ShareDomUsers" -FullAccess "Domain Users"
    # TODO: need to adjust $share here
    $acl = Get-Acl "$root$ShareDomUsers"
    $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("$domain\Domain Users", "FullControl", "Allow")
    $acl.SetAccessRule($AccessRule)
    $acl | Set-Acl "$root$ShareDomUsers"
}
# create share accessible by everyone
if ((Test-Path -Path "$root$SharePublic") -eq $false){
    New-Item -ItemType directory -Path "$root$SharePublic"
    echo "P@ssw0rd!" > "$root$SharePublic\passfile.txt"
    New-SmbShare -Name $SharePublic -Path "$root$SharePublic" -FullAccess "Domain Users"
    $acl = Get-Acl "$root$SharePublic"
    $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("$domain\Domain Users", "FullControl", "Allow")
    $acl.SetAccessRule($AccessRule)
    $acl | Set-Acl "$root$SharePublic"
}
# add user as a local admin
# net localgroup administrators adminUser /add

# Note: this is set to False not $false per the docs
# https://docs.microsoft.com/en-us/powershell/module/netsecurity/set-netfirewallprofile?view=windowsserver2022-ps
# Set-NetFirewallProfile -Profile Domain -Enabled False 

############################################
# --------------------------------------
#          install mssql
# --------------------------------------
# 
############################################
# based on https://github.com/Orange-Cyberdefense/GOAD/blob/main/ansible/roles/mssql/tasks/main.yml
# sql_instance_name: SQLEXPRESS
# download_url: https://download.microsoft.com/download/7/f/8/7f8a9c43-8c8a-4f7c-9f92-83c18d96b681/SQL2019-SSEI-Expr.exe
# md -Force "c:\Windows\Temp\mssql\media"
# iwr -useb -outfile "c:\Windows\Temp\mssql\sql_installer.exe" https://download.microsoft.com/download/7/f/8/7f8a9c43-8c8a-4f7c-9f92-83c18d96b681/SQL2019-SSEI-Expr.exe
# copy-item "C:\vagrant\powershell\fs\files\sql_conf.ini" "c:\Windows\Temp\mssql\sql_conf.ini"
# # "sa_password": "Sup1_sa_P@ssw0rd!",
# $svcaccount= "sql_svc"
# # https://stackoverflow.com/questions/10187837/granting-seservicelogonright-to-a-user-from-powershell
# function Add-ServiceLogonRight([string] $Username) {
#     Write-Host "Enable ServiceLogonRight for $Username"
# 
#     $tmp = New-TemporaryFile
#     secedit /export /cfg "$tmp.inf" | Out-Null
#     (gc -Encoding ascii "$tmp.inf") -replace '^SeServiceLogonRight .+', "`$0,$Username" | sc -Encoding ascii "$tmp.inf"
#     secedit /import /cfg "$tmp.inf" /db "$tmp.sdb" | Out-Null
#     secedit /configure /db "$tmp.sdb" /cfg "$tmp.inf" | Out-Null
#     rm $tmp* -ea 0
# }
# Add-ServiceLogonRight $svcaccount
# 
# $username = "$domain\$admin";
# $password = $adminpass;
# $securePassword = ConvertTo-SecureString $password -AsPlainText -Force; 
# $credential = New-Object System.Management.Automation.PSCredential $username, $securePassword;
# $sess = New-PSSession -Credential $credential
# Invoke-Command -ScriptBlock {."c:\Windows\Temp\mssql\sql_installer.exe" /configurationfile="c:\Windows\Temp\mssql\sql_conf.ini" /IACCEPTSQLSERVERLICENSETERMS /MEDIAPATH="c:\Windows\Temp\mssql\media" /QUIET /HIDEPROGRESSBAR } -Session $sess
# 
