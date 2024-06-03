<#
.SYNOPSIS
This PowerShell script provides a graphical user interface (GUI) for backing up files and folders to a SanDisk USB drive. It includes functions for saving all user files, specific folders, desktop contents, and downloads. The script ensures the backup process is user-friendly and efficient.

.DESCRIPTION
The script offers the following key features:
1. **Get-DiskSize**: Calculates the size of the USB drive and retrieves its drive letter.
2. **Get-Size**: Determines the size of a specified folder.
3. **Save-All-Files**: Backs up the entire user profile folder to the USB drive.
4. **Save-Specific-Folder**: Allows the user to specify a folder to back up.
5. **Save-Desktop**: Backs up the contents of the user's desktop.
6. **Save-Downloads**: Backs up the contents of the user's Downloads folder.
7. **GUI**: Provides a user interface with buttons to trigger the various backup functions.

.FUNCTIONS
    Get-DiskSize
    {
        Retrieves the size of the SanDisk USB drive and its drive letter.
        
        .SYNOPSIS
        Retrieves the size of the SanDisk USB drive and its drive letter.
        
        .DESCRIPTION
        This function calculates the size of the USB drive and retrieves its drive letter.
    }
    
    Get-Size
    {
        Calculates the size of the specified path.
        
        .SYNOPSIS
        Calculates the size of the specified path.
        
        .DESCRIPTION
        This function determines the size of the specified folder.
    }
    
    Save-All-Files
    {
        Backs up the entire user profile folder to the USB drive.
        
        .SYNOPSIS
        Backs up the entire user profile folder to the USB drive.
        
        .DESCRIPTION
        This function backs up the entire user profile folder to the USB drive.
    }
    
    Save-Specific-Folder
    {
        Prompts the user to specify a folder to back up.
        
        .SYNOPSIS
        Prompts the user to specify a folder to back up.
        
        .DESCRIPTION
        This function allows the user to specify a folder to back up.
    }
    
    Save-Desktop
    {
        Backs up the contents of the user's desktop.
        
        .SYNOPSIS
        Backs up the contents of the user's desktop.
        
        .DESCRIPTION
        This function backs up the contents of the user's desktop to the USB drive.
    }
    
    Save-Downloads
    {
        Backs up the contents of the user's Downloads folder.
        
        .SYNOPSIS
        Backs up the contents of the user's Downloads folder.
        
        .DESCRIPTION
        This function backs up the contents of the user's Downloads folder to the USB drive.
    }

.NOTES
Author: Silaskufu
Date: 12.11.2023
Version: 1.0

.LINK
https://github.com/Silaskufu/PowerShell

.EXAMPLE
To use this script, simply run it in a PowerShell session:
PS C:> .\BackupScript.ps1
This will open a GUI allowing you to select the backup options.
#>

Add-Type -AssemblyName System.Windows.Forms

