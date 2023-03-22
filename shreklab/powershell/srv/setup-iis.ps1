# https://www.ionos.com/help/server-cloud-infrastructure/server-administration/installing-iis-on-a-server/
Install-WindowsFeature -name Web-Server -IncludeManagementTools
Install-WindowsFeature Web-Asp-Net45

$webroot = "C:\inetpub\wwwroot"
copy-item "C:\vagrant\powershell\srv\files\web\*" -Destination $webroot -recurse -force

cd $webroot
$uploaddir = "$webroot\upload"
md "upload" -force
$acl = Get-Acl $uploaddir
$AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("IIS_IUSRS", "FullControl", "Allow")
$acl.SetAccessRule($AccessRule)
$acl | Set-Acl $uploaddir