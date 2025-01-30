# Create Image Definition for a generalized image, ie final image for new session host creation
$imageDefinition = New-AzGalleryImageDefinition -GalleryName $gallery.Name -ResourceGroupName $gallery.ResourceGroupName -Location $gallery.Location -Name 'myImageDefinition' -OsState generalized -OsType Windows -Publisher 'myPublisher' -Offer 'myOffer' -Sku 'mySKU'

# Create Image Definition for storing an image which has to be reused.
$imageDefinition = New-AzGalleryImageDefinition -GalleryName $gallery.Name -ResourceGroupName $gallery.ResourceGroupName -Location $gallery.Location -Name 'myImageDefinition' -OsState specialized -OsType Windows -Publisher 'myPublisher' -Offer 'myOffer' -Sku 'mySKU'