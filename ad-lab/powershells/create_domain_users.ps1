
$domain = Get-ADDomain
$domain = $domain.DNSRoot
$dc = $env:COMPUTERNAME

Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Adding users"
net user shrek Myswamp2022! /ADD /DOMAIN /Y
net group "Domain Admins" shrek /add /Y

net user donkey "I<3youshrek" /ADD /DOMAIN /Y

net user pinocchio Wy_82ZZhiuhcVfYNsk2X5 /ADD /DOMAIN /Y
set-ADUser pinocchio -description "pw:Wy_82ZZhiuhcVfYNsk2X5"

# create constrainment user accounts
# source: https://github.com/Marshall-Hallenbeck/red_team_attack_lab/blob/main/ansible/roles/windows_domain_controller/tasks/set_constrainment.yml
Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) setting constrained and unconstrained delegation users"
net user 'UnconstrainedUser' Iamunconstrained2021! /ADD /DOMAIN /Y
net user 'ConstrainedUser' Iamconstrained2021! /ADD /DOMAIN /Y

$user = (Get-ADUser -Identity "UnconstrainedUser").DistinguishedName
Set-ADAccountControl -Identity $user -TrustedForDelegation $True
$user = (Get-ADUser -Identity "ConstrainedUser").DistinguishedName

Set-ADObject -Identity $user -Add @{"msDS-AllowedToDelegateTo" = @("CIFS/$dc","CIFS/$dc.$domain","CIFS/$dc.$domain/$domain")}

# create roastable user accounts
# sauce: https://github.com/Marshall-Hallenbeck/red_team_attack_lab/blob/main/ansible/roles/windows_domain_controller/tasks/set_roasting.yml
Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) setting kerberoastable and ASRep roastable users"
net user 'KerberoastMe' "P@ssw0rd!" /ADD /DOMAIN /Y
net user 'AsrepRoastMe' "P@ssw0rd!" /ADD /DOMAIN /Y

$user = (Get-ADUser -Identity "KerberoastMe").DistinguishedName
Set-ADUser -Identity $user -ServicePrincipalNames @{Add="KerberoastMe/$domain"}
Set-ADUser -Identity $user -KerberosEncryptionType RC4
$user = (Get-ADUser -Identity "AsrepRoastMe").DistinguishedName
Set-ADAccountControl -Identity $user -DoesNotRequirePreAuth $True


# create OUs
Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) creating base OUs"
New-ADOrganizationalUnit -Name "Servers"
New-ADOrganizationalUnit -Name "Workstations"