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
$IsoPath = "C:\Users\xxxxx\Desktop\System\os\Ubuntu Desktop\ubuntu-24.04.3-desktop-amd64.iso"
$VMPath = "E:\ProgramData\Microsoft\Windows\Hyper-V\$VMName"
$VHDPath = "$VMPath\$VMName.vhdx"
$VHDSize = 80GB
$VMSwitch = "Hyper-V仮想スイッチ（外部）"     # 既存の仮想スイッチ名

# C:\ProgramData\Microsoft\Windows\Hyper-V\
# C:\ProgramData\Microsoft\Windows\Virtual Hard Disks\Ubuntu Desktop 24.04.1(GitLab)_4A340DA9-9715-4E0E-9C78-9E3F72950E39.avhdx
# Ubuntu Desktop 24.04.1(GitLab).vhdx
# Ubuntu Desktop 24.04.1(GitLab)_0D43BB91-FBB3-4D1A-96D8-2BAAEEFBA00E.avhdx
# フォルダ
New-Item -ItemType Directory -Path $VMPath -Force | Out-Null

# VM作成（Generation 2）
New-VM -Name $VMName -Generation 2 -Path $VMPath -MemoryStartupBytes 4GB -SwitchName $VMSwitch

# ディスク作成＆接続
New-VHD -Path $VHDPath -SizeBytes $VHDSize -Dynamic | Out-Null
Add-VMHardDiskDrive -VMName $VMName -Path $VHDPath

# CPU数
Set-VMProcessor -VMName $VMName -Count 2

# ISOをDVDとして接続
Add-VMDvdDrive -VMName $VMName -Path $IsoPath

# 起動順序（DVD優先にしてインストールへ）
$dvd = Get-VMDvdDrive -VMName $VMName
Set-VMFirmware -VMName $VMName -FirstBootDevice $dvd

# Secure Boot（Linuxならテンプレを変えることが多い）
# Windowsなら既定のままでOK、Linuxなら Off または "MicrosoftUEFICertificateAuthority" を使うことがあります
Set-VMFirmware -VMName $VMName -EnableSecureBoot Off

# 起動
Start-VM -Name $VMName
