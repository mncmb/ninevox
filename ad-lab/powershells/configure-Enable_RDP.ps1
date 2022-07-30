# Purpose: Install the GPO that specifies the WEF collector
$domain = Get-ADDomain
$domain = $domain.DNSRoot
$domComp = ",dc=" +(($domain.split(".")) -join ",dc=")
$GPOName = 'Enable RDP' 
$GPOPath = "c:\vagrant\resources\GPO\Enable_RDP"

Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Importing the GPO $GPOName..."
Import-GPO -BackupGpoName $GPOName -Path $GPOPath -TargetName $GPOName -CreateIfNeeded
$OU = "ou=Workstations" + $domComp
$gPLinks = $null
$gPLinks = Get-ADOrganizationalUnit -Identity $OU -Properties name,distinguishedName, gPLink, gPOptions
$GPO = Get-GPO -Name $GPOName
If ($gPLinks.LinkedGroupPolicyObjects -notcontains $gpo.path)
{
    New-GPLink -Name $GPOName -Target $OU -Enforced yes
}
else
{
    Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) $GPOName was already linked at $OU. Moving On."
}
$OU = "ou=Servers" + $domComp
$gPLinks = $null
$gPLinks = Get-ADOrganizationalUnit -Identity $OU -Properties name,distinguishedName, gPLink, gPOptions
$GPO = Get-GPO -Name $GPOName
If ($gPLinks.LinkedGroupPolicyObjects -notcontains $gpo.path)
{
    New-GPLink -Name $GPOName -Target $OU -Enforced yes
}
else
{
    Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) $GPOName was already linked at $OU. Moving On."
}
# $OU = "ou=Domain Controllers" + $domComp
# $gPLinks = $null
# $gPLinks = Get-ADOrganizationalUnit -Identity $OU -Properties name,distinguishedName, gPLink, gPOptions
# If ($gPLinks.LinkedGroupPolicyObjects -notcontains $gpo.path)
# {
#     New-GPLink -Name $GPOName -Target $OU -Enforced yes
# }
# else
# {
#     Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) $GPOName was already linked at $OU. Moving On."
# }
gpupdate /force
