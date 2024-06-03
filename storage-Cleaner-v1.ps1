<#
.SYNOPSIS
  Script to clean up disk space on a remote computer by deleting contents of specified directories.
  
.DESCRIPTION
  This PowerShell script connects to a remote computer, verifies specified paths, and deletes files 
  within those paths if confirmed by the user. It includes checks for specific conditions, such as 
  only deleting content from certain directories within the first 10 days of the month.
  Feel free to change the $paths variable to your needs. Pro Patches folder was only deleted on the first 10 Days of the month in this example.
  Feel free to remove/ change that part of the script aswelle .


.PARAMETER Get-Credential
  Prompts the user to enter credentials for connecting to the remote computer.

.PARAMETER Read-Host
  Prompts the user to enter the name of the remote computer to clean disk space on.

.EXAMPLE
  .\Clean-DiskSpace.ps1
  This command will run the script, prompt for credentials, and ask for the remote computer name 
  before proceeding with the cleanup process.

.NOTES
  This script uses PowerShell Remoting to connect to the remote computer. Ensure that PowerShell 
  Remoting is enabled and configured on the target machine.

.LINK
  https://docs.microsoft.com/en-us/powershell/scripting/learn/remoting/ps-remoting-overview
#>
$credentials = Get-Credential
$computer = Read-Host -Prompt "Enter computer to clean diskspace on"

$s = New-PSSession -ComputerName $computer -Credential $credentials
Enter-PSSession -Session $s

Invoke-Command -Session $s -ScriptBlock {
    $paths = @(
        'C:\Temp\',
        'C:\$Recycle.Bin',
        'C:\Tmp\',
        'C:\Windows\ProPatches\Patches\',
        'C:\Windows\SoftwareDistribution\Download\',
        'C:\Windows\Installer\',
        'C:\Windows\Installer\$PatchCache$\Managed\',
        'C:\Windows\ccmcache'
    )

    Write-Host ""
    Write-Host "Are you sure you want to delete the content of the following folders:"
    Write-Host "---------------------------------"
    $paths
    Write-Host "---------------------------------"
    Write-Host ""
    $continue = Read-Host "[Y/N]"


    if ($continue -eq "Y" ){
        foreach($path in $paths){
            $testedPath = Test-Path -Path $Path
            if($testedPath){
            
                $fileContent = Get-ChildItem -Path $path
                if ($fileContent.Count -ge "1"){
                    
                    if($path -contains "ProPatches"){
                        $date = Get-Date
                        # only delete folder content, if its the first 10 days of the month
                        if (1..10 -contains $date.Day ){
                            $null = Get-ChildItem -Path $path -Include * -File -Recurse | Select-Object { $_.Delete()}
                            write-Host "$path --> Deleted Content" -ForegroundColor DarkYellow
                        }
                        else{
                            Write-Host "$path --> Content only gets deleted in the first 10 Days of the Month"
                        }
                    }
                    $null = Get-ChildItem -Path $path -Recurse -Include * -File -Force  | Remove-Item -ErrorAction SilentlyContinue
                    write-Host "$path --> Deleted Content" -ForegroundColor DarkYellow 

                }
                else{
                    Write-Host "$path --> Clean" -ForegroundColor Green
                }
            }
            else {
                write-Host "$path --> not found" -ForegroundColor Red
            }
        }

    }
    else{
        Write-Host "Exiting script.."
        Exit-PSSession
        Remove-PSSession -Session $s
        Exit 1
    }
}



Exit-PSSession
Remove-PSSession -Session $s
