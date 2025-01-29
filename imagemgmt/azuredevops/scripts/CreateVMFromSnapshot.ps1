<#
.DESCRIPTION
This script creates a new VM from an existing disk snapshot
#>

[CmdletBinding()]
param (
    [Parameter()]
    [string]
    $SnapshotName
)

$resourceGroupName = "rg-name"
$newOsDiskName = "nyNewDisk01"
$newVMName = "myNewVM"
$location = "eastus"

$storageType = 'Premium_LRS'
$diskSize = '128'

$snapshot = Get-AzSnapshot -SnapshotName $SnapshotName -ResourceGroupName $resourceGroupName

$diskConfig = New-AzDiskConfig -SkuName $storageType -Location $location -CreateOption Copy -SourceResourceId $snapshot.Id -DiskSizeGB $diskSize

$newOsDisk = New-AzDisk -Disk $diskConfig -ResourceGroupName $resourceGroupName -DiskName $newOsDiskName

# assuming a subnet and a vnet already exists
$vNetName = "myVnet"
$subnetName = "mySubnetName"

# create a public IP for the VM
$ipName = "myIP"
$pip = New-AzPublicIpAddress -Name $ipName -ResourceGroupName $destinationResourceGroup -Location $location -AllocationMethod Dynamic

# create a NIC and attach the public IP to it
$nicName = "myNicName"
$nic = New-AzNetworkInterface -Name $nicName -ResourceGroupName $destinationResourceGroup -Location $location -SubnetId $vnet.Subnets[0].Id -PublicIpAddressId $pip.Id -NetworkSecurityGroupId $nsg.Id

# create the VM
$vmConfig = New-AzVMConfig -VMName $newVMName -VMSize "Standard_D4s"

$vm = Add-AzVMNetworkInterface -VM $vmConfig -Id $nic.Id
$vm = Set-AzVMOSDisk -VM $vm -ManagedDiskId $newOsDisk.Id -StorageAccountType Standard_LRS -DiskSizeInGB 128 -CreateOption Attach -Windows

New-AzVM -ResourceGroupName $destinationResourceGroup -Location $location -VM $vm