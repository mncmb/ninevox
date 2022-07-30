# Purpose: Install the GPO that allows windomain\vagrant to RDP
# source:  https://github.com/clong/DetectionLab
$domain = Get-ADDomain
$domain = $domain.DNSRoot
$domComp = ",dc=" +(($domain.split(".")) -join ",dc=")
$migtable = "c:\vagrant\resources\GPO\rdp_users\rdp_users.migtable"
$migtable_loc = $migtable + "local"

# Get-ChildItem -Recurse | Select-String "windomain" -List | select Path | ForEach-Object -Process {(Get-Content -path $_.Path ) -replace "windomain.local",$domain | Set-Content -Path $_.Path} 
(Get-Content -path $migtable ) -replace "windomain.local",$domain | Set-Content -Path $migtable_loc
Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Importing the GPO to allow windomain/vagrant to RDP..."
Import-GPO -BackupGpoName 'Allow Domain Users RDP' -Path "c:\vagrant\resources\GPO\rdp_users" -MigrationTable $migtable -TargetName 'Allow Domain Users RDP' -CreateIfNeeded

$OU = "ou=Workstations" + $domComp
$gPLinks = $null
$gPLinks = Get-ADOrganizationalUnit -Identity $OU -Properties name,distinguishedName, gPLink, gPOptions
$GPO = Get-GPO -Name 'Allow Domain Users RDP'
If ($gPLinks.LinkedGroupPolicyObjects -notcontains $gpo.path)
{
  New-GPLink -Name 'Allow Domain Users RDP' -Target $OU -Enforced yes
}
else
{
  Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Allow Domain Users RDP GPO was already linked at $OU. Moving On."
}
$OU = "ou=Servers" + $domComp
$gPLinks = $null
$gPLinks = Get-ADOrganizationalUnit -Identity $OU -Properties name,distinguishedName, gPLink, gPOptions
$GPO = Get-GPO -Name 'Allow Domain Users RDP'
If ($gPLinks.LinkedGroupPolicyObjects -notcontains $gpo.path)
{
    New-GPLink -Name 'Allow Domain Users RDP' -Target $OU -Enforced yes
}
else
{
  Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Allow Domain Users RDP GPO was already linked at $OU. Moving On."
}

remove-item $migtable_loc

gpupdate /force
