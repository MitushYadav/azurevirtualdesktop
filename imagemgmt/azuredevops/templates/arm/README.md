# Templates

This folder contains the templates required for resource deployment in Azure using the pipelines.

`basevm` : contains the ARM templates to create a base VM from the marketplace images.
`sessionhosts` : contains the ARM templates to create an AVD session host from an Azure Compute Gallery image version.
 - `newVMFromGallery` : creates a new session host from a Azure Compute Gallery image version.
 - `managedDisks-galleryvm` : creates new session hosts from a marketplace image. 