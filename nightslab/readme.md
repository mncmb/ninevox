# nights_lab
Flat network, AD template. Elastic container project in the mix.

`As long as the firewall stands, the dead cannot pass.`

Vagrantfile for minimal AD config and setup

Also includes a build of the [elastic container project](https://github.com/peasead/elastic-container). Blogpost [here](https://www.elastic.co/de/security-labs/the-elastic-container-project)

## common post built tasks
create some users
```powershell
net user <USER> <PASS> /domain /add
net groups "Domain Admins" <USER> /add
```

```powershell
$user = "shrek"
$pw = ConvertTo-SecureString "Swamp2022!" -AsPlainText -Force
New-ADUser -Name $user -AccountPassword $pw -Passwordneverexpires $true -Enabled $true
Add-ADGroupMember -Identity "Domain Admins" -Members $user


$credential = New-Object System.Management.Automation.PSCredential $user,$pw
$session = New-PSSession -ComputerName DC01 -Credential $credential

# this here should work
Invoke-Command -Session $session -ScriptBlock {Start-Process -FilePath "C:\Windows\System32\cmd.exe" -LoadUserProfile -ArgumentList "/c dir" }


Invoke-Command -Session $session -ScriptBlock { $secpasswd = ConvertTo-SecureString $Using:pass -AsPlainText -Force; $cred = New-Object System.Management.Automation.PSCredential ($Using:user, $secpasswd);Start-Process -FilePath "C:\Windows\System32\cmd.exe" -Credential $credential -LoadUserProfile -ArgumentList "/c dir" }
```

autodaminlogon
```powershell
set-ItemProperty -path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\" -name AutoAdminLogon -value 1 -force 
set-ItemProperty -path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\" -name DefaultUserName -value $admin -force 
set-ItemProperty -path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\" -name DefaultPassword -value $adminpass -force 
set-ItemProperty -path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\" -name DefaultDomainName -value $domain -force 
```


create more users and other stuff 
```powershell
# clone the repo
git clone https://github.com/davidprowe/badblood.git
#Run Invoke-badblood.ps1
./badblood/invoke-badblood.ps1
```

create computers in specific OU. see also https://learn.microsoft.com/en-us/previous-versions/windows/it-pro/windows-server-2012-r2-and-2012/cc771655(v=ws.11)
```powershell
add-computer -domainname <domain> -cred <domain\administrator> -Passthru -OUPath OU=xxx,DC=<Domain>,DC=<Domain>
```

## elastic 
While installing agent with the provided command, use insecure flag to ignore cert error.  
```powershell
...
.\elastic-agent.exe install --insecure --url=... --enrollment-token=...
```

- change fleet server host and output url under `fleet > settings` tab