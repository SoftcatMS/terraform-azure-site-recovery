resource "azurerm_resource_group" "rg_asr_test_basic" {
  name     = "rg-test-vm-basic-resources"
  location = "UK South"
}

module "vnet" {
  source              = "github.com/SoftcatMS/azure-terraform-vnet"
  vnet_name           = "vnet-asr-test-basic"
  resource_group_name = azurerm_resource_group.rg_asr_test_basic.name
  address_space       = ["10.10.0.0/16"]
  subnet_prefixes     = ["10.10.1.0/24"]
  subnet_names        = ["subnet1"]

  tags = {
    environment = "test"
    engineer    = "ci/cd"
  }

  depends_on = [azurerm_resource_group.rg_asr_test_basic]
}

module "asr" {
  source                        = "../../"
  location_primary              = "uksouth"
  location_secondary            = "westeurope"
  asr_cache_resource_group_name = azurerm_resource_group.rg_asr_test_basic.name
  resource_group_name_secondary = "UKW-RG-TEST-ASR"
  asr_vault_name                = "UKW-ASR-TEST-VAULT"
  existing_vnet_id_primary      = module.vnet.vnet_id

  depends_on = [module.vnet]

}
