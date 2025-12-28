Set-StrictMode -Version 3.0
$PSDefaultParameterValues["*:Encoding"] = "utf8"
$OutputEncoding = [Text.Encoding]::UTF8
[Console]::OutputEncoding = [Text.Encoding]::UTF8
$MyFileNameWithoutExt = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.name);
$Now = Get-Date -Format yyyyMMdd_HHmmss
$LogFile = "${MyFileNameWithoutExt}_${Now}.log"
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
$IsoPath = "C:\Users\xxxxx\Desktop\System\os\Ubuntu Desktop\ubuntu-24.04.3-desktop-amd64.iso"
$VMPath = "E:\ProgramData\Microsoft\Windows\Hyper-V\$VMName"
$VHDPath = "$VMPath\$VMName.vhdx"
$VHDGigaBytesSize = 50GB
$VMSwitch = "Hyper-V仮想スイッチ（外部）"     # 既存の仮想スイッチ名
$VMCpuCount = 2

# get statue(before)
Get-VM | ForEach-Object {
    $vm = $_

    $proc = Get-VMProcessor -VMName $vm.Name
    $mem = Get-VMMemory    -VMName $vm.Name
    $fw = Get-VMFirmware  -VMName $vm.Name
    $nics = @(Get-VMNetworkAdapter -VMName $vm.Name)
    $dvds = @(Get-VMDvdDrive       -VMName $vm.Name)
    $vhds = @(Get-VMHardDiskDrive  -VMName $vm.Name)

    $max = @($nics.Count, $dvds.Count, $vhds.Count | Measure-Object -Maximum).Maximum
    if (-not $max -or $max -lt 1) { $max = 1 }

    for ($i = 0; $i -lt $max; $i++) {
        $nic = if ($i -lt $nics.Count) { $nics[$i] } else { $null }
        $dvd = if ($i -lt $dvds.Count) { $dvds[$i] } else { $null }
        $vhd = if ($i -lt $vhds.Count) { $vhds[$i] } else { $null }

        @(
            "Name           : $($vm.Name)"
            "VMPath         : $($vm.Path)"
            "Generation     : $($vm.Generation)"
            "MemoryStartup  : $([math]::Round($vm.MemoryStartup / 1GB, 2)) GB"
            "CPUCount       : $($proc.Count)"
            "StaticMemory   : $(-not $mem.DynamicMemoryEnabled)"
            "AutoCheckpoint : $($vm.AutomaticCheckpointsEnabled)"
            "SwitchName     : $($nic.SwitchName)"
            "ISOPath        : $($dvd.Path)"
            "VHDPath        : $($vhd.Path)"
            "SecureBoot     : $($fw.SecureBoot)"
            "FirstBootDev   : $($fw.FirstBootDevice)"
            ""
        ) -join "`r`n"
    }
} | Out-String -Width 4096


# create folder for VM
New-Item -ItemType Directory -Path $VMPath -Force

# create VM(generation 2)
# https://learn.microsoft.com/ja-jp/powershell/module/hyper-v/new-vm
New-VM -Name $VMName `
    -Generation 2 `
    -Path $VMPath `
    -MemoryStartupBytes ($VmMemoryStartupGigaBytes * 1GB) `
    -NewVHDPath $VHDPath `
    -NewVHDSizeBytes ($VHDGigaBytesSize * 1GB) `
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

# 起動順序（DVD優先にしてインストールへ）
# set firmware(boot order, secure boot)
# https://learn.microsoft.com/ja-jp/powershell/module/hyper-v/set-vmfirmware
Set-VMFirmware -VMName $VMName `
    -FirstBootDevice (Get-VMDvdDrive -VMName $VMName) `
    -EnableSecureBoot Off

# get statue(after)
Get-VM | ForEach-Object {
    $vm = $_

    $proc = Get-VMProcessor -VMName $vm.Name
    $mem = Get-VMMemory    -VMName $vm.Name
    $fw = Get-VMFirmware  -VMName $vm.Name
    $nics = @(Get-VMNetworkAdapter -VMName $vm.Name)
    $dvds = @(Get-VMDvdDrive       -VMName $vm.Name)
    $vhds = @(Get-VMHardDiskDrive  -VMName $vm.Name)

    $max = @($nics.Count, $dvds.Count, $vhds.Count | Measure-Object -Maximum).Maximum
    if (-not $max -or $max -lt 1) { $max = 1 }

    for ($i = 0; $i -lt $max; $i++) {
        $nic = if ($i -lt $nics.Count) { $nics[$i] } else { $null }
        $dvd = if ($i -lt $dvds.Count) { $dvds[$i] } else { $null }
        $vhd = if ($i -lt $vhds.Count) { $vhds[$i] } else { $null }

        @(
            "Name           : $($vm.Name)"
            "VMPath         : $($vm.Path)"
            "Generation     : $($vm.Generation)"
            "MemoryStartup  : $([math]::Round($vm.MemoryStartup / 1GB, 2)) GB"
            "CPUCount       : $($proc.Count)"
            "StaticMemory   : $(-not $mem.DynamicMemoryEnabled)"
            "AutoCheckpoint : $($vm.AutomaticCheckpointsEnabled)"
            "SwitchName     : $($nic.SwitchName)"
            "ISOPath        : $($dvd.Path)"
            "VHDPath        : $($vhd.Path)"
            "SecureBoot     : $($fw.SecureBoot)"
            "FirstBootDev   : $($fw.FirstBootDevice)"
            ""
        ) -join "`r`n"
    }
} | Out-String -Width 4096


# start up the VM
# https://learn.microsoft.com/ja-jp/powershell/module/hyper-v/start-vm
Start-VM -Name $VMName
