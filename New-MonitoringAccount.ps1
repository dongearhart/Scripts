<#
Don Gearhart
https://github.com/dongearhart

Quick and dirty script to enable WinRM and create a local administrator account for monitoring for machines not on the domain. 

To do:
1) Needs a proper logging function and stop using write-host like a noob. 
2) This script has literally no error handling at all. 
3) Create comment based help. 
#>

function New-MonitoringAccount {
    param (
        $Username = 'monitoring',
        $Password = 'P@ssw0rd',
        $Description = "Service Account for Monitoring",
        $Group = 'Administrators'
    )

    #Check if part of a domain
    if((Get-WmiObject -Class Win32_ComputerSystem).PartOfDomain){
        #Code to check for a domain account and maybe create it. Decided against this. 
        <#
        #Check if the $Username service account exists on this domain account exists on this domain
        if(!(Get-AdUser -Identity $Username)){
            New-ADUser -Name $Username -Description $Description
        }
        else {
            Write-Host "User $Username already exists for this domain"
        }#>
        Write-Host "This machine is bound to a domain. Please create a domain account and add it to the necessary group via Group Policy"
        Start-Sleep -s 30
        Exit
    }
    Write-Host "Creating account username: $username with password: $password and adding it to the administrators group"
    # Local account control was introudced in WMF 5.1
    if($PSVersionTable.PSVersion.Major -eq 5 -and $PSVersionTable.PSVersion.Minor -ge 1 -or $PSVersionTable.PSVersion.Major -eq 6){
        
        #Creates a secure string to pass to the New-LocalUser cmdlet since it won't accept plaintext. 
        $Secure_String_Pwd = ConvertTo-SecureString $Password -AsPlainText -Force 

        Write-Host "Using native powershell to create the account"
        #Check if local account $Username exists
        if(!(Get-LocalUser -Name $Username)){
            #Create local account
            New-LocalUser -Name $Username -Password $Secure_String_Pwd -Description $Description -AccountNeverExpires -PasswordNeverExpires 
        }
        #Add to the remote management users group. 
        Add-LocalGroupMember -Group $Group -Member $Username
    }
    # Go old school on this sucker and use old Win32 executibles to do the above for Server 2012 and older. 
    else{
        Write-Host "Using legacy net command to create user"
        NET USER $Username $Password /ADD
        NET LOCALGROUP $Group $Username  /ADD
        WMIC USERACCOUNT WHERE "Name='$Username'" SET PasswordExpires=FALSE
    }
    #Enable PowerShell Remoting
    Write-Host "Configuring PSRemoting"
    Enable-PSRemoting -Force
}

New-MonitoringAccount -Username 'demo' -Password 'd3moP@ssword'