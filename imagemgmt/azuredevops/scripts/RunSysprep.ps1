<#
.DESCRIPTION
This script syspreps the current VM on which the script is running.
IMPORTANT: Run it only on the VM to be sysprepped. 

Author: Mitush Yadav
#>

try {
    Start-Process -FilePath "C:\Windows\System32\Sysprep\sysprep.exe" -ArgumentList "/generalize","/shutdown","/oobe" -Wait
}
catch {
    Write-Host "Error while sysprepping: $($_.Exception.Message)"
    Write-Host "Please check the logs in the SysPrep\Panther folder"
}