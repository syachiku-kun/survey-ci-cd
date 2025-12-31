Set-StrictMode -Version 3.0
$PSDefaultParameterValues["*:Encoding"] = "utf8"
$OutputEncoding = [Text.Encoding]::UTF8
[Console]::OutputEncoding = [Text.Encoding]::UTF8
$FileNameWithoutExtension = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.name);
$FileLocation = (Split-Path -Path $MyInvocation.MyCommand.Path -Parent)
$Now = Get-Date -Format yyyyMMdd_HHmmss
$LogFileName = "${FileNameWithoutExtension}_${Now}.log"
$LogFile = Join-Path -Path $FileLocation -ChildPath $LogFileName
Start-Transcript $LogFile -append

#----------------------------------------------
# Define variables
# $OsName os name will be used in VM
# $OsVersion os version will be used in VM
# $VmPurpose purpose of the VM
# $VMPath if you want to check existing VMs
# PS C:\Users\xxxxx> Get-VM | Select-Object Name, Path | Format-Table -AutoSize
# Name                   Path
# ----                   ----
# CentOS Stream 9        E:\ProgramData\Microsoft\Windows\Hyper-V\CentOS Stream 9
# Debian 12.7.0          E:\ProgramData\Microsoft\Windows\Hyper-V\Debian 12.7.0
#
# $IsoPath path to the OS ISO file
# $VHDPath path to the VHDX file(auto completed)
# $VMSwitch existing virtual switch name
#----------------------------------------------
$OsName = "Ubuntu Desktop"
$OsVersion = "24.04.3"
$VmPurpose = "GitLab"
$VmName = "${OsName} ${OsVersion}(${VmPurpose})"
$VmMemoryStartupGigaBytes = 4
$IsoPath = "C:\Users\xxxxx\Desktop\system\os\Ubuntu Desktop\ubuntu-24.04.3-desktop-amd64.iso"
$VMPath = "E:\ProgramData\Microsoft\Windows\Hyper-V"
$VHDPath = "$VMPath\$VMName\Virtual Hard Disks\$VMName.vhdx"
$VHDGigaBytesSize = 50
$VMSwitch = "Hyper-V仮想スイッチ（外部）"
$VMCpuCount = 2

# get statue(before)
Get-VM | Select-Object Name, Path | Out-String -Width 4096
Get-Variable | Out-String -Width 4096

# create folder for VM
New-Item -ItemType Directory -Path $VMPath -Force

# create VM(generation 2)
# https://learn.microsoft.com/ja-jp/powershell/module/hyper-v/new-vm
New-VM -Name $VMName `
    -Generation 2 `
    -Path $VMPath `
    -MemoryStartupBytes ([UInt64]$VmMemoryStartupGigaBytes * 1GB) `
    -NewVHDPath $VHDPath `
    -NewVHDSizeBytes ([UInt64]$VHDGigaBytesSize * 1GB) `
    -SwitchName $VMSwitch

# set VM
# https://learn.microsoft.com/ja-jp/powershell/module/hyper-v/set-vm
Set-VM -VMName $vmName `
    -ProcessorCount $VMCpuCount `
    -StaticMemory -AutomaticCheckpointsEnabled $false

# set DVD drive
# https://learn.microsoft.com/ja-jp/powershell/module/hyper-v/add-vmdvddrive
Add-VMDvdDrive -VMName $VMName `
    -Path $IsoPath

# set firmware(boot order, secure boot)
# https://learn.microsoft.com/ja-jp/powershell/module/hyper-v/set-vmfirmware
Set-VMFirmware -VMName $VMName `
    -FirstBootDevice (Get-VMDvdDrive -VMName $VMName) `
    -EnableSecureBoot Off

# create initial checkpoint
# https://learn.microsoft.com/ja-jp/powershell/module/hyper-v/checkpoint-vm
Checkpoint-VM -Name $VMName `
    -SnapshotName "Init Checkpoint"

# get statue(after)
Get-VM | Select-Object Name, Path | Out-String -Width 4096
Get-Variable | Out-String -Width 4096

# start up the VM
# https://learn.microsoft.com/ja-jp/powershell/module/hyper-v/start-vm
Start-VM -Name $VMName

Write-Host "Completed. Press Enter to exit…" -ForegroundColor Yellow
[void] (Read-Host)

Stop-Transcript
