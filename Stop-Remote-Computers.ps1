Clear
$cred = Get-Credential HOME\p.lemmen
$Session = New-PSSession -ComputerName HOME-RACK001 -Credential $Cred
Invoke-Command -Session $Session -Scriptblock {Stop-Computer -Force}
Remove-PSSession $Session

$Session = New-PSSession -ComputerName HOME-RACK003 -Credential $Cred
Invoke-Command -Session $Session -Scriptblock {Stop-Computer -Force}
Remove-PSSession $Session