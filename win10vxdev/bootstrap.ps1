# activate RDP
echo "[INFO] setting RDP registry key:"
cmd /C 'reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections /t REG_DWORD /d 0 /f'
echo "[INFO] adding RDP firewall rule:"
cmd /C 'netsh advfirewall firewall set rule group="remote desktop" new enable=yes'
echo "[INFO] adding user to RDP group:" 
cmd /C 'net localgroup "remote desktop users" IEUser /add'

# winrm - Switch to private network
# powershell -InputFormat None -NoProfile -ExecutionPolicy Bypass -Command '$networkListManager = [Activator]::CreateInstance([Type]::GetTypeFromCLSID([Guid]"{DCB00C01-570F-4A9B-8D69-199FDBA5723B}")) ; $connections = $networkListManager.GetNetworkConnections() ; $connections | % {$_.GetNetwork().SetCategory(1)}'

# activate winrm
#sc config winrm start=auto
cmd /C "winrm quickconfig -q"

# activate openSSH
# use the script deployed by microsoft 
echo "[INFO] setting up SSH server:"
C:\BGinfo\openssh.ps1

# install chocolatey
echo "[INFO] installing chocolatey package manager:" 
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# install packages and create symlink to installs
echo "[INFO] run chocolatey installations:"
C:\vagrant\choco-install.ps1
cmd /C mklink /d C:\Users\IEUser\Desktop\tools C:\ProgramData\chocolatey\bin


# TODO: install and use puppet
# download from https://downloads.puppetlabs.com/windows/puppet5/
# https://downloads.puppetlabs.com/windows/puppet5/puppet-agent-x64-latest.msi
# msiexec /qn /norestart /i puppet-agent-<VERSION>-x64.msi
