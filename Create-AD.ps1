Install-windowsfeature AD-domain-services
Install-WindowsFeature RSAT-AD-AdminCenter
Install-WindowsFeature RSAT-ADDS-Tools

Import-Module ADDSDeployment

Install-ADDSForest `
 -CreateDnsDelegation:$false `
 -DatabasePath "C:\Windows\NTDS" `
 -DomainMode "Win2012R2" `
 -DomainName "AzurePoc.hybrid" `
 -DomainNetbiosName "AzurePoc" `
 -ForestMode "Win2012R2" `
 -InstallDns:$true `
 -LogPath "C:\Windows\NTDS" `
 -NoRebootOnCompletion:$true `
 -SysvolPath "C:\Windows\SYSVOL" `
 -Force:$true

 Add-DnsServerForwarder -IPAddress 8.8.8.8 -PassThru
 Add-DnsServerForwarder -IPAddress 8.8.8.4 -PassThru

 Restart-Computer
