<#
.DESCRIPTION
This script creates a disk snapshot from the os disk of an existing vm.
#>

[CmdletBinding()]
param (
    [Parameter()]
    [string]
    $VMName
)

$resourceGroupName = 'myResourceGroup' 
$location = 'eastus' 
$snapshotName = 'mySnapshot'


$vm = Get-AzVM -ResourceGroupName $resourceGroupName -Name $VMName

$snapshot = New-AzSnapshotConfig -SourceUri $vm.StorageProfile.OsDisk.ManagedDisk.Id -Location $location -CreateOption copy

New-AzSnapshot -Snapshot $snapshot -SnapshotName $snapshotName -ResourceGroupName $resourceGroupName