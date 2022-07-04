module "asr" {
    source                          = "../../"
    location_primary                = "uksouth"
    location_secondary              = "westeurope"
    asr_cache_resource_group_name   = "RSG-UKS-INSTANCES-TRAINING"
    resource_group_name_secondary   = "rg-asr-secondary"
    asr_vault_name                  = "asr-vault-replication"
    
    existing_vm_primary = [
        {
        vm_name                         = "UKS-TRAINING-VM01"
        vm_id                           = "/subscriptions/652f2afd-d7ca-4ffb-977e-de679adc4b03/resourceGroups/RSG-UKS-INSTANCES-TRAINING/providers/Microsoft.Compute/virtualMachines/UKS-TRAINING-VM01"
        vm_osdisk_id                    = "/subscriptions/652f2afd-d7ca-4ffb-977e-de679adc4b03/resourceGroups/RSG-UKS-INSTANCES-TRAINING/providers/Microsoft.Compute/disks/UKS-TRAINING-VM01-osdisk"
        vm_osdisk_type                  = "Premium_LRS"
        }
    ]

    existing_vm_datadisks = [
        {
            vm_datadisk_id    = "/subscriptions/652f2afd-d7ca-4ffb-977e-de679adc4b03/resourceGroups/RSG-UKS-INSTANCES-TRAINING/providers/Microsoft.Compute/disks/UKS-TRAINING-VM01_DataDisk_0"
            vm_datadisk_type  = "StandardSSD_LRS"
        }
    ]

    existing_vm_networkinteface_id      = "/subscriptions/652f2afd-d7ca-4ffb-977e-de679adc4b03/resourceGroups/RSG-UKS-INSTANCES-TRAINING/providers/Microsoft.Network/networkInterfaces/UKS-TRAINING-VM01-nic"
    existing_vnet_id_primary            = "/subscriptions/652f2afd-d7ca-4ffb-977e-de679adc4b03/resourceGroups/RSG-UKS-TRAINING-VNET-01/providers/Microsoft.Network/virtualNetworks/training-vnet-01"

}