function Get-DiskSize{
    param()


    $diskPartition = (Get-Partition -Disk $usbDrive)
    $diskLetter = $diskPartition.DriveLetter
    $diskSize = "{0:n2}" -f ($diskPartition.Size /1mb)

    
    [float]$diskSize = ($diskSize -replace ("[^\d.]",""))

    return $diskSize, $diskLetter
}
function Get-Size{
    param(
        $path
    )
    $size = "{0:n2}" -f ((Get-ChildItem -path $pathToSave -recurse | measure-object -property length -sum).sum /1mb)
    return $size
}
function Save-All-Files {
    param ()

    
    # This path will be saved --> in this case the whole userfile (this will take a while with big amounts of data.)
    $pathToSave = "C:\Users\$env:username"

    # Set Variables for function -> $backupName = Datum des saves
    $backupName = ((Get-Date -Format "dd-MM-yyyy") + "_" + (Get-Date -Format "HH:mm")).Replace(":",".")
    $usbDrive = (Get-Disk | Where-Object {$_.FriendlyName -match "SanDisk"})

    # Set Variables for function
    $diskSize, $driveLetter = Get-DiskSize
    $folderSize = Get-Size -path $pathToSave
    
    $backupFolder = "${driveLetter}:\File_Backup"
    $destinationFolder = "$backupFolder\$backupName"

    # Check if Disk with FriendlyName SanDisk exists --> Script will only work with SanDisk Drives
    if($usbDrive){
        
        if($diskSize -gt $folderSize){

            # Check if theres already a dir for all the backups
            If(Test-Path $backupFolder){
                # Check if there is already a save with the time the script was executed before
                if(Test-Path "$destinationFolder"){

                    # Save data anyway.
                    Write-Host "Die Daten werden kopiert.. Dies kann einen Moment dauern.." 
                    Start-Sleep(3)
                    Copy-Item -Path $pathToSave -Destination $destinationFolder -Recurse -ErrorAction SilentlyContinue
                    Write-Host "Kopieren abgeschlossen." -ForegroundColor Green
                    Start-Sleep(5)
                    return
                }
                else {
                    $null = New-Item -Path $backupFolder -ItemType Directory -Name $backupName
                    Write-Host "Ordner '$backupName' wurde erstellt.." -ForegroundColor Green
                }
            }
            else{
                $null = New-Item -Path $backupFolder -ItemType Directory -Name $backupName
                Write-Host "Ordner '$backupFolder' erstellt.." -ForegroundColor Green
            }

            Write-Host "Die Daten werden kopiert.. Dies kann einen Moment dauern.." -ForegroundColor Green
            Start-Sleep(3)
            Copy-Item -Path $pathToSave -Destination $destinationFolder -Recurse -ErrorAction SilentlyContinue
            Write-Host "Kopieren abgeschlossen."
            Start-Sleep(5)
            return
        }
        else{
            Write-Host "Die Disk verfuegt nicht ueber genug speicherplatz um alle Dateien zu sichern. Verlasse Skript" -ForegroundColor DarkYellow
            Start-Sleep(7)
            return
        }


    }
    else{
        Write-Host "Die eingesteckte Disk enthaelt nicht 'SanDisk' im Namen. Verlasse Skript.." -ForegroundColor DarkYellow
        Start-Sleep(7)
        return
    }
}
function Save-Specific-Folder{
    param()

    $usbDrive = (Get-Disk | Where-Object {$_.FriendlyName -match "SanDisk"})
    
    # This path will be saved 
    $pathToSave = Read-Host -Prompt "Geben sie den Dateipfad fuer die Speicherung an (C:\This\Will\Be\Saved)"

    if ($pathToSave -eq "" -or $null) {
        Write-Host "Bitte geben sie einen Gueltigen Pfad im Format 'C:\This\Will\Be\Saved' an." -ForegroundColor DarkYellow
        Start-Sleep(3)
        return
    }
    if(-not(Test-Path $pathToSave)){
        Write-Host "Bitte geben sie einen Gueltigen Pfad im Format 'C:\This\Will\Be\Saved' an." -ForegroundColor DarkYellow
        Start-Sleep(3)
        return
    }

    # Set Variables for function
    $diskSize, $driveLetter = Get-DiskSize
    $folderSize = Get-Size -path $pathToSave
    
    $backupFolder = "${driveLetter}:\File_Backup"
    
    # Trim everything away but last Directory to use in save file name
    $folderName = Split-Path $pathToSave -Leaf

    $backupName = ("Ordner_$folderName" + "_" + (Get-Date -Format "dd-MM-yyyy") + "_" + (Get-Date -Format "HH:mm")).Replace(":",".")
    $destinationFolder = "$backupFolder\$backupName"
    
    if($usbDrive){
        if($diskSize -gt $folderSize){

            # Check if theres already a dir for all the backups
            If(Test-Path $backupFolder){
                # Check if there is already a save with the time the script was executed before
                if(Test-Path "$destinationFolder"){

                    # Save data anyway.
                    Write-Host "Vorhandene Speicherung wird ueberschrieben.. Dies kann einen Moment dauern.." 
                    Start-Sleep(3)
                    Copy-Item -Path $pathToSave -Destination $destinationFolder -Recurse -ErrorAction SilentlyContinue
                    Write-Host "Kopieren abgeschlossen." -ForegroundColor Green
                    Start-Sleep(5)
                    return
                }
                else {
                    $null = New-Item -Path $backupFolder -ItemType Directory -Name $backupName
                    Write-Host "Ordner '$backupName' wurde erstellt.." -ForegroundColor Green
                }
            }
            else{
                $null = New-Item -Path $backupFolder -ItemType Directory -Name $backupName
                Write-Host "Ordner '$backupFolder' erstellt.." -ForegroundColor Green
            }

            Write-Host "Die Daten werden kopiert.. Dies kann einen Moment dauern.." -ForegroundColor Green
            Start-Sleep(3)
            Copy-Item -Path $pathToSave -Destination $destinationFolder -Recurse -ErrorAction SilentlyContinue
            Write-Host "Kopieren abgeschlossen."
            Start-Sleep(5)
            return
        }
        else{
            Write-Host "Die Disk verfuegt nicht ueber genug speicherplatz um alle Dateien zu sichern. Verlasse Skript" -ForegroundColor DarkYellow
            Start-Sleep(7)
            return
        }
    }
    else{
        Write-Host "Die eingesteckte Disk enthaelt nicht 'SanDisk' im Namen. Verlasse Skript.." -ForegroundColor DarkYellow
        Start-Sleep(7)
        return
    }
    Write-Host "" -ForegroundColor 
}
function Save-Desktop{
    param()

    # This path will be saved --> in this case the whole userfile (this will take a while with big amounts of data.)
    $pathToSave = "C:\Users\$env:USERNAME\Desktop"

    # Set Variables for function -> $backupName = Datum des saves
    $backupName = "Desktop"+"_"+((Get-Date -Format "dd-MM-yyyy") + "_" + (Get-Date -Format "HH:mm")).Replace(":",".")
    $usbDrive = (Get-Disk | Where-Object {$_.FriendlyName -match "SanDisk"})

    # Set Variables for function
    $diskSize, $driveLetter = Get-DiskSize
    $folderSize = Get-Size -path $pathToSave
    
    $backupFolder = "${driveLetter}:\File_Backup"
    $destinationFolder = "$backupFolder\$backupName"

    # Check if Disk with FriendlyName SanDisk exists --> Script will only work with SanDisk Drives
    if($usbDrive){
        
        if($diskSize -gt $folderSize){
           # Check if theres already a dir for all the backups
            If(Test-Path $backupFolder){

                # Check if there is already a save with the time the script was executed before
                if(Test-Path "$destinationFolder"){
                    # Save data anyway.
                    Write-Host "Die Daten werden kopiert.. Dies kann einen Moment dauern.." 
                    Start-Sleep(3)
                    Copy-Item -Path $pathToSave -Destination $destinationFolder -Recurse -ErrorAction SilentlyContinue
                    Write-Host "Kopieren abgeschlossen." -ForegroundColor Green
                    Start-Sleep(5)
                    return
                }
                else {
                    $null = New-Item -Path $backupFolder -ItemType Directory -Name $backupName
                    Write-Host "Ordner '$backupName' wurde erstellt.." -ForegroundColor Green
                }
            }
            else{
                $null = New-Item -Path $backupFolder -ItemType Directory -Name $backupName
                Write-Host "Ordner '$backupFolder' erstellt.." -ForegroundColor Green
            }
            Write-Host "Die Daten werden kopiert.. Dies kann einen Moment dauern.." -ForegroundColor Green
            Start-Sleep(3)
            Copy-Item -Path $pathToSave -Destination $destinationFolder -Recurse -ErrorAction SilentlyContinue
            Write-Host "Kopieren abgeschlossen."
            Start-Sleep(5)
            return
        }
        else{
            Write-Host "Die Disk verfuegt nicht ueber genug speicherplatz um alle Dateien zu sichern. Verlasse Skript" -ForegroundColor DarkYellow
            Start-Sleep(7)
            return
        }


    }
    else{
        Write-Host "Die eingesteckte Disk enthaelt nicht 'SanDisk' im Namen. Verlasse Skript.." -ForegroundColor DarkYellow
        Start-Sleep(7)
        return
    }

}
function Save-Downloads{
    param()
    $folderSize = 0
    # This path will be saved --> in this case the whole userfile (this will take a while with big amounts of data.)
    $pathToSave = "C:\Users\$env:USERNAME\Downloads"

    # Set Variables for function -> $backupName = Datum des saves
    $backupName = "Downloads"+"_"+((Get-Date -Format "dd-MM-yyyy") + "_" + (Get-Date -Format "HH:mm")).Replace(":",".")
    $usbDrive = (Get-Disk | Where-Object {$_.FriendlyName -match "SanDisk"})

    # Set Variables for function
    $diskSize, $driveLetter = Get-DiskSize
    [float]$folderSize = Get-Size -path $pathToSave
    
    $backupFolder = "${driveLetter}:\File_Backup"
    $destinationFolder = "$backupFolder\$backupName"

    # Check if Disk with FriendlyName SanDisk exists --> Script will only work with SanDisk Drives
    if($usbDrive){
        
        if($diskSize -gt $folderSize){
            # Check if theres already a dir for all the backups
            If(Test-Path $backupFolder){

                # Check if there is already a save with the time the script was executed before
                if(Test-Path "$destinationFolder"){
                    # Save data anyway.
                    Write-Host "Die Daten werden kopiert.. Dies kann einen Moment dauern.." 
                    Start-Sleep(3)
                    Copy-Item -Path $pathToSave -Destination $destinationFolder -Recurse -ErrorAction SilentlyContinue
                    Write-Host "Kopieren abgeschlossen." -ForegroundColor Green
                    Start-Sleep(5)
                    return
                }
                else{
                    $null = New-Item -Path $backupFolder -ItemType Directory -Name $backupName
                    Write-Host "Ordner '$backupName' wurde erstellt.." -ForegroundColor Green
                }
            }
            else{
                $null = New-Item -Path $backupFolder -ItemType Directory -Name $backupName
                Write-Host "Ordner '$backupFolder' erstellt.." -ForegroundColor Green
            }
            Write-Host "Die Daten werden kopiert.. Dies kann einen Moment dauern.." -ForegroundColor Green
            Start-Sleep(3)
            Copy-Item -Path $pathToSave -Destination $destinationFolder -Recurse -ErrorAction SilentlyContinue
            Write-Host "Kopieren abgeschlossen."
            Start-Sleep(5)
            return
        }
        else{
            Write-Host "Die Disk verfuegt nicht ueber genug speicherplatz um alle Dateien zu sichern. Verlasse Skript" -ForegroundColor DarkYellow
            Start-Sleep(7)
            return
        }


    }
    else{
        Write-Host "Die eingesteckte Disk enthaelt nicht 'SanDisk' im Namen. Verlasse Skript.." -ForegroundColor DarkYellow
        Start-Sleep(7)
        return
    }

}

