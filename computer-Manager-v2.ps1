<#
.SYNOPSIS
This PowerShell script empowers computer management tasks by offering a range of actions to execute on remote or local computers within a network.
Make sure you have the needed permissions to connect to remote computers

.DESCRIPTION
The computer-Manager-v2.ps1 script provides an interactive interface for executing various administrative tasks on remote or local computers. Key features include:

Displaying a custom ASCII banner for script branding and identification.
Ability to gather computer information such as model, IP address, and current user.
Options to perform actions like shutting down, rebooting, getting computer info, executing PowerShell commands, listing installed software, managing services and processes, disabling/enabling input devices, sending messages to users, viewing remote computer files, and checking disk status.
Customizable cursor setting for local computers.

.PARAMETER
Credentials
Specifies the credentials required to execute actions on remote computers.

.NOTES
Author: Silaskufu
Date: 10.05.2023
Version: 2.0

.LINK
https://github.com/Silaskufu/PowerShell

.EXAMPLE
To utilize this script, execute it within a PowerShell session and follow the on-screen prompts to select and execute desired actions.
.\computer-Manager-v2.ps1
#>

# Get Credentials to execute actions with
$credentials = Get-Credential

function banner { # Function to display a banner for the script

    $Banner = @(
    "     __  __                                                         ",
    "    |  \/  |                                                        ",
    "    | \  / |   __ _   _ __     __ _    __ _    ___                  ",
    "    | |\/| |  / _`  | | '_ \   / _`  |  / _`  |  / _ \                 ",
    "    | |  | | | (_| | | | | | | (_| | | (_| | |  __/                 ",
    "    |_|  |_|  \__,_| |_| |_|  \__,_|  \__, |  \___|                 ",
    "      _____                            __/ |      _                 ",
    "     / ____|                          |___/      | |                ",
    "    | |        ___    _ __ ___    _ __    _   _  | |_    ___   _ __ ",
    "    | |       / _ \  | '_ ` _  \  | '_ \  | | | | | __|  / _ \ | '__|",
    "    | |____  | (_) | | | | | | | | |_) | | |_| | | |_  |  __/ | |   ",
    "     \_____|  \___/  |_| |_| |_| | .__/   \__,_|  \__|  \___| |_|   ",
    "                                 | |                                ",
    "                                 |_|                                "
    )   

    $Colors = @("Blue")
    Write-Host ""
    Write-Host ""
    Write-Host ""
    foreach ($i in 0..($Banner.Length)) {
        Write-Host $Banner[$i] -ForegroundColor $Colors[$i % $Colors.Count]
    }
    Write-Host ""
    Write-Host ""
    Write-Host "     Running computer-Manager-v2.ps1 script" -ForegroundColor $Colors[$i % $Colors.Count]
    Write-Host ""
}

# Executes the banner function
banner

# Get needed information / initialize Variables
$computer = Read-Host -Prompt "Enter Computer Name "
$count = 0

try {
    # try to reach remote computer and might aswell save the IP
    $pingResponse = Test-Connection -ComputerName $computer -Count "1" -ErrorAction Stop
    $computerIP = $pingResponse.IPV4Address.IPAddressToString
}
catch {
    # Write Error and exit if computer can't be pinged
    Write-Host "Computer is unavailable or blocking Ping probes.. Try again later."
    Exit 1
} 

