
Clear

$cred = Get-Credential HOME\p.lemmen

$Filename = '.\VMs.csv'
$File = Import-CSV $Filename

ForEach ($VM in $File)
{

    Write-Host $VM.VMName
    Write-Host $VM.ComputerName

    #
    Write-Host 'Make a backup of the current VM Template Disk before doing any modifications'
    #
    $Session = New-PSSession -ComputerName HOME-RACK002 -Credential $Cred
    Invoke-Command -Session $Session -Scriptblock {
        $var = $args[0]
        Stop-VM -Name $var.VMName -Force
        Write-Host 'VM Stopped'
        $path = 'E:\VMs\Virtual Hard Disks\' + $var.VMName + '.vhdx'
        Copy-Item -Path $path  -Destination 'E:\VMs\Virtual Hard Disks\Backup' -Force
        Write-Host 'Disk Copied'
        Start-VM -Name $var.VMName
        Write-Host 'VM Started'
    } -ArgumentList $VM
    Remove-PSSession $Session


    Write-Host 'Wait 5 Minutes to enable startup of the VM before logging on...'
    Start-Sleep -Seconds 300

    #
    Write-Host 'Logon to the VM to trigger an Sysprep'
    #
    $Session = New-PSSession -ComputerName $VM.ComputerName -Credential $Cred
    Invoke-Command -Session $Session -Scriptblock {
        $process = Start-Process -FilePath C:\Windows\System32\Sysprep\Sysprep.exe -ArgumentList '/generalize /oobe /shutdown /quiet' -PassThru
        $process.WaitForExit()
        WriteHost 'Sysprep ended with exit code: ' $process.ExitCode
    }
    Remove-PSSession $Session

    Write-Host 'Wait 10 Minutes for the Sysprep & shutdown of the VM'
    Start-Sleep -Seconds 600

    #
    Write-Host 'Copy the Syspreped disk to the template location. Afterwards copy the original (backuped) disk back.'
    #
    $Session = New-PSSession -ComputerName HOME-RACK002 -Credential $Cred
    Invoke-Command -Session $Session -Scriptblock {
        $var = $args[0]
        $path1 = 'E:\VMs\Virtual Hard Disks\' + $var.VMName + '.vhdx'
        $path2 = 'E:\Base VHD\' + $var.VMName + '-SYSPREPED.vhdx'
        $path3 = 'E:\VMs\Virtual Hard Disks\Backup\' + $var.VMName + '.vhdx'

        Copy-Item -Path $path1 -Destination $path2 -Force
        Write-Host 'New Base disk copied'
        Copy-Item -Path $path3 -Destination 'E:\VMs\Virtual Hard Disks' -Force 
        Write-Host 'Backup disk restored'

        Start-VM -Name $var.VMName
    } -ArgumentList $VM
    Remove-PSSession $Session
} 