#Set global Variables
$credential = Get-Credential -Credential helpdesk@school.edu
$password = ConvertTo-SecureString -AsPlainText “TempPass1” -Force 
$users = Get-Content -Path users.txt
$body = Get-Content body.htm -Raw


#for testing
#users = dongearhart 
#$emailList = dongearhart@school.edu

$ids = New-Object 'system.collections.arraylist'
ForEach ($user in $users) 
{
    Get-ADUser $user | Set-ADAccountPassword -NewPassword $password -Reset
    Get-ADUser $user | Set-AdUser -ChangePasswordAtLogon $true
    Disable-ADAccount -Identity $user
    Write-Host “Password has been reset for the user: $user”
    $userAccount = Get-ADUser -Identity $user -Properties employeeID,info
    $oldinfo = $userAccount.info
    $newinfo = "Disabled due to spamming $date - DG"
    If ($oldinfo -ne $null){
        Set-ADUser $user -replace @{info="$oldinfo`r`n$newinfo"}
        }Else{
        Set-ADUser $user -replace @{info=$newinfo}
    }
    $ids.Add($userAccount.EmployeeID);
}
    
#join the string of IDs with commas
$idsCSV = ($ids-join ',')

#Query SIS for alternate emails
write-host 'Pulling emails from SIS for the following IDs:' $idsCSV
$emailList = Invoke-Sqlcmd -Query "SELECT SyStudentID as ID, LastName as Last, FirstName as First, Email as school_Email, OtherEmail as Alt_Email FROM SyStudent with(nolock) WHERE SyStudentID in ($($idsCSV))" -ServerInstance "databaseserver" -Database "StudentInformationSystem" 
write-host $emailList.Alt_Email

#Send email to each recipient separately
ForEach ($emailAddress in $emailList) 
{
    Send-MailMessage -To $emailAddress.Alt_Email -Bcc "donith913@school.edu" -From "helpdesk@school.edu"  -Subject "Your school Account Password Has Been Reset" -BodyAsHtml -Body $body -SmtpServer "smtp.office365.com" -UseSsl -Credential $credential
}
