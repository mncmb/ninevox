# bigwhoop
`AD amusement park.`

Vagrant template to provision an active directory domain in a flat network environment. 
Also includes a setup script for the elastic container project.

This is a minimal AD domain installation and was designed as such. Use some type of `AD generator` to misconfigure it. 

![netplan whoop](../pics/whoop.jpg)

## AD generation tools
- create users, kerberoastable, asreproastable, misconfigured ACLs, ...
```powershell
# clone the repo
git clone https://github.com/davidprowe/badblood.git
# run 
./badblood/invoke-badblood.ps1
```
- alternatively check out [vulnAD](https://github.com/WazeHell/vulnerable-AD)
- or the pretty great [adsec](https://github.com/cfalta/adsec) repository
- or wait for the release of my AD generator some time later this year 


## Common post built tasks
- create some users
```powershell
net user <USER> <PASS> /domain /add
net groups "Domain Admins" <USER> /add
```
- same in powershell plus some login stuff
```powershell
$admin = "chonk"
$adminpass = "Passw0rd!" 
$pw = ConvertTo-SecureString $adminpass -AsPlainText -Force
New-ADUser -Name $user -AccountPassword $pw -Passwordneverexpires $true -Enabled $true
Add-ADGroupMember -Identity "Domain Admins" -Members $user

# create the home dir for the freshly created user by doing a login
$credential = New-Object System.Management.Automation.PSCredential $user,$pw
$session = New-PSSession -ComputerName DC01 -Credential $credential
Invoke-Command -Session $session -ScriptBlock {Start-Process -FilePath "C:\Windows\System32\cmd.exe" -LoadUserProfile -ArgumentList "/c dir" }
```
- configure autodaminlogon for the newely created user (afaik does not work unless the user has logged in / homedir was created)
```powershell
set-ItemProperty -path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\" -name AutoAdminLogon -value 1 -force 
set-ItemProperty -path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\" -name DefaultUserName -value $admin -force 
set-ItemProperty -path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\" -name DefaultPassword -value $adminpass -force 
set-ItemProperty -path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\" -name DefaultDomainName -value $domain -force 
```
- create computers in specific OU. see [MS documentation](https://learn.microsoft.com/en-us/previous-versions/windows/it-pro/windows-server-2012-r2-and-2012/cc771655(v=ws.11))
```powershell
add-computer -domainname <domain> -cred <domain\administrator> -Passthru -OUPath OU=xxx,DC=<Domain>,DC=<Domain>
```


## elastic container project
You have to manually perform different post install tasks when using the elastic container project.
Everything is described in the [accompanying blogpost from elastic](https://www.elastic.co/de/security-labs/the-elastic-container-project). 

After setting up elastic with fleet through the script, the following steps have to be performed.

- change fleet server host and output url under `fleet > settings` tab to the respective interface (probably `Ethernet 2`)
- creating a fleet policy
- create agent policy
- Enabling Elastic’s Prebuilt Detection Rules
- Enrolling an Elastic Agent

when using the elastic container project
While installing the agent in the step `Enrolling an Elastic Agent`, use the insecure flag to ignore certifcate based errors.  
```powershell
...
.\elastic-agent.exe install --insecure --url=... --enrollment-token=...
```

Depending on the version of elastic, I have encountered errors with different components of the agents not accepting the self signed certificate.  
One solution to this problem is to extract the certs from the server and import them in the local system.

Keep an eye out for updates to [the project](https://github.com/peasead/elastic-container), which is still a godsend compared to manually setting it up.