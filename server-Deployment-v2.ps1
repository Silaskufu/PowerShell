<#
.SYNOPSIS
This PowerShell script automates the deployment of a new virtual machine (VM) using VMware vCenter and custom specifications. 
NOTE THAT THERE MUST BE CHANGES DONE TO THE SCRIPT TO USE IT SUCCESSFULLY!

.DESCRIPTION
The script offers the following key features:
1. **Import-Module**: Loads the necessary VMware modules.
2. **Set-PowerCLIConfiguration**: Configures PowerCLI to ignore certificate warnings.
3. **Disconnect-VIServer**: Ensures any existing vCenter connections are disconnected.
4. **banner**: Displays a custom ASCII banner for script branding.
5. **Get-SpecificFolder**: Helper function to list and select specific folders in vCenter.
6. **Get-SpecificNetwork**: Helper function to list and select specific networks in vCenter.
7. **vCenter and [CI MANAGEMENT TOOL] Checks**: Prompts user to confirm entries in [IP DOCUMENTATION TOOL] and [CI MANAGEMENT TOOL].
8. **vCenter Connection**: Connects to vCenter using provided credentials.
9. **Customization Spec**: Manages OS customization specifications for the new VM.
10. **Resource Selection**: Prompts user to select folder, network, datastore, and resource pool.
11. **VM Creation and Configuration**: Creates the VM from a template, configures hardware, and sets up network adapters.
12. **Disk Management**: Adds additional disks to the VM if required.
13. **Ping Test**: Checks if the new VM is reachable via ping.
14. **Cleanup**: Removes customization spec and disconnects from vCenter.

.PARAMETER
vCenter
Specifies the vCenter server for VM deployment.

.NOTES
Author: Silaskufu
Date: 30.05.2023
Version: 2.0

.LINK
https://github.com/Silaskufu/PowerShell

.EXAMPLE
To use this script, modify all the Keywords marked between [KEYWORD], debug it once or twice make more needed changes and run it in a PowerShell session:
PS C:> .\server-Deployment-v2.ps1
This will prompt for necessary inputs and execute the VM deployment process.
#>

import-module VMware.VimAutomation.Cis.Core

#Import-Module [IP DOCUMENTATION TOOL]server

Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false 2>&1 > $null

# vCenter verbindung testen
$testvcenterconnection = $Global:DefaultVIServer.count

