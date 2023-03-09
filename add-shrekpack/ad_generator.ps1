param([Parameter(Mandatory=$true)] $JSONfile, $domain="shrek.lab")
$Global:BadPasswords = @("Spring2023!","Summer2023!","Fall2023!","Winter2023!","Fairy2023!","Changeme123!","P@ssw0rd","Shrek2023!")

function Create-fairyPassword(){
    if ((get-random -Maximum 100) -lt 10){
        return Get-Random -InputObject $Global:BadPasswords
    }
    else{
        
    }
    
    $goodpass = 
    return 
}

#Write-host $json
function Create-fairyOU([Parameter(Mandatory=$true)] $name,[Parameter(Mandatory=$true)] $path){
    $OUfullpath = "ou=$name,$path"
    if (Get-ADOrganizationalUnit -Filter "distinguishedName -eq '$OUfullpath'") {
        Write-Host "[OU_CREATE] OU already exists $OUfullpath."
    } else {
        New-ADOrganizationalUnit -Name $name -Path $path
        Write-Host "[OU_CREATE] OU created $OUfullpath."
    }
}

function Create-fairyGroup($name,$path){
    $groupfullpath = "cn=$name,$path"
    # -SamAccountName RODCAdmins -DisplayName "RODC Administrators" -Description "Members of this group are RODC Administrators" -Path "CN=Users,DC=Fabrikam,DC=Com"
    if (Get-ADgroup -Filter "distinguishedName -eq '$groupfullpath'") {
        Write-Host "[GROUP_CREATE] Group already exists $groupfullpath."
    }
    else {
        New-ADGroup -Name "$name" -GroupCategory Security -GroupScope Global -Path "$path"
        Write-Host "[GROUP_CREATE] Group created $groupfullpath."   
    } 
}

function Create-fairyUser($username, $passwd, $description="", $ou="", $groups=""){
    if (!($passwd)){
        $passwd = Create-fairyPassword 
    }
    if (!(Get-ADUser -Filter "sAMAccountName -eq '$username'")) {
        $passwd = ConvertTo-SecureString $passwd -AsPlainText -Force
        New-ADUser -Name $username -AccountPassword $passwd `
                    -Passwordneverexpires $true -Enabled $true `
                    -ChangePasswordAtLogon $false -Description $description 
        write-host "[USER_CREATE] User created NAME: $username, OU: $ou, GROUPS: $groups"
        if ($ou){ # if ou path was given
            Get-ADUser -Identity $username | Move-ADObject -TargetPath "$ou" 
        }
        if ($groups){
            foreach ($group in $groups){
                Add-ADGroupMember -Identity "$group" -Members $username 
            }
        }
    }
    else {
        Write-Host "[USER_CREATE] $username already exists."
    }
}



function invoke-shrekpack(){
    write-host "reading $JSONfile"
    $json = (get-content $JSONfile | Convertfrom-json)
    # create base OU
    $topOU = "FairyFolk"
    $fqdn = "dc=" +(($domain.split(".")) -join ",dc=")
    $defaultOU = "ou=$topOU,$fqdn"
    Create-fairyOU -Name "$topOU" -Path "$fqdn"
    Write-Host "[REDIRUSR] redirecting newly created users to $defaultOU"
    redirusr $defaultOU

    foreach ($ou in $json.ou){
        Create-fairyOU -Name "$ou" -Path "$defaultOU"
        # OUdeletion get-ADOrganizationalUnit "ou=san_ricardo,$fqdn" | Set-ADObject -ProtectedFromAccidentalDeletion:$false -PassThru | Remove-ADOrganizationalUnit
    }

    foreach ($countrygroup in $json.groups.PSObject.Properties){
        foreach ($group in $countrygroup.Value){
            Create-fairyGroup $group "OU=$($countrygroup.Name),$defaultOU"
        }
    }

    foreach ($user in $json.users){
        Write-Host "test"
        if ($user.ou){
            $ou = "OU=$($user.ou),$defaultOU"
        } else { $ou = "" }
        Create-fairyUser -username $user.username -passwd $user.password -description $user.description -ou $ou -groups $user.groups
    }
}

invoke-shrekpack