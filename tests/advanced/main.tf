data "azurerm_subscription" "current" {}

resource "azurerm_resource_group" "rg_asr_test_advanced" {
  name     = "rg-test-vm-advanced-resources"
  location = "UK South"
}

module "vnet" {
  source              = "github.com/SoftcatMS/azure-terraform-vnet"
  vnet_name           = "vnet-asr-test-advanced"
  resource_group_name = azurerm_resource_group.rg_asr_test_advanced.name
  address_space       = ["10.11.0.0/16"]
  subnet_prefixes     = ["10.11.1.0/24"]
  subnet_names        = ["subnet1"]

  tags = {
    environment = "test"
    engineer    = "ci/cd"
  }

  depends_on = [azurerm_resource_group.rg_asr_test_advanced]
}


resource "azurerm_network_interface" "vm1_nic" {
  name                = "vm1-asr-test-advanced-nic"
  resource_group_name = azurerm_resource_group.rg_asr_test_advanced.name
  location            = azurerm_resource_group.rg_asr_test_advanced.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = module.vnet.vnet_subnets[0]
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "vm1" {
  name                            = "vm1-asr-test-advanced"
  resource_group_name             = azurerm_resource_group.rg_asr_test_advanced.name
  location                        = azurerm_resource_group.rg_asr_test_advanced.location
  size                            = "Standard_B1ls"
  admin_username                  = "adminuser"
  admin_password                  = "4Compl3xP4ssw0rd"
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.vm1_nic.id,
  ]

  os_disk {
    name                 = "vm1-asr-test-advanced-os"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
}


module "asr" {
  source                        = "../../"
  location_primary              = "uksouth"
  location_secondary            = "westeurope"
  asr_cache_resource_group_name = azurerm_resource_group.rg_asr_test_advanced.name
  resource_group_name_secondary = "UKW-RG-ADVANCED-TEST-ASR"
  asr_vault_name                = "UKW-ASR-ADVANCED-TEST-VAULT"
  existing_vnet_id_primary      = module.vnet.vnet_id
  existing_vm_primary = [
    {
      vm_name            = "vm1-asr-test-advanced"
      vm_id              = azurerm_linux_virtual_machine.vm1.id
      vm_osdisk_id       = "${data.azurerm_subscription.current.id}/resourceGroups/${azurerm_resource_group.rg_asr_test_advanced.name}/providers/Microsoft.Compute/disks/vm1-asr-test-advanced-os"
      vm_osdisk_type     = "Standard_LRS"
      vm_existing_nic_id = azurerm_network_interface.vm1_nic.id
      vm_pubip           = true
      vm_datadisks       = []
    }
    # {
    #   vm_name            = "WinVM-Test2"
    #   vm_id              = "/subscriptions/b5daafd9-87e5-4d14-9e0a-7009ef189fb8/resourceGroups/VM-Test/providers/Microsoft.Compute/virtualMachines/WinVM-Test2"
    #   vm_osdisk_id       = "/subscriptions/b5daafd9-87e5-4d14-9e0a-7009ef189fb8/resourceGroups/VM-TEST/providers/Microsoft.Compute/disks/WinVM-Test2_disk1_64c880b958a14cbc8cedce7f043475f1"
    #   vm_osdisk_type     = "Premium_LRS"
    #   vm_existing_nic_id = "/subscriptions/b5daafd9-87e5-4d14-9e0a-7009ef189fb8/resourceGroups/VM-Test/providers/Microsoft.Network/networkInterfaces/winvm-test2148"
    #   vm_pubip           = false
    #   vm_datadisks = [
    #     {
    #       id   = "/subscriptions/b5daafd9-87e5-4d14-9e0a-7009ef189fb8/resourceGroups/VM-Test/providers/Microsoft.Compute/disks/winvm-test2_datadisk1"
    #       type = "Premium_LRS"
    #     },
    #     {
    #       id   = "/subscriptions/b5daafd9-87e5-4d14-9e0a-7009ef189fb8/resourceGroups/VM-Test/providers/Microsoft.Compute/disks/winvm-test2_datadisk2"
    #       type = "Premium_LRS"
    #     },
    #     {
    #       id   = "/subscriptions/b5daafd9-87e5-4d14-9e0a-7009ef189fb8/resourceGroups/VM-Test/providers/Microsoft.Compute/disks/winvm-test2_datadisk3"
    #       type = "Premium_LRS"
    #     }
    #   ]
    # }
  ]

  depends_on = [azurerm_linux_virtual_machine.vm1]

}
