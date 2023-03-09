param ( [String] $domain, $dcip, $iface)

$fqdn = "dc=" +(($domain.split(".")) -join ",dc=")
$newOU = "UserAccounts"
New-ADOrganizationalUnit -Name "UserAccounts" -Path "$fqdn"

# all new users will be grouped here
$userOU = "ou=$newOU,$fqdn"
redirusr $userOU


# $username = "shrek"
# $passwd = "Swamp2022!"
# $passwd = ConvertTo-SecureString $passwd -AsPlainText -Force
# New-ADUser -Name $username -AccountPassword $passwd -Passwordneverexpires $true -Enabled $true
# Add-ADGroupMember -Identity "Domain Admins" -Members $username


function create-ADUser($username, $passwd, $description="")
{
    $passwd = ConvertTo-SecureString $passwd -AsPlainText -Force
    New-ADUser -Name $username -AccountPassword $passwd `
                -Passwordneverexpires $true -Enabled $true `
                -ChangePasswordAtLogon $false -Description $description
}


create-ADUser "donkey" "Passw0rd!"  "                                                                                                                         My Password was Passw0rd!"
create-ADUser
# move user to other OU 
# Get-ADUser -Identity shrek | Move-ADObject -TargetPath "OU=HR,DC=SHELLPRO,DC=LOCAL"