# Do-While loop to continue if more then 1 Action is wanted.
do{

    ### Picking Actions for Computer ###
    
    # List Options
    Write-Host ""
    Write-Host ""
    Write-Host "Shutdown Computer             :  Type [1]" # Shutdown the remote Computer after any amount of time
    Write-Host "Reboot Computer               :  Type [2]" # Reboot the remote Computer after any amount of time
    Write-Host "Get Computer Info             :  Type [3]" # List some Information about the remote Computer
    Write-Host "Execute PS Command            :  Type [4]" # Execute a custom Powershell Command on the remote Computer
    Write-Host "List Installed Software       :  Type [5]" # List the Installed Software on remote Computer
    Write-Host "Service & Process Management  :  Type [6]" # Gives you options for Service & Process Management Management
    Write-Host "Disable / Enable Input Device :  Type [7]" # Gives you the option to Disable or Enable a USB Device
    Write-Host "Send Message to current user  :  Type [8]" # Lets you send a Message to the user currently working on the machine
    Write-Host "View Remote Computer Files    :  Type [9]" # Open Explorer with path to remote Computer where you can Edit, view & create files including folders.
    Write-Host "View Disk Status              :  Type [10]" # Displays Hard drive status. If left storage is under 10 % it will be displayed red
    Write-Host "Set Custom Cursor              :  Type [11]" # Displays Hard drive status. If left storage is under 10 % it will be displayed red
    Write-Host "View Action Details           :  Type [99]" # List these details.
    Write-Host ""

    Do {
        # Save Action Number
        $Action = Read-Host -prompt "Pick Action"

        # if userinput matches with Options set variable $validAction to true
        if( $Action -match '^[1-9]$' -or $Action -match '^(11|99)$' ){ # Change regex number if Amount of numbers are changed
            $validAction = $true
        }
        else {
            # if userinput doesn't match with Options set variable $validAction to false and tell user to pick again
            $validAction = $false
            $count += 1
            Write-Host "" # To make output prettier
            switch ( $count ){
                "1" {Write-Host "Invalid choice. Pick from above"}
                "2" {Write-Host "Please. Pick a Number Listed above"}
                "3" {Write-Host "Im Warning you. This is not funny.."}
                "4" {Write-Host "THIS IS YOUR LAST WARNING PICK A NUMBER FROM ABOVE!!"}
                "5" {Write-Host "No. This is it. Im leaving. >:/"; Start-Process -FilePath "msedge.exe" -ArgumentList "--new-window https://www.google.com/search?q=how+to+overcome+dyslexia"; Exit 0}
            }
        }

    } while( -not $validAction ) # will loop "Do" as long as $validAction is set to $false


    ### Switch to Execute the chosen Actions ###

    Switch( $Action ){
        "1"{                                                                                          # Action 1
            # Ask for time to shutdown in
            $shutdowntimer = Read-Host -Prompt "Enter shutdown Timer (Seconds)"
            Write-Host "Shutdown scheduled, press CTRL + C to cancle."

            # Put script to sleep, so you have full control over cancle
            Start-Sleep ($shutdowntimer)

            #Shuts Computer Down
            Stop-Computer -ComputerName $computer -Credential $credentials -Confirm:$false
        }
        "2"{                                                                                          # Action 2
            # Ask for time to reboot in
            $reboottimer = Read-Host -Prompt "Enter shutdown Timer (Seconds)"
            Write-Host "Shutdown scheduled, press CTRL + C to cancle."
            # Put script to sleep, so you have full control over cancle
            Start-Sleep ( $reboottimer )
            # Reboots Computer
            Restart-Computer -ComputerName $computer -Credential $credentials -Confirm:$false
        }
        "3"{                                                                                          # Action 3
            # Get computerinfo and check if computer is remote or local 
            if ( $computerInfo = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $computer -Credential $credentials -ErrorAction SilentlyContinue ){

                # Split Computerinfo
                $computerModel = $computerInfo.Model
                $currentUser = $computerInfo.UserName.TrimStart("EUHCNET\")   
                # Write Information
                Write-Host ""
                Write-Host "Computer Name       :       $computer"
                Write-Host "Computer Model      :       $computerModel"
                Write-Host "IP Adress           :       $computerIP"
                Write-Host "Current User        :       $currentUser"
                Write-Host ""
            }

            # Will be executed if computer is local / not remote    
            else {
            
                # Get Local Computerinfo
                $computerInfo = Get-ComputerInfo
                # Split Computerinfo
                $computerModel = $computerInfo.CsModel
                $currentUser = $computerInfo.CsUserName.TrimStart("EUHCNET\")        
                # Write Information
                Write-Host ""
                Write-Host "Computer Name       :       $computer"
                Write-Host "Computer Model      :       $computerModel"
                Write-Host "IP Adress           :       $computerIP"
                Write-Host "Current User        :       $currentUser"
                Write-Host ""
            }
        }
        "4"{                                                                                          # Action 4

            Invoke-Command -Credential $credentials -ComputerName $computer -ScriptBlock {

                # Initialize Variables as Arrays
                $parameters = ("")
                $commandToExecute= ("")

                # Error Handling for Invalit cmdlet Input 
                do {
                    # Get CMDLET
                    $cmdlet = Read-Host -Prompt "Enter the CmdLet you would like to execute"

                    # if the cmdlet can't be found you get the chance to input another
                    if( -not ( Get-Command -Name $cmdlet -ErrorAction SilentlyContinue ) ){
                        Write-Host "The cmdlet '$cmdlet' doesn't exit try again"
                        continue
                    }
                    
                }while( -not ( Get-Command -Name $cmdlet -ErrorAction SilentlyContinue ) ) # Loop as long as no cmdlet is found

                # List Parameters for CMDLET
                Write-Host "Choose the needed Parameters:"
                (Get-Command $cmdlet).Parameters.Keys

                
                
                ### Get Parameter Amount ###

                # Error Handling for userinput 
                do{
                    # Write Options
                    Write-Host ""
                    Write-Host "No Parameter        : [0]"
                    Write-Host "One Parameter       : [1]"
                    Write-Host "Multiple Parameter  : [2]"

                    # Save Userinput 
                    $amount = Read-Host -Prompt "Please choose 0, 1 or 2"

                    # Write Invalid input if it doesn't match with Available options
                    if ( $amount -ne "0" -and $amount -ne "1" -and $amount -ne "2" ){
                        Write-Host ""
                        Write-Host "Invalid Input. Choose Again"
                        continue
                    }
                    
                }while ( $amount -ne "0" -and $amount -ne "1" -and $amount -ne "2" ) # Do While User input doesn't match Options

                Switch ( $amount ){
                    "0" {
                        continue
                    }
                    "1" {
                        # get the wanted parameter from user
                        $parameters += Read-Host -prompt 'Type your parameter like "-Property"'
                        # append the value of the parameter to the parameter itself
                        $parameters += "",(Read-Host -prompt "Add Value to $parameters")
                        $parameters.Replace(",", "")
                    }
                    "2" { 
                        # Get the wanted parameters from user
                        $parameters = (Read-Host -Prompt "Type your parameters like -Property, -Verbose")

                        # Split away the , from the input
                        $parameterArray = $parameters.Split(",")

                        # initialize newParameter array
                        $newParameters = @()

                        # Foreach through the Parameter Array to append the parameter value
                        foreach ( $param in $parameterArray ) {
                            # Get Text to append
                            $textToAppend = Read-Host -Prompt "Enter text to append to parameter '$param'"
                            # Create new variable with full parameter context
                            $newParam = $param + " " + $textToAppend
                            # add full parameters to the newParameters array
                            $newParameters += $newParam
                        }
                        # set Prameter variable to new parameter variable with joined
                        $parameters = $newParameters -join ""

                    }
                }
                # Put Together Full Command
                $commandToExecute += "$cmdlet $parameters"

                try {
                    # Run Command
                Invoke-Expression $commandToExecute
                }
                catch {
                    Write-Host "An Error occured: $_"
                }
                
            }




        }
        "5"{                                                                                          # Action 5
            Write-Host ""
            Write-Host "These are the currently installed Software packages:"
            Write-Host ""

            # list Items of folder Application_Detection and filter Name + Install date (Creation Time)  
            Invoke-Command -ComputerName $computer -Credential $credentials -ScriptBlock {
                $installedSoftware = Get-Package -Name * | Where-Object -Property ProviderName -match "programs" | Where-Object -Property "Name" -NotMatch "Update for" | Sort-Object -Property "Name"
                $installedSoftware.Name
            } 
            Write-Host ""
        }
        "6"{                                                                                          # Action 6
            # List the available Manager options 
            Write-Host ""
            Write-Host "Processes      [1]  "
            Write-Host "Services       [2]  "
            Write-Host ""

            Invoke-Command -ComputerName $computer -Credential $credentials -ScriptBlock {
                # Get Manager to run
                $Action = Read-Host -Prompt "choose an option to manage"
                Switch($Action){
                    "1"{
                    Write-Host ""
                    Write-Host "Search a Process by name      [1]  "
                    Write-Host "Stop a Process by name        [2]  "
                    Write-Host ""
                    $Action = Read-Host -Prompt "Choose an option"
                    Switch($Action){
                        "1"{
                            # Ask for process name
                            $process = Read-Host -Prompt "Search for a process"
                            # Search for process
                            $processFound = Get-Process -Name "*$process*"
                            # List up Process/es if some were found
                            if($processFound.Count -ge "1"){
                                Write-Host "The following process was found:"
                                $processFound
                            }
                            # Display message if nothing was found and continue
                            else{
                                Write-Host "No Process running with the name '$process'"
                            }
                        }
                        "2"{
                            # Ask for process name
                            $process = Read-Host -Prompt "Search for process to stop"
                            # Search for process
                            $processFound = Get-Process -Name "*$process*"
                            # stop Process/es if some were found
                            if($processFound.Count -ge "1"){
                                Write-Host "Closing Process/es.."
                                Stop-Process -Name $processFound.Name
                                Start-Sleep(2)
                                Write-Host "Process closed."
                            }
                            # Display message if nothing was found and continue
                            else{
                                Write-Host "No Process running with the name '$process'"
                            }
                        }
                        # Displayed if no valid option is chosen in Process Manager
                        Default{ Write-Host "Error. Enter a valid option."}
                    }
                    }
                    "2"{
                    Write-Host ""
                    Write-Host "Search a Service by name      [1]  "
                    Write-Host "Stop a Service by name        [2]  "
                    Write-Host "Reboot a Service by name      [3]  "
                    Write-Host ""
                    $Action = Read-Host -Prompt "Choose an option"
                    Switch($Action){
                        "1"{
                            # Get service to search for
                            $service = Read-Host -Prompt "Search for a Service"
                            # Search for service 
                            $servicesearch = Get-Service -Name "*$service*" 
                            # Will be run if service/es were found
                            if ($servicesearch.count -ge "1"){
                                Write-Host "Following Service was found:"
                                $servicesearch
                            }
                            # Display message if no service could be found
                            else{
                                Write-Host "No service with the name '$service' could be found."
                            }
                        }
                        "2"{
                            $service = Read-Host -Prompt "Enter service name to stop"
                            # Search for service 
                            $servicesearch = Get-Service -Name "*$service*" 
                            # Will be run if service/es were found
                            if ($servicesearch.count -ge "1"){
                                Write-Host "Stopping Service.."
                                Stop-Service $servicesearch
                                Write-Host "Service Stopped."
                            }
                            # Display message if no service could be found
                            else{
                                Write-Host "No service with the name '$service' could be found."
                            }
                        }
                        "3"{
                            $service = Read-Host -Prompt "Enter service name to reboot"
                            # Search for service 
                            $servicesearch = Get-Service -Name "*$service*" 
                            # Will be run if service/es were found
                            if ($servicesearch.count -ge "1"){
                                Write-Host "Rebooting Service.."
                                Restart-Service $servicesearch
                                Write-Host "Service rebooted."
                            }
                            # Display message if no service could be found
                            else{
                                Write-Host "No service with the name '$service' could be found."
                            }
                        }
                        # Will be run if no valid option is entered
                        Default{ Write-Host "Error. Enter a valid option."}
                    }
                    }

                    # Will be run if no valid Manager was chosen / numbers 3 and above
                    Default{ Write-Host "Error. Enter a valid option."}
                
                }
            }
            
                        
                    
        }
        "7"{                                                                                          # Action 7

            Write-Host "Disable Mouse   [1]"
            Write-Host "Enable Mouse    [2]"
            $Action = Read-Host -prompt "What would you like to do"
            switch($Action){
                "1" {
                    Write-Host "Disabling mouse.."
                    # This disables the mouse, by disabling the drivers that the mouse uses.
                    Invoke-Command -ComputerName $computer -Credential $credentials -ScriptBlock {
                        $mouseDeviceId = (Get-PnpDevice -Class "Mouse" | Where-Object {$_.Status -eq "OK"}).InstanceId
                        Disable-PnpDevice -InstanceId $mouseDeviceId -Confirm:$false -ErrorAction SilentlyContinue
                    }
                    Write-Host "Mouse disabled."
                }
                "2" {
                    Write-Host "Enabling mouse.."
                    # This enables the mouse, by enabling the drivers that the mouse uses.
                    Invoke-Command -ComputerName $computer -Credential $credentials -ScriptBlock {
                        $mouseDeviceId = (Get-PnpDevice -Class "Mouse" | Where-Object {$_.Status -eq "Error"}).InstanceId
                        Enable-PnpDevice -InstanceId $mouseDeviceId -Confirm:$false -ErrorAction SilentlyContinue
                    }
                    Write-Host "Mouse enabled."
                }

                # Executed if no valid Action is entered.
                Default {Write-Host "Please enter a valid Action.."}
            }
            
            
        }
        "8"{                                                                                           # Action 8
            # Get message from user
            $msg = Read-Host -prompt "What would you like to say"
            
            # Try to send message to remote Computer
            if (!(Invoke-WmiMethod -Path Win32_Process -Name Create -ArgumentList "msg * $msg" -ComputerName $computer -Credential $credentials -ErrorAction SilentlyContinue)){
                
                ### Gets executed if computer is not Remote ###

                # Get Local Computerinfo
                $computerInfo = Get-ComputerInfo
                # Split Computerinfo
                $currentUser = $computerInfo.CsUserName.TrimStart("EUHCNET\")

                # Send current local user message
                if (!(msg.exe $currentUser /SERVER:$computer $msg)){
                    # Gets displayed if message gets delivered to local Computer
                    Write-Host "Your message was successfully delivered" 
                }
                else {
                    # Gets displayed if message couldn't be delivered to remote or local computer
                    Write-Host "Your message couldn't be delivered. Try again later." 
                }
                
                
            }
            else{
                # Gets displayed if message gets delivered to remote Computer
                Write-Host "Your message was successfully delivered" 
            }
        }
        "9"{                                                                                           # Action 9
            # Set Path with Computer name
            $path = "\\$computer\c$"
            explorer.exe $path # Opens explorer on Computer network path 
        }
        "10"{                                                                                          # Action 10
            # Make output prettier
            Write-Host""
            Write-Host "Drive Status:"
            Write-Host ""
            Invoke-Command -ComputerName $computer -Credential $credentials -ScriptBlock {
                
                # Get the Volumes that have a drive letter assigned
                $volumes = Get-Volume | Where-Object -Property "DriveLetter" -NE $null

                foreach ( $volume in $volumes ) {


                    $sizeGB = [math]::Round($volume.Size / 1GB, 2) # Math: Convert the Full disk space from bytes to Gigabytes ==> Round the resulting Gigabyte values to two decimals
                    $freeSpaceGB = [math]::Round($volume.SizeRemaining / 1GB, 2) # Math: Convert the remaining disk space from bytes to Gigabytes and Round the resulting Gigabyte values to two decimals

                 
                    # Set the color to red if the free space is less than 10 % of Disk size else mark disk as green
                    $color = if ($freeSpaceGB -lt ($sizeGB * ( 10 / 100 ))) { 'Red' } else { 'Green' }

                    # Set $color to DarkYellow if the disk size is almost 0 or 0
                    if($sizeGB -lt 0.1 ){
                        $color = 'DarkYellow'
                    }
                    if($volume.FileSystemLabel -eq ""){
                        $volume.FileSystemLabel = "System"
                    }
                
                    # Display information based on color set above (if free space less than 10% it gets displayed as critical else it will be displayed as healthy)
                    if($color -eq "Red"){
                        Write-Host "Drive $($volume.DriveLetter): $($volume.FileSystemLabel) - Size: $($sizeGB)GB, Free Space: $($freeSpaceGB)GB - " -NoNewline
                        Write-Host -ForegroundColor $color "Free Space Lower than 10%" 
                    }
                    Elseif($color -eq "Green"){
                        Write-Host "Drive $($volume.DriveLetter): $($volume.FileSystemLabel) - Size: $($sizeGB)GB, Free Space: $($freeSpaceGB)GB - " -NoNewline
                        Write-Host -ForegroundColor $color "Healthy" 
                    }
                    Elseif($color -eq "DarkYellow"){
                        Write-Host "DVD Drive: $($volume.DriveLetter) - Size: $($sizeGB)GB, Free Space: $($freeSpaceGB)GB - " -NoNewline 
                        Write-Host -ForegroundColor $color "This is a DVD slot" 
                    }
                    
                    
                    $volumeList += ,$volume
                
                }
                
                # Display a separator line
                Write-Host "---------------------------------------------"


            }
        }
        "11"{                                                                                       # Action 11 (doesn't work for remote computers)                                                                                
            # List the available Manager options 
            Write-Host ""
            Write-Host "Recover To Normal       [1]  "
            Write-Host "Set custom cursor       [2]"
            Write-Host ""
    
            $Action = Read-Host -prompt "What would you like to do"
            switch($Action){
                "1" {
                    $CSharpSig = @'
                    [DllImport("user32.dll", EntryPoint = "SystemParametersInfo")]
                    public static extern bool SystemParametersInfo(
                        uint uiAction,
                        uint uiParam,
                        uint pvParam,
                        uint fWinIni);
'@

                    # Set the path to the cursor file you want to use
                    $cursorPath = "C:\Windows\Cursors\aero_link.cur"
                    # Set the registry key for the cursor
                    Set-ItemProperty -Path "HKCU:\Control Panel\Cursors" -Name "Hand" -Value $cursorPath
                    
                    $CursorRefresh = Add-Type -MemberDefinition $CSharpSig -Name WinAPICall -Namespace SystemParamInfo -PassThru
                    $CursorRefresh::SystemParametersInfo(0x0057,0,$null,0)
                
                    }
                
                "2" { 
                    Write-Host "Copy your custom file to 'C:\Windows\Cursors' with the name custom_cur.cur"
                    Read-Host -Prompt "Press Enter when you're ready"

                    $CSharpSig = @'
                    [DllImport("user32.dll", EntryPoint = "SystemParametersInfo")]
                    public static extern bool SystemParametersInfo(
                        uint uiAction,
                        uint uiParam,
                        uint pvParam,
                        uint fWinIni);
'@

                        # Set the path to the cursor file you want to use
                        $cursorPath = "C:\Windows\Cursors\custom_cur.cur"
                        # Set the registry key for the cursor
                        Set-ItemProperty -Path "HKCU:\Control Panel\Cursors" -Name "Hand" -Value $cursorPath

                        $CursorRefresh = Add-Type -MemberDefinition $CSharpSig -Name WinAPICall -Namespace SystemParamInfo -PassThru
                        $CursorRefresh::SystemParametersInfo(0x0057,0,$null,0)
                        
                    

                }
            }
        }
        "99"{                                                                                          # Action 99
            Write-Host "Type [1]  : Shutdown the remote Computer after any amount of time"
            Write-Host "Type [2]  : Reboot the remote Computer after any amount of time "
            Write-Host "Type [3]  : List some Information about the remote Computer and the current User"
            Write-Host "Type [4]  : Execute a custom Powershell Command on the remote Computer"
            Write-Host "Type [5]  : List the Installed Software on remote Computer"
            Write-Host "Type [6]  : This function, lets you search or stop processes and gives you the `n`t    option to Search, restart or Stop services."
            Write-Host "Type [7]  : Gives you the option to disable or enable a USB Device."
            Write-Host "Type [8]  : Lets you send a Message to the user currently working on the machine"
            Write-Host "Type [9]  : Open Explorer with path to remote Computer where you can Edit, `n`t    view & create files including folders."
            Write-Host "Type [10] : List Information about the Harddrives on the Remote or Local `n`t    Computer. When the Threshhold of 10% free space is exceeded the Disk gets displayed as Red / Critical "
            Write-Host "Type [11] : Set a custom cursor for Computer. THIS ONLY WORKS FOR LOCAL COMPUTERS "
            Write-Host "Type [99] : List these details."

        }
    }

    ### Conclusion / What happens after Action is done ###

    # Do-While loop to errorhandle userinput
    do{
        # Ask User if he wants to Execute another Action
        $validInput = Read-Host -Prompt "Would you like to execute another action? [Y / n]"

        switch ($validInput){
            # If Userinput is "Y" it sets the variable $continue to true which starts the do-loop again
            "Y" {
                $continue = $true
            }
            # If Userinput is "N" it sets the variable $continue to false which exits the script in the end
            "N"{
                $continue = $false
            }
            # Gets executed if Userinput is not Y or N
            Default{Write-Host "Please Write [Y] or [N]"}
        }

    }while( $validInput -ne "Y" -and $validInput -ne "N" ) # While the user doesn't input Y or N he gets prompted again


}while ($continue)

