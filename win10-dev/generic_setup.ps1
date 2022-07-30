Write-Host "creating basic desktop shortcut to choco dir"
# create destkop shortcut to choco tools
New-Item -ItemType SymbolicLink -Path $($HOME+'\Desktop\choco') -Target 'C:\ProgramData\chocolatey\lib' -Force
Write-Host "installing common utlis"
# install basic utils
choco install -y --limit-output --no-progress git 7zip chocolateygui boxstarter

# update so that git is in PATH of current powershell session
# script is part of chocolatey
# Update-SessionEnvironment 
refreshenv

Write-Host "finished basic setup"