$usbDrive = (Get-Disk | Where-Object {$_.FriendlyName -match "SanDisk"})

if(-not($usbDrive)){
    Write-Host "Es wurde kein USB Speichermedium mit dem Namen 'SanDisk' gefunden!" -ForegroundColor Red
    Start-Sleep(5)
    Exit 1
}

# Knopf für das Speichern vom User profil
$Button1 = New-Object System.Windows.Forms.Button
$Button1.Text = "Alle Dateien Speichern" 
$Button1.Font = "Arial,16"
$Button1.Location = New-Object System.Drawing.Point(70, 200)
$Button1.Width = 300
$Button1.Height = 40
$Button1.TextAlign = "MiddleCenter"
$Button1.AutoSize = $true
$Button1.Add_click({Save-All-Files})

# Knopf für das speichern vom einzelnen Ordner
$Button2 = New-Object System.Windows.Forms.Button
$Button2.Text = "Ordner Speichern (Pfad)"
$Button2.Font = "Arial,16"
$Button2.Location = New-Object System.Drawing.Point(460, 200)
$Button2.Width = 300
$Button2.Height = 40
$Button2.TextAlign = "MiddleCenter"
$Button2.AutoSize = $false
$Button2.Add_click({Save-Specific-Folder})

# Knopf für das speichern vom Desktop
$Button3 = New-Object System.Windows.Forms.Button
$Button3.Text = "Desktop Speichern"
$Button3.Font = "Arial,16"
$Button3.Location = New-Object System.Drawing.Point(70, 100)
$Button3.Width = 300
$Button3.Height = 40
$Button3.TextAlign = "MiddleCenter"
$Button3.AutoSize = $false
$Button3.Add_click({Save-Desktop})

# Knopf für das speichern der Downloads
$Button4 = New-Object System.Windows.Forms.Button
$Button4.Text = "Downloads Speichern"
$Button4.Font = "Arial,16"
$Button4.Location = New-Object System.Drawing.Point(460, 100)
$Button4.Width = 300
$Button4.Height = 40
$Button4.TextAlign = "MiddleCenter"
$Button4.AutoSize = $false
$Button4.Add_click({Save-Downloads})

# Title
$Title = New-Object System.Windows.Forms.Label
$Title.Text  = "File Saver"
$Title.Font = "Arial,32" 
$Title.Location = New-Object System.Drawing.Point(300, 10)
$Title.AutoSize = $true

# Root GUI
$root_form = New-Object System.Windows.Forms.Form
$root_form.Text = "File Saver"
$root_form.Height = 400
$root_form.Width = 830
$root_form.AutoSize = $true
$root_form.BackColor = "Gray"
$root_form.Controls.Add($Button1)
$root_form.Controls.Add($Button2)
$root_form.Controls.Add($Button3)
$root_form.Controls.Add($Button4)
$root_form.Controls.Add($Title)
$root_form.ShowDialog()