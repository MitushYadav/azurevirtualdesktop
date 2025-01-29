<#
.DESCRIPTION
This script creates a new VM from an existing VM.
#>

[CmdletBinding()]
param (
    [Parameter()]
    [string]
    $SourceResourceGroupName,
    [Parameter()]
    [string]
    $SourceVMName,
    [Parameter()]
    [string]
    $DestinationResourceGroupName,
    [Parameter()]
    [string]
    $DestinationVMName,
    [Parameter()]
    [string]
    $DestinationVNetworkName,
    [Parameter()]
    [string]
    $DestinationSubnetName

)

#region CreateSnapshot
$Location = (Get-AzResourceGroup -Name $SourceResourceGroupName).Location
$snapshotName = "mySnapshot-$(get-date -f ddMMyyyyHHmm)"

$srcVm = Get-AzVM -ResourceGroupName $SourceResourceGroupName -Name $SourceVMName

$snapshot = New-AzSnapshotConfig -SourceUri $srcVm.StorageProfile.OsDisk.ManagedDisk.Id -Location $Location -CreateOption copy

$vmSnapshot = New-AzSnapshot -Snapshot $snapshot -SnapshotName $snapshotName -ResourceGroupName $SourceResourceGroupName

#endregion

#region CreateVMFromSnapshot
$vmSize = "Standard_D2as_v5"

# new disk details
$newOsDiskName = "myNewDisk01"
$storageType = 'Premium_LRS'
$diskSize = '128'

# assuming a subnet and a vnet already exists
$vNetName = "myVnet"
$subnetName = "mySubnetName"

#$snapshotObj = Get-AzSnapshot -SnapshotName $SnapshotName -ResourceGroupName $SourceResourceGroupName

$diskConfig = New-AzDiskConfig -SkuName $storageType -Location $location -CreateOption Copy -SourceResourceId $vmSnapshot.Id -DiskSizeGB $diskSize
$newOsDisk = New-AzDisk -Disk $diskConfig -ResourceGroupName $DestinationResourceGroupName -DiskName $newOsDiskName

# create a public IP for the VM
$pipName = "myIP"
$pip = New-AzPublicIpAddress -Name $pipName -ResourceGroupName $DestinationResourceGroupName -Location $location -AllocationMethod Static

# create a NIC and attach the public IP to it
$nicName = "myNicName"
$nsgName = "myNewNSG"

$nsgObj = New-AzNetworkSecurityGroup -Name $nsgName -ResourceGroupName $DestinationResourceGroupName -Location $Location
$vNetObj = Get-AzVirtualNetwork -Name $DestinationVNetworkName
$subnetObj = Get-AzVirtualNetworkSubnetConfig -Name $DestinationSubnetName -VirtualNetwork $vNetObj
$nic = New-AzNetworkInterface -Name $nicName -ResourceGroupName $DestinationResourceGroupName -Location $location -SubnetId $subnetObj.Id -PublicIpAddressId $pip.Id -NetworkSecurityGroupId $nsgObj.Id

# create the VM
$vmConfig = New-AzVMConfig -VMName $DestinationVMName -VMSize $vmSize

$vm = Add-AzVMNetworkInterface -VM $vmConfig -Id $nic.Id
$vm = Set-AzVMOSDisk -VM $vm -ManagedDiskId $newOsDisk.Id -StorageAccountType Standard_LRS -DiskSizeInGB 128 -CreateOption Attach -Windows

New-AzVM -ResourceGroupName $DestinationResourceGroupName -Location $location -VM $vm

# rename new VM computer
$sb = [scriptblock]{
    param(
        [string] $VMNewName
    )
    Rename-Computer -NewName $VMNewName -Force -Restart
}

Invoke-AzVMRunCommand -ResourceGroupName $DestinationResourceGroupName -Name $DestinationVMName -CommandId 'RunPowerShellScript' -ScriptString $sb -Parameter @{'VMNewName' = $DestinationVMName}