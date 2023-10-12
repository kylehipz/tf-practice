output "resource_group_id" {
  value = azurerm_resource_group.rg.id
}

output "app_insights_cs" {
  value = azurerm_application_insights.ai.connection_string
  sensitive = true
}
