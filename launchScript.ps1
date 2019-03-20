#Path to Python
$python = 'C:\iKitchen\Python\MobilConceptsOvenSafety\DeviceAPI\venv\Scripts\python.exe'
#Path to ikitchen python file
$ikitchen = 'C:\iKitchen\Python\MobilConceptsOvenSafety\DeviceAPI\scripts\i_kitchen.py'
#Path to iKitchen exe
$ikitchenApp = 'C:\iKitchen\Application\MobileConcepts.IKitchenPresenter.exe'
#Username you want the program to run as
$targetUser = 'ikitchen'

function runScriptAsUser{
    param(
        $python,
        $ikitchen,
        $ikitchenApp,
        $targetUser
    )
    if ($env:USERNAME -like $targetUser){
        #Run the command
        #Write-Host 'Running command: ' $command
        #iKitchen API - to run in a command window, change WindowStyle to Minimized or comment it out completely
        Start-Process -FilePath $python -ArgumentList $ikitchen -WindowStyle Hidden
        #iKitchen application
        Start-Process -FilePath $ikitchenApp
        #If necessary this could be piped to a Wait-Process and followed by a stop-process on process to kill the API on oprocess exit
    }
}

runScriptAsUser -python $python -ikitchen $ikitchen -ikitchenApp $ikitchenApp -targetUser $targetUser