<#
.DESCRIPTION
This script creates a VM in Azure using an existing ARM template
#>

[CmdletBinding()]
param (
    [Parameter()]
    [string]
    $VMTemplateFilePath,
    [string]
    $ResourceGroupName
)

New-AzResourceGroupDeployment -ResourceGroupName $ResourceGroupName -TemplateFile "$PSScriptRoot\deployAzureVM-Windows-QSTemplate.json"