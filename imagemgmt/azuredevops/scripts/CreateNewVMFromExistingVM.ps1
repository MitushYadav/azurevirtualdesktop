<#
.DESCRIPTION
This script creates a new VM from an existing VM.
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    [string]
    $SourceResourceGroupName,
    [Parameter(Mandatory=$true)]
    [string]
    $SourceVMName,
    [Parameter(Mandatory=$true)]
    [string]
    $DestinationResourceGroupName,
    [Parameter(Mandatory=$true)]
    [string]
    $DestinationVMName,
    [Parameter(Mandatory=$true)]
    [string]
    $DestinationVNetworkName,
    [Parameter(Mandatory=$true)]
    [string]
    $DestinationSubnetName,
    [Parameter(Mandatory=$false)]
    [string]
    $DestinationVmSize = "Standard_D2as_v5",
    [Parameter(Mandatory=$false)]
    [switch]
    $CreatePublicIP
)

#region CreateSnapshot
$Location = (Get-AzResourceGroup -Name $SourceResourceGroupName).Location
$snapshotName = "mySnapshot-$(get-date -f ddMMyyyyHHmm)"

$srcVm = Get-AzVM -ResourceGroupName $SourceResourceGroupName -Name $SourceVMName
$snapshot = New-AzSnapshotConfig -SourceUri $($srcVm.StorageProfile.OsDisk.ManagedDisk.Id) -Location $Location -CreateOption copy

# create the source VM disk snapshot in the same resource group as the VM.
$vmSnapshot = New-AzSnapshot -Snapshot $snapshot -SnapshotName $snapshotName -ResourceGroupName $SourceResourceGroupName

#endregion

#region CreateVMFromSnapshot
$newOsDiskName = $($DestinationVMName + "-osdisk")
$diskConfig = New-AzDiskConfig -SkuName $storageType -Location $location -CreateOption Copy -SourceResourceId $($vmSnapshot.Id) -DiskSizeGB $diskSize
$newOsDisk = New-AzDisk -Disk $diskConfig -ResourceGroupName $DestinationResourceGroupName -DiskName $newOsDiskName

if($CreatePublicIP) {
    # create a public IP for the VM
    $pipName = $($DestinationVmName + "-pip")
    $pip = New-AzPublicIpAddress -Name $pipName -ResourceGroupName $DestinationResourceGroupName -Location $location -AllocationMethod Static
}


# create a NIC and attach the public IP to it
$nicName = $($DestinationVMName + "-nic")
$nsgName = $($DestinationVMName + "-nsg")

$nsgObj = New-AzNetworkSecurityGroup -Name $nsgName -ResourceGroupName $DestinationResourceGroupName -Location $Location
$vNetObj = Get-AzVirtualNetwork -Name $DestinationVNetworkName
$subnetObj = Get-AzVirtualNetworkSubnetConfig -Name $DestinationSubnetName -VirtualNetwork $vNetObj
$nicOptions = @{
    Name = $nicName
    ResourceGroupName = $DestinationResourceGroupName
    Location = $location
    SubnetId = $subnetObj.Id
    NetworkSecurityGroupId = $nsgObj.Id
}

if($CreatePublicIP) {
    $nicOptions.Add("PublicIpAddressId", $pip.Id)
}

$nic = New-AzNetworkInterface @nicOptions

# create the VM
$vmConfig = New-AzVMConfig -VMName $DestinationVMName -VMSize $vmSize

$vm = Add-AzVMNetworkInterface -VM $vmConfig -Id $nic.Id
$destVmStorageAccountType = $srcVm.storageprofile.osdisk.manageddisk.StorageAccountType
$destVmOsDiskSize = $srcVm.StorageProfile.OsDisk.DiskSizeGB
$vm = Set-AzVMOSDisk -VM $vm -ManagedDiskId $newOsDisk.Id -StorageAccountType $destVmStorageAccountType -DiskSizeInGB $destVmOsDiskSize -CreateOption Attach -Windows

New-AzVM -ResourceGroupName $DestinationResourceGroupName -Location $location -VM $vm

#endregion

# rename new VM computer
$sb = [scriptblock]{
    param(
        [string] $VMNewName
    )
    Rename-Computer -NewName $VMNewName -Force -Restart
}

Invoke-AzVMRunCommand -ResourceGroupName $DestinationResourceGroupName -Name $DestinationVMName -CommandId 'RunPowerShellScript' -ScriptString $sb -Parameter @{'VMNewName' = $DestinationVMName}