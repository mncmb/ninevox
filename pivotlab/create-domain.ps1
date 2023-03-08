 param ( [String] $domain, $dcip, $iface)

$safemodeAdminPW = "Sup3rSecureP@ssw0rd!"
$Secure_String_Pwd = ConvertTo-SecureString $safemodeAdminPW -AsPlainText -Force

Set-NetIPInterface -InterfaceAlias $iface -InterfaceMetric 10

# install AD
$domainMode = "Win2012R2"
Import-Module ServerManager
Add-WindowsFeature RSAT-AD-PowerShell,RSAT-AD-AdminCenter, RSAT-ADDS-Tools
Install-windowsfeature AD-domain-services, RSAT-ADDS
import-module ADDSDeployment
write-host "setting up domain"

# vagrant attempts to do graceful shutdown after ADDSForest 
# "==> dc01: Attempting graceful shutdown of VM..."
# also ends with a "WinRM::WinRMAuthorizationError"
# https://github.com/dbroeglin/windows-lab/issues/1
# https://stackoverflow.com/questions/69482240/provisioning-windows-vm-with-vagrant-cannot-execute-remote-winrm-commands
# https://groups.google.com/g/vagrant-up/c/JNMOCYpHSt8
# 
# probably related to some winrm timeout until after VM is restarted
try {
        Install-ADDSForest `
                -SafeModeAdministratorPassword $Secure_String_Pwd `
                -DomainMode $domainMode `
                -DomainName $domain `
                -ForestMode $domainMode `
                -InstallDns `
                -Force `
                -NoRebootOnCompletion `
                -ErrorAction Stop

}
catch {
        Write-Host "[ERROR]:" $_ 
}
Write-host "AD installed, DC promoted. "