# Wenn vorherige verbindungen bestehen, diese Trennen
if ($testvcenterconnection -gt 0) {
    Disconnect-VIServer * -confirm:$false
}
# Skript Banner
function banner {
    ### Displaying banner ###

    $Banner = @(
    "     _____                                                                         ",
    "    / ____|                                            .--.                        ",
    "   | (___     ___   _ __  __   __   ___   _ __         |__| .---------.            ",  
    "    \___ \   / _ \ | '__| \ \ / /  / _ \ | '__|        |=.| |.-------.|            ", 
    "    ____) | |  __/ | |     \ V /  |  __/ | |           |--| || VEEAM ||            ",  
    "   |_____/   \___| |_|      \_/    \___| |_|           |  | |'-------'|            ",  
    "    _____                   _                          |__|~')_______('    _       ",
    "   |  __ \                 | |                                            | |      ",
    "   | |  | |   ___   _ __   | |   ___    _   _   _ __ ___     ___   _ __   | |_     ",
    "   | |  | |  / _ \ | '_ \  | |  / _ \  | | | | | '_ ` _  \   / _ \ | '_ \  | __|   ",
    "   | |__| | |  __/ | |_) | | | | (_) | | |_| | | | | | | | |  __/ | | | | | |_     ",
    "   |_____/   \___| | .__/  |_|  \___/   \__, | |_| |_| |_|  \___| |_| |_|  \__|    ",
    "                   | |                   __/ |                                     ",
    "                   |_|                  |___/                                      "
    )
    $Colors = @("Green")
    Write-Host ""
    Write-Host ""
    Write-Host ""
    foreach ($i in 0..($Banner.Length - 1)) {
        Write-Host $Banner[$i] -ForegroundColor $Colors[$i % $Colors.Count]
    }
    Write-Host ""
    Write-Host ""
    Write-Host `t"Running server-Deployment-v2.ps1 script" -ForegroundColor Cyan
    Write-Host ""
    Start-Sleep(2)
}
# Anzeigen von Skript Banner
banner 

# Credentials holen --> Darüber wird alles erstellt
$Credential = Get-Credential -Message "Geben Sie ihre anmeldeinformationen ein (adminxxx@[DOMAINNAME])"
[int]$count = 0

# Funktion für spätere Ordnersuche
function Get-SpecificFolder {
    param (
        $foldersFound
    )
    Class folderSearch{
        $Nr
        $FolderName
        $ParentFolder
    }

    $folderList = @()
    $folderCount = 1
    foreach($folder in $foldersFound){
        $leafobject = [folderSearch]::new()
        $leafobject.Nr = $folderCount
        $leafobject.FolderName = $folder.Name
        $leafobject.ParentFolder = $folder.Parent
        $folderCount = $folderCount + 1
        $folderList += $leafobject
    }
    return $folderList
    
}
function Get-SpecificNetwork {
    param (
        $networksFound
    )
    Class networkSearch{
        $Nr
        $NetworkName
    }

    $NetworkList = @()
    $NetworkCount = 1
    foreach($network in $networksFound){
        $leafobject = [networkSearch]::new()
        $leafobject.Nr = $networkCount
        $leafobject.NetworkName = $network.Name
        $NetworkCount = $NetworkCount + 1
        $NetworkList += $leafobjectcxcx
    }
    return $NetworkList
}

# Ask for [IP DOCUMENTATION TOOL] entry DOCUMENTATION PURPOSES
$Action = Read-Host -Prompt "Wurde der Server einer freien IP im [IP DOCUMENTATION TOOL] erfasst?  [Y/N]" 
if ($Action -eq "Y") {
}
else {
    Write-Host "Vor Server erstellung bitte im [IP DOCUMENTATION TOOL] erfassen und [CI MANAGEMENT TOOL] eintrag erstellen!"
    Exit 1
}

# Ask for [CI MANAGEMENT TOOL] entry DOCUMENTATION PURPOSES
$Action = Read-Host -Prompt "Wurde der neue Server in der [CI MANAGEMENT TOOL] erfasst?         [Y/N]"
if ($Action -eq "Y") {
}
else {
    Write-Host "Vor Server erstellung bitte im [IP DOCUMENTATION TOOL] erfassen und [CI MANAGEMENT TOOL] eintrag erstellen!"
    Exit 1
}

### Getting Information ###
$vCenter = (Read-Host -prompt "Auf welchem vCenter wird der Server erstellt [VCENTERNAME]") + ".[DOMAINNAME]"


# Verbindung zu vCenter
$vCenterConnection = Connect-VIServer -Server $vCenter -Credential $Credential -ErrorAction SilentlyContinue

# Prüfen ob vCenter verbunden wurde
if ($vCenterConnection.Name) {

    # Hostname der neuen VM holen
    do {
        $hostname = Read-Host "Name der neuen VM (ohne FQDN & max. 15 Zeichen lang) -->"
    } while ($hostname.Length -gt 15)
    
    # Spezifile vorlage suchen
    $oldSpecFile = (Get-OSCustomizationSpec | Where-Object { $_.Name -contains "Windows2019 Std KMS" }).Name

    $specToRemove = Get-OSCustomizationSpec -Name $hostname -ErrorAction SilentlyContinue

    if($specToRemove.Name){
        Remove-OSCustomizationSpec $specToRemove -Confirm:$false -ErrorAction SilentlyContinue
        Start-Sleep(10)
    }

    # Neue Spezifile erstellen auf basis der alten Spezifile 
    New-OSCustomizationSpec -Name $hostname -OSCustomizationSpec $oldSpecFile 2>&1 > $null
    $newSpecFile = Get-OSCustomizationSpec -Name $hostname

    # Local Admin Passwort holen
    $securePassword = Read-Host -Prompt "Gib das Local Administrator-Passwort fuer den Server ein -->" -AsSecureString
    $securePassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($securePassword))

    $IP = Read-Host "Gib die IP-Adresse der VM ein -->"
    $Netmask = Read-Host "Gib die Subnetzmaske des Netzwerks ein -->"
    $Gateway = Read-Host "Gib den Gateway des Netzwerks ein -->"
    # $primaryDNS = Read-Host "Primary DNS -->"
    # $secondaryDNS = Read-Host "Secondary DNS -->"

    # DNS einstellungen Setzen, da diese immer Statisch sind
    $primaryDNS = "[DNSIP1]"
    $secondaryDNS = "[DNSIP2]"

    Set-OSCustomizationSpec $newSpecFile.Name -Server $vCenter -NamingScheme fixed -NamingPrefix $newSpecFile.Name -AdminPassword $securePassword 2>&1 > $null

    $removingNIC = Get-OSCustomizationSpec $newSpecFile.Name | Get-OSCustomizationNicMapping
    Remove-OSCustomizationNicMapping $removingNIC -Confirm:$false 2>&1 > $null

    # Neue Netzwerk Karte mit Angaben Konfigurieren
    New-OSCustomizationNicMapping -OSCustomizationSpec $newSpecFile.Name -IpMode UseStaticIP -IpAddress $IP -SubnetMask $Netmask -DefaultGateway $Gateway -Dns $primaryDNS, $secondaryDNS 2>&1 > $null

    Start-Sleep (1.5)

    if ($null -ne (Get-OSCustomizationSpec $newSpecFile.Name)) {
        $hostname += "[DOMAINNAME]"

        Write-Host ""
        
        # Speicherort suche
        do {
            Write-Host "Fuer Auflistung der moeglichen Ordner nur Taste 'Enter' druecken"
            $folder = Read-Host "Unter welchem Ordner soll die VM erstellt werden? -->"
            $foldersFound = Get-Folder -Name "*$folder*"
            if ($foldersFound) {

                # Wird ausgefuehrt wenn mehr als 1 Ordner mit dem Namen vorhanden ist
                if($foldersFound.Count -ge "2"){
                    
                    Write-Host "Es wurden mehrere Ordner mit dem Namen '$folder' gefunden:"
                    $output = $(Get-SpecificFolder -foldersFound $foldersFound)

                    $outputToString = $output | Out-String
                    
                    Write-Host "$outputToString"
                    $folderChoice = Read-Host -Prompt "In welchem Ordner soll die VM deployed werden (Nr)"
                    
                    $foldersFound = (Get-SpecificFolder -foldersFound $foldersFound) | Where-Object { $_.Nr -eq $folderChoice }
                }
                Continue
            }
            Else {
                Write-Host "Ordner konnte nicht gefunden werden, erneut versuchen"
            }
        }while (-not $foldersFound.Name -and (-not $foldersFound.FolderName)) 

        Write-Host ""

        # Netzwerk Adapter suche
        do {
            Write-Host "Fuer Auflistung der moeglichen Netzwerke nur Taste 'Enter' druecken"
            $whichnetwork = Read-Host "Unter welchem Netzwerk soll die VM laufen? (letzte 3 Ziffern angeben) -->"
            $networksFound = (Get-VirtualNetwork | Where-Object { $_.Name -like "*$whichnetwork*" })

            if($networksFound){
                if($networksFound.count -ge 2){
                    Write-Host "Es wurden mehrere Netzwerke die den Text '$whichnetwork' enthalten gefunden:"
                    $output = $(Get-SpecificNetwork -networksFound $networksFound)


                    $outputToString = $output | Out-String
                    
                    Write-Host "$outputToString"
                    $networkChoice = Read-Host -Prompt "In welchem Ordner soll die VM deployed werden (Nr)"
                    
                    $networksFound = (Get-SpecificNetwork -networksFound $networksFound) | Where-Object { $_.Nr -eq $networkChoice }
                }
                continue
            }
            
            Else {
                Write-Host "Netzwerk konnte nicht gefunden werden, erneut versuchen"
            }
        }while (-not $networksFound.Name -and (-not $networksFound.NetworkName))

        
       
        # Zuschneiden von vCenter Zahlen für datastore filterung
        $vCenterDigits = $vCenter.TrimEnd("[DOMAINNAME]")
        $vCenterDigits = ($vCenterDigits.Substring(7, 2) + "01")

        # Datenspeicher suche #
        $datastore = Get-DatastoreCluster | Where-Object "Name" -Match "$vCenterDigits"
        if ($null -eq $datastore) {
            Write-Host "Datastore konnte nicht gefunden werden.."
            Write-Host "Skript wird abgebrochen und die Spezifikations Datei geloescht!"
            Remove-OSCustomizationSpec -OSCustomizationSpec $newSpecFile.Name -Confirm:$false
        
            Exit 1
        } 
        else {
            Write-Host "Datastore gefunden"
            Start-Sleep (1)
        }

        # Template suchen
        $template = (Get-Template -Name "*2019Template*")
        # prüfen ob Template gefunden wurde
        if ($null -eq $template) {
            Write-Host "Template konnte auf vCenter nicht gefunden werden.."
            Write-Host "Skript wird abgebrochen und die Spezifikations Datei geloescht!"
            Remove-OSCustomizationSpec -OSCustomizationSpec $newSpecFile.Name -Confirm:$false
        
            Exit 1
        } 
        else {
            Write-Host "Template gefunden"
            Start-Sleep (1)
        }

        # Ressourcen Pool holen
        $ressourcePool = (Get-Cluster -Server $vCenter -Name "*$vCenterDigits*")
        if ($null -eq $ressourcePool) {
            Write-Host "Ressourcen Pool konnte nicht gefunden werden.."
            Write-Host "Skript wird abgebrochen und die Spezifikations Datei geloescht!"
            Remove-OSCustomizationSpec -OSCustomizationSpec $newSpecFile.Name -Confirm:$false
            Exit 1
        } 
        else {
            Write-Host "Ressourcen Pool gefunden"
            Start-Sleep (1)
        }

        # Hardware Eigenschaften Abfragen
        $CPUnum = [int](Read-Host "vCPUs -->")

        if ($CPUnum -ge 40){
            $continue = Read-Host -Prompt "Sind sie sich sicher, dass sie $CPUnum vCPUs zuweisen wollen? [y/N]"
            switch ($continue){
                "Y"{
                    continue
                }
                "N"{
                    Write-Host "Waehlen Sie erneut"
                    $CPUnum = [int](Read-Host "vCPUs -->")
                }
                Default { Write-Host "Keine gueltige Angabe, Skript wird abgebrochen.." -ForegroundColor Red} 
            }
        }

        $CoresPerSocket = [int](Read-Host "Cores Per Socket -->") # vCPU / Cores = Anzahl verwendeter Sockets 

        $RAMnum = [int](Read-Host "Arbeitsspeicher (GB) -->")

        if ($RAMnum -ge 40){
            $continue = Read-Host -Prompt "Sind sie sich sicher, dass sie $RAMnum GB RAM zuweisen wollen? [y/N]"
            switch ($continue){
                "Y"{
                    continue
                }
                "N"{
                    Write-Host "Waehlen Sie erneut"
                    $RAMnum = [int](Read-Host "Arbeitsspeicher (GB) -->")
                }
                Default { Write-Host "Keine gueltige Angabe, Skript wird abgebrochen.." -ForegroundColor Red} 
            }
        }

        # Neue VM Erstellen
        New-VM -OSCustomizationSpec $newSpecFile -Template $template -Server $vCenter -Name $hostname -ResourcePool $ressourcePool -Location $foldersFound.FolderName -Datastore $datastore 2>&1 > $null

        Start-Sleep -Seconds 4
        # VM Eigenschaften wie CPU, CPS & RAM setzen 
        Set-VM -VM $hostname -NumCpu $CPUnum -CoresPerSocket $CoresPerSocket -MemoryGB $RAMnum -Confirm:$false 2>&1 > $null

        Start-Sleep -Seconds 2

        # Vm Starten
        Start-VM -VM $hostname -Confirm:$false 2>&1 > $null

        Start-Sleep -Seconds 4

        # Netzwerk Adapter der neuen vm holen
        $VMNic = (Get-NetworkAdapter -VM $hostname)
        Set-NetworkAdapter -NetworkAdapter $VMNic -NetworkName $networksFound.Name -StartConnected:$true -Connected:$true -Confirm:$false 2>&1 > $null
        
        # Entfernen von automatisch erstelltem D:\ Drive
        $removeHarddisk = Get-HardDisk -VM $hostname -Server $vCenter -Name "*2*"
        Remove-HardDisk -HardDisk $removeHarddisk -DeletePermanently -Confirm:$false 2>&1 > $null

        # Fragen ob Disks erstellt werden sollten
        $Disks = read-host "sollen noch weitere Festplatten hinzugefuegt werden? (D, E, F, G) [Y/N] -->"
        
        do {
            if ($Disks -eq "Y" -or $Disks -eq "y") {
                Write-Host ""
                Write-Host ("-" * 20)
                Write-Host "Die Maximale Grösse fuer Festplatten betraegt 500 GB"
                Write-Host ""
                # Diskgrösse abfragen
                $diskgroesse = Read-Host "Gib die Groesse der Disk an [GB] -->"

                if ($diskgroesse -gt 500 ) {
                    Write-Host "ERROR - Die maximale groesse fuer Festplatten betraegt 500GB" -ForegroundColor Red
                }
                else{
                    # neue Harddisk erstellen
                    New-HardDisk -VM $hostname -Server $vCenter -CapacityGB $diskgroesse 2>&1 > $null
                }
                
                # Nachdem eine Disk erstellt wurde, fragen, ob eine weitere erstellt werden soll.
                $weitereDisk = Read-Host "Soll eine weitere Disk erstellt werden? (Y/N) -->"
            }
            else {
                $weitereDisk = "N" # Setzen Sie die Standardeingabe auf 'N', um die Schleife zu beenden.
            }
        } while ($weitereDisk -eq "Y" -or $weitereDisk -eq "y")

        # Funktion, um den Ping-Status zu überprüfen
        function Test-Ping {
            param (
                [string]$hostname
            )
            $pingResult = Test-Connection -ComputerName $hostname -Count 1 -ErrorAction SilentlyContinue
            
            return $null -ne $pingResult
        }
        
        # Warten, bis der Server pingbar ist
        while (-not (Test-Ping -hostname $hostname)) {
            Write-Host "Der Server $hostname wird bereitgestellt... bitte warten. " -ForegroundColor DarkYellow
            Start-Sleep -Seconds 16

            $count++
            if($count -ge 15){
                Write-Host "Bitte Server im vCenter ueberpruefen! Server ist nicht Erreichbar." -ForegroundColor Red

                # Spezifikations File löschen
                Remove-OSCustomizationSpec -OSCustomizationSpec $newSpecFile.Name -Confirm:$false
                Write-Host "Spezifikations-Datei geloescht!"
                Disconnect-VIServer * -confirm:$false 2>&1 > $null
                Exit 1
            }
        }

        ### Skript Ende ###
        Write-Host "Die VM wurde erfolgreich bereitgestellt =======> 100%" -ForegroundColor DarkGreen
        Start-Sleep (2)
        Write-Host "*VM Started* --> Falls vorhanden muessen Disks noch manuell formatiert werden!  " -ForegroundColor Magenta
        Start-Sleep (2)
        # Spezifikations File löschen
        Remove-OSCustomizationSpec -OSCustomizationSpec $newSpecFile.Name -Confirm:$false
        Write-Host "Spezifikations-Datei geloescht!"
        Disconnect-VIServer * -confirm:$false 2>&1 > $null




    }
    else {
        Disconnect-VIServer * -confirm:$false 2>&1 > $null
        Write-Error "Error - Das Spezifile existiert nicht." -ForegroundColor Red
        throw
    }

}
else {
    Disconnect-VIServer * -confirm:$false 2>&1 > $null
    Write-Host "Error - Kein gültiges vCenter angegeben" 
    Throw
}
