# https://learn.microsoft.com/en-us/azure/virtual-machines/image-version?tabs=powershell%2Ccli2#create-an-image

$region1 = @{Name='South Central US';ReplicaCount=1}
   $region2 = @{Name='East US';ReplicaCount=2}
   $targetRegions = @($region1,$region2)

$job = $imageVersion = New-AzGalleryImageVersion -GalleryImageDefinitionName $imageDefinition.Name -GalleryImageVersionName '1.0.0' -GalleryName $gallery.Name -ResourceGroupName $gallery.ResourceGroupName -Location $gallery.Location -TargetRegion $targetRegions -SourceImageId $sourceVm.Id.ToString() -PublishingProfileEndOfLifeDate '2020-12-01' -asJob

New-AzGalleryImageVersion -GalleryImageDefinitionName $imageDefinition.Name -GalleryImageVersionName '1.0.0' -GalleryName $gallery.Name -ResourceGroupName $gallery.ResourceGroupName -Location $gallery.Location -TargetRegion $targetRegions -SourceImageVMId $sourceVm.Id.ToString() -PublishingProfileEndOfLifeDate '2020-12-01' -asJob