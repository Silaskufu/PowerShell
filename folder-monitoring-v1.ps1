<#
.SYNOPSIS
This PowerShell script monitors a specified folder for any changes, including file creations, deletions, modifications, and renames.

.DESCRIPTION
The Monitor-FolderChanges.ps1 script uses the FileSystemWatcher class to observe a folder and its subdirectories. 
It prints a corresponding message to the console whenever an event occurs (such as a file being created, deleted, changed, or renamed). 
Feel free to change the action done when an event occurs.

.PARAMETER
None

.NOTES
Author: Silaskufu
Date: 07.06.2024
Version: 1.0

.EXAMPLE
To use this script, simply execute it within a PowerShell session. The script will start monitoring the specified folder for any changes.
.\Monitor-FolderChanges.ps1
#>

# Enter folder to monitor
$folder = "C:\Your\Very\Important\Folder\Path"

# *.* Filters for all files ends
$filter = "*.*"

# Remove Event subscriptions, if $fsw is already filled so no double output happens
if($fsw){
    Get-EventSubscriber | Unregister-Event
}

$fsw = New-Object IO.FileSystemWatcher $folder, $filter
$fsw.EnableRaisingEvents = $true
$fsw.IncludeSubdirectories = $true

$onChange = Register-ObjectEvent $fsw "Changed" -Action {
    Write-Host "Changes made: $($eventArgs.FullPath)"
}

$onCreate = Register-ObjectEvent $fsw "Created" -Action {
    Write-Host "File was created: $($eventArgs.FullPath)"
}

$onDelete = Register-ObjectEvent $fsw "Deleted" -Action {
    Write-Host "File was deleted: $($eventArgs.FullPath)"
}

$onRename = Register-ObjectEvent $fsw "Renamed" -Action {
    Write-Host "File was renamed from: $($eventArgs.OldFullPath) to $($eventArgs.FullPath)"
}

while ($true){
    Start-Sleep(1)
}
