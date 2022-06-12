# Purpose: Install the GPO that specifies the WEF collector
# source:  https://github.com/clong/DetectionLab
$domain = Get-ADDomain
$domain = $domain.DNSRoot
$domComp = ",dc=" +(($domain.split(".")) -join ",dc=")

Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Importing the GPO to enable Powershell Module, ScriptBlock and Transcript logging..."
Import-GPO -BackupGpoName 'Powershell Logging' -Path "c:\vagrant\resources\GPO\powershell_logging" -TargetName 'Powershell Logging' -CreateIfNeeded
$OU = "ou=Workstations" + $domComp
$gPLinks = $null
$gPLinks = Get-ADOrganizationalUnit -Identity $OU -Properties name,distinguishedName, gPLink, gPOptions
$GPO = Get-GPO -Name 'Powershell Logging'
If ($gPLinks.LinkedGroupPolicyObjects -notcontains $gpo.path)
{
    New-GPLink -Name 'Powershell Logging' -Target $OU -Enforced yes
}
else
{
    Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Powershell Logging was already linked at $OU. Moving On."
}
$OU = "ou=Servers" + $domComp
$gPLinks = $null
$gPLinks = Get-ADOrganizationalUnit -Identity $OU -Properties name,distinguishedName, gPLink, gPOptions
$GPO = Get-GPO -Name 'Powershell Logging'
If ($gPLinks.LinkedGroupPolicyObjects -notcontains $gpo.path)
{
    New-GPLink -Name 'Powershell Logging' -Target $OU -Enforced yes
}
else
{
    Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Powershell Logging was already linked at $OU. Moving On."
}
$OU = "ou=Domain Controllers" + $domComp
$gPLinks = $null
$gPLinks = Get-ADOrganizationalUnit -Identity $OU -Properties name,distinguishedName, gPLink, gPOptions
If ($gPLinks.LinkedGroupPolicyObjects -notcontains $gpo.path)
{
    New-GPLink -Name 'Powershell Logging' -Target $OU -Enforced yes
}
else
{
    Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Powershell Logging was already linked at $OU. Moving On."
}
gpupdate /force
