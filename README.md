# Terraform Practice

### Practicing Terraform with Azure. This project is for learning purposes only

### Infrastructure Requirements
* Azure Resource Group
* Azure Linux Web App
    * Should be http2
    * Should have staging deployment slot
* Azure Key Vault
* Azure Storage Account
    * staging container
    * Should only use Azure AD as authentication
* Create Group
    * Include me as a member
    * Include app service identity as member
    * Assign Key Vault Secrets Officer and Storage Account Data Contributor Roles
* Azure App Insights
* Azure App Registrations
    * 1 for SPA
        * 
    * 1 for API
        * Expose API
