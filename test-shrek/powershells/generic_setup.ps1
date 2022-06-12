# create destkop shortcut to choco tools
New-Item -ItemType SymbolicLink -Path $($HOME+'\Desktop\choco') -Target 'C:\ProgramData\chocolatey\lib'

# install basic utils
choco install -y git 7zip chocolateygui

# update so that git is in PATH of current powershell session
# script is part of chocolatey
# Update-SessionEnvironment 
refreshenv

# create local admin 
# pick pw from rockyou
net user ladmin "liverpoolfc" /ADD 
net localgroup Administrators ladmin /add  
net localgroup "Remote Management Users" ladmin /add

# set natnetwork to priority
# https://www.windowscentral.com/how-change-priority-order-network-adapters-windows-10
Set-NetipInterface -InterfaceAlias Ethernet -InterfaceMetric 1
Set-NetipInterface -InterfaceAlias Ethernet2 -InterfaceMetric 9
.\logging.ps1