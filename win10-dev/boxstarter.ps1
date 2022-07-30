Import-Module Boxstarter.Chocolatey
Set-WindowsExplorerOptions -EnableShowHiddenFilesFoldersDrives -EnableShowProtectedOSFiles -EnableShowFileExtensions
Set-BoxstarterTaskbarOptions -Size Small

# choco install IIS-WebServerRole -source windowsfeatures

# install terminal dependency bc of chocolatey issue https://github.com/mkevenaar/chocolatey-packages/issues/124
$archiveUrl = 'https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx'
$archiveName = Split-Path -Leaf $archiveUrl
$archivePath = "$env:TEMP\$archiveName"
(New-Object System.Net.WebClient).DownloadFile($archiveUrl, $archivePath)
Add-AppxPackage $archivePath
Remove-Item $archivePath
# install terminal
choco install -y --limit-output --no-progress microsoft-windows-terminal 
