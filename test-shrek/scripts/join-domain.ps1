# Purpose: Joins a Windows host to the windomain.local domain which was created with "create-domain.ps1".
# Source: https://github.com/StefanScherer/adfs2
# source:  https://github.com/clong/DetectionLab

param ([String] $ip, [String] $domain,[String] $dns )

$hostsFile = "c:\Windows\System32\drivers\etc\hosts"

Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Joining the domain..."

Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) First, set DNS to DC to join the domain..."
$newDNSServers = $dns
$adapters = Get-WmiObject Win32_NetworkAdapterConfiguration | Where-Object {$_.IPAddress -match "192.168.56."}
# Don't do this in Azure. If the network adatper description contains "Hyper-V", this won't apply changes.
# Specify the DC as a WINS server to help with connectivity as well
$adapters | ForEach-Object {if (!($_.Description).Contains("Hyper-V")) {$_.SetDNSServerSearchOrder($newDNSServers); $_.SetWINSServer($newDNSServers, "")}}

Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Now join the domain..."
$hostname = $(hostname)
$user = "$domain\vagrant"
$pass = ConvertTo-SecureString "vagrant" -AsPlainText -Force
$DomainCred = New-Object System.Management.Automation.PSCredential $user, $pass
$OUworkstations =  "ou=Workstations,dc=" +(($domain.split(".")) -join ",dc=")
$OUservers =  "ou=Servers,dc=" +(($domain.split(".")) -join ",dc=")

# Place the computer in the correct OU based on hostname
# Retry up to 3 times. Sleep 15 seconds between tries.
If (($hostname -match "srv") -or ($hostname -eq "exchange") -or ($hostname -eq "server") -or ($hostname -eq "file")) {
  $tries = 0
  While ($tries -lt 3) {
    Try {
      $tries += 1
      Add-Computer -DomainName $domain -credential $DomainCred -PassThru -ErrorAction Stop -OUPath $OUservers  
      Break
    } Catch {
      $tries += 1
      Write-Host $_.Exception.Message
      Start-Sleep 15
    }
  }
  # Attempt to fix Issue #517
  Set-ItemProperty -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Control' -Name 'WaitToKillServiceTimeout' -Value '500' -Type String -Force -ea SilentlyContinue
  New-ItemProperty -LiteralPath 'HKCU:\Control Panel\Desktop' -Name 'AutoEndTasks' -Value 1 -PropertyType DWord -Force -ea SilentlyContinue
  Set-ItemProperty -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Control\SessionManager\Power' -Name 'HiberbootEnabled' -Value 0 -Type DWord -Force -ea SilentlyContinue
} ElseIf ($hostname -imatch "win10") {
  Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Adding Win10 to the domain. Sometimes this step times out. If that happens, just run 'vagrant reload win10 --provision'" #debug
  Add-Computer -DomainName $domain -credential $DomainCred -OUPath $OUworkstations
} Else {
  Add-Computer -DomainName $domain -credential $DomainCred -PassThru
}

# Stop Windows Update
Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Disabling Windows Updates and Windows Module Services"
Set-Service wuauserv -StartupType Disabled
Stop-Service wuauserv
Set-Service TrustedInstaller -StartupType Disabled
Stop-Service TrustedInstaller
