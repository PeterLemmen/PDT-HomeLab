$Filename = '.\VMs.csv'
$File = Import-CSV $Filename
ForEach ($VM in $File)
{
    Write-Host $VM.VMName
    Write-Host $VM.ComputerName
}