####### Disk settings
$DiskSettings = [PSCustomObject]@{
    LargeDiskPercent     = 1
    LargeDiskAbsolute    = 100GB
    LargeDisksThreshold  = 10TB
    MediumDiskPercent    = 5
    MediumDiskAbsolute   = 50GB
    MediumDiskThreshold  = 3TB
    SmallDiskThreshold   = 200GB
    SmallDiskPercent     = 10
    SmallDiskAbsolute    = 2GB
    ExcludedDriveLetters = "A", "B"
}
####### Disk settings
try {
    $Volumes = get-volume | Where-Object { $_.DriveLetter -ne $null -and $_.DriveLetter -notin $ExcludedDriveLetters -and $_.DriveType -eq 'Fixed'}
}
catch {
    write-host "Could not get volumes: $($_.Exception.Message)"
    exit 1
}
$DisksOutOfSpace = Foreach ($Volume in $Volumes) {
    if ($volume.size -gt $DiskSettings.LargeDisksThreshold) { $percent = $DiskSettings.LargeDiskPercent; $absolute = $DiskSettings.LargeDiskAbsolute }
    if ($volume.size -lt $DiskSettings.LargeDisksThreshold) { $percent = $DiskSettings.MediumDiskPercent; $absolute = $DiskSettings.MediumDiskAbsolute }
    if ($volume.size -lt $DiskSettings.MediumDiskThreshold) { $percent = $DiskSettings.MediumDiskPercent; $absolute = $DiskSettings.MediumDiskAbsolute }
    if ($volume.size -lt $DiskSettings.SmallDiskThreshold) { $percent = $DiskSettings.SmallDiskPercent; $absolute = $DiskSettings.SmallDiskAbsolute }
 
    if ($volume.SizeRemaining -lt $absolute -or ([Math]::Round(($volume.SizeRemaining / $volume.Size * 100), 0)) -lt $percent ) {
        [PSCustomObject]@{
            DiskName            = $Volume.FileSystemLabel
            DriveLetter         = $volume.DriveLetter
            Size                = $volume.Size
            SizeRemaining       = $volume.SizeRemaining
            PercentageRemaining = [Math]::Round(($volume.SizeRemaining / $volume.Size * 100), 0)
       } 
    }
}
 
if ($DisksOutOfSpace) {
    "Some disks are running low on space. Please investigate"
    $DisksOutOfSpace
}
else {
    "Healthy - No disks running out of space"
}
