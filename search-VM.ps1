<#
.SYNOPSIS
  Script to find a specific virtual machine (VM) across multiple vCenter servers.

.DESCRIPTION
  This PowerShell script connects to multiple vCenter servers to search for a VM by name. It displays
  a banner, prompts for user credentials, and iterates through a list of vCenters to locate the specified
  VM. If found, the script displays the vCenter where the VM is located and exits.

.PARAMETER Get-Credential
  Prompts the user to enter credentials for connecting to the vCenter servers.

.PARAMETER Read-Host
  Prompts the user to enter the name of the VM to search for across the specified vCenter servers.

.EXAMPLE
  .\Find-VM.ps1
  This command will run the script, display the banner, prompt for credentials, and ask for the VM name
  before searching through the listed vCenter servers.

.NOTES
  This script requires the VMware PowerCLI module to be installed and imported. Ensure you have 
  appropriate permissions to connect to the vCenter servers and search for VMs.

.LINK
  https://developer.vmware.com/powercli
#>

Import-Module VMware.VimAutomation.Core

$Credentials = Get-Credential

# Skript Banner
function banner {
    ### Displaying banner ###

    $Banner = @(
       "  _____                          _                                 ",
       " / ____|                        | |                                ",
       "| (___    ___   __ _  _ __  ___ | |__     __=======__              ",
       " \___ \  / _ \ / _ ` || '__|/ __|| '_ \   [ |'''''''| ]            ",
       " ____) ||  __/| (_| || |  | (__ | | | |  [ |       | ]             ",
       "|_____/  \___| \__,_||_|   \___||_| |_|  [ |______.| ]             ",
       "__      __                                '=======(<>)             ",
       "\ \    / /                                         \  \            ",
       " \ \  / /_ __ ___                                   \  \           ",
       "  \ \/ /| '_ ` _  \                                   \__\         ",
       "   \  / | | | | | |                                                ",
       "    \/  |_| |_| |_|                                                "                     
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


$vCenterServers = @(
    # LIST OF VCENTERS TO SEARCH THROUGH
    # Add more vcenters if needed
)




$serverToFind = Read-Host -Prompt "Enter Server to find on all vCenters"

Write-Host "Searching for VM"

foreach($Server in $vCenterServers) {
    
    $null = Connect-VIServer -Server $Server -Credential $Credentials -ErrorAction SilentlyContinue
    $vmFound = Get-VM -Name "*$serverToFind*" -Server $Server
    if($vmFound.count -ge "1"){
        Write-Host "The VM is located on: $global:DefaultViServer" -ForegroundColor Green
        Disconnect-VIServer -Server $Server -Force -Confirm:$false
        Exit 1
    }
    else{
        Write-Host "Trying '$Server'..." -ForegroundColor Yellow
        Disconnect-VIServer -Server $Server -Force -Confirm:$false
    }
}

Write-Host "The VM you're looking for couldn't be found" -ForegroundColor Red



