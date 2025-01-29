# generate hostpool registration info

$parameters = @{
    HostPoolName = '<HostPoolName>'
    ResourceGroupName = '<ResourceGroupName>'
    ExpirationTime = $((Get-Date).ToUniversalTime().AddHours(24).ToString('yyyy-MM-ddTHH:mm:ss.fffffffZ'))
}

New-AzWvdRegistrationInfo @parameters

$parameters = @{
    HostPoolName = '<HostPoolName>'
    ResourceGroupName = '<ResourceGroupName>'
}

$registrationToken = (Get-AzWvdHostPoolRegistrationToken @parameters).Token


# IMPORTANT : JOIN THE VM EITHER TO ENTRA ID OR AD BEFORE PROCEEDING

$uris = @(
    "https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RWrmXv"
    "https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RWrxrH"
)

$installers = @()
foreach ($uri in $uris) {
    $download = Invoke-WebRequest -Uri $uri -UseBasicParsing

$fileName = ($download.Headers.'Content-Disposition').Split('=')[1].Replace('"','')
    $output = [System.IO.FileStream]::new("$pwd\$fileName", [System.IO.FileMode]::Create)
    $output.write($download.Content, 0, $download.RawContentLength)
    $output.close()
    $installers += $output.Name
}

foreach ($installer in $installers) {
    Unblock-File -Path "$installer"
}

# Install the Remote Desktop Services Infrastructure Agent
Start-Process -FilePath "msiexec.exe" -ArgumentList "/i","Microsoft.RDInfra.RDAgent.Installer-x64-<version>.msi","/quiet","REGISTRATIONTOKEN=<RegistrationToken>" -Wait

# Install the BootLoader
Start-Process -FilePath "msiexec.exe" -ArgumentList "/i","Microsoft.RDInfra.RDAgentBootLoader.Installer-x64.msi","/quiet" -Wait

# THE VM SHOULD START SHOWING AS SESSION HOST. AFTER STATUS BECOME AVAILABLE, REBOOT THE VM.