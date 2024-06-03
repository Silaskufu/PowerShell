<#
.SYNOPSIS
    Script to search for a specific virtual machine (VM) across multiple vCenter servers.

.DESCRIPTION
    This PowerShell script allows the user to search for a virtual machine (VM) by name across a list of
    vCenter servers. The user is prompted to enter their credentials and the VM name. The script then
    connects to each vCenter server, searches for the specified VM, and displays its properties if found.
    If the VM is not found on any of the vCenter servers, the script informs the user.

.PARAMETER $credentials
    The credentials used to connect to the vCenter servers. The user is prompted to enter these credentials.
  
.PARAMETER $vmToFind
    The name of the VM to search for. The user is prompted to enter this name.

.PARAMETER $vCenterServers
    An array of vCenter server addresses to search through. Add more vCenter servers to this array as needed.

.FUNCTION Connect-VIServer
    Connects to a vCenter server using the provided credentials.

.FUNCTION Get-VM
    Searches for a VM by name on the connected vCenter server.

.FUNCTION Disconnect-VIServer
    Disconnects from the vCenter server.

.EXAMPLE
    .\FindVM.ps1
    This command will prompt the user to enter their credentials and the VM name, then search for the VM
    across the specified vCenter servers.
.NOTES
    Ensure that the VMware PowerCLI module is installed and imported before running this script. Also, 
    update the $vCenterServers array with the correct vCenter server addresses.
#>


$credentials = Get-Credential -Message "Enter your credentials like [ADMIN]@[DOMAINNAME]"
$vmToFind = Read-Host -Prompt "Enter a VM Name"

$vCenterServers = @(
    # List of vCenters to Search VM through add more if needed
    # Weitere vCenter-Server hinzufügen, falls notwendig
)

Write-Host "Searching for VM"
foreach ($server in $vCenterServers){
    $null = Connect-VIServer -Credential $credentials -Server $server 
    $VM = Get-VM -Name "*$vmToFind*" -Server $server
    if($VM.Name){
        Write-Host "VM Found on $global:DefaultVIServer" -ForegroundColor Green
        Write-Host "VM Properties:"
        Write-Host ("-" * 20)
        $VM | Select-Object *
        
        Exit 1
    }
    else{
        Write-Host "Trying '$server' ..." -ForegroundColor Yellow
        $null = Disconnect-VIServer -Server $server -Force -Confirm:$false
    }
    
}

Write-Host "The entered VM couln't be found on any vCenters in the list.." -ForegroundColor Red