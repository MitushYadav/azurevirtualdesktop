<#
.DESCRIPTION
This script installs the PSWindowsUpdate module and uses it to apply Windows updates on the machine.
#>

[CmdletBinding()]
param (
)

$logfile = "C:\Windows\Temp\WinUpdateStep_log.log"
function Write-Log
{
Param ([string]$LogString)
$Stamp = (Get-Date).toString("yyyy/MM/dd HH:mm:ss")
$LogMessage = "$Stamp $LogString"
Add-content $LogFile -value $LogMessage
}



# install the NuGet package provider if required
if(-not(Get-PackageProvider -Name Nuget -ListAvailable -ErrorAction SilentlyContinue)) {
    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
    Write-Log -LogString "Installed the Nuget Package Provider"
}

# Install the PSWindowsUpdate moduele
if(-not(Get-Module -Name "PSWindowsUpdate" -ListAvailable -ErrorAction SilentlyContinue)) {
    # Module is not installed
    Install-Module -Name PSWindowsUpdate -Scope AllUsers -Force -Confirm:$false
    Write-Log -LogString "Installed the PSWindowsUpdate module"
}

Import-Module PSWindowsUpdate
Write-Log -LogString "Imported the PsWindowsUpdate module"

try {
    Install-WindowsUpdate -Install -MicrosoftUpdate -AcceptAll | Out-File "C:\Windows\Temp\$(get-date -f yyyy-MM-dd)-WindowsUpdate.log" -Force
    Write-log -LogString "ran the windowsupdate part"
}
catch {
    Write-Host "Error while updating Windows: $($_.Exception.Message)"
    Write-log -LogString "ERROR: $($_.Exception.Message)"
}
