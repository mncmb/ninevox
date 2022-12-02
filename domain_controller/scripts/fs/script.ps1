
param ( [String] $domain, [String] $iface, [String] $ip_host_part)

$domain = "shreklab.local"
# fileshare setup taken from https://github.com/jfmaes/x33fcon-workshop/blob/main/FS01/addons.ps1
$ShareName = "data"
$root = "C:\"

New-Item -ItemType directory -Path "$root\$ShareName"
echo "top secret" > "$root\$ShareName\test.txt"
New-SmbShare -Name $ShareName -Path "$root\$ShareName" -FullAccess "Domain Users"


# TODO: need to adjust $share here
$acl = Get-Acl "$root\$ShareName"
$AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("$domain\Domain Users", "FullControl", "Allow")
$acl.SetAccessRule($AccessRule)
$acl | Set-Acl "$root\$ShareName"


# add user as a local admin
# net localgroup administrators "shreklab.local"\adminUser /add


# Note: this is set to False not $false per the docs
# https://docs.microsoft.com/en-us/powershell/module/netsecurity/set-netfirewallprofile?view=windowsserver2022-ps
# Set-NetFirewallProfile -Profile Domain -Enabled False 