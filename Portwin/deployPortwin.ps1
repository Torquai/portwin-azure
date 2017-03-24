$subscriptionId = "66c96f4e-ae9e-4ffe-a06c-0b9dc1daaad4"

#Location in Azure to place resources
$resourceGroupLocation = "North Europe"

#Resourcegroup prefix to generate new resourcegroups
$resourceGroupPrefix = "thomas-devtest"

$parameters = @{
    "environment" = "dev";
    "sqlAdminLoginName" = "sqladmin";
    "sqlAdminPassword" = "a!r(Fc#&blah"

    "storageSkuName" = "Standard_LRS";
    "storageSkuTier" = "Standard";
};

#Url for parameters
$baseParameterUrl = "https://github.com/Torquai/portwin-azure/raw/master/Portwin/parameters/"

#Url for templates
$baseTemplateUrl = "https://github.com/Torquai/portwin-azure/raw/master/Portwin/templates/"



# sign in
Write-Host "Logging in...";
Login-AzureRmAccount;

# select subscription
Write-Host "Selecting subscription '$subscriptionId'";
Select-AzureRmSubscription -SubscriptionID $subscriptionId;

# Start deployment of application insights
$resourceGroupInsightsName = $resourceGroupPrefix + "-insights"
$templateUri = $baseTemplateUrl + "templateInsights.json"

Write-Host "Deploying application insights to resourcegroup '$resourceGroupInsightsName'...";
#New-AzureRmResourceGroup -Name $resourceGroupInsightsName -Location $resourceGroupLocation -Force -ErrorAction SilentlyContinue
#New-AzureRmResourceGroupDeployment `
#    -Mode Incremental `
#    -ResourceGroupName $resourceGroupInsightsName `
#    -TemplateUri $templateUri `
#    -TemplateParameterObject @{ environment=$baseEnvironment; } `
#    -Verbose;
Write-Host "Finished deployment of application insights"


# Start deployment of storage
$resourceGroupStorageName = $resourceGroupPrefix + "-storage"
$templateUri = $baseTemplateUrl + "templateStorage.json"
$storageParameters = @{ "environment" = $parameters.Get_Item("environment") };

Write-Host "Deploying storage to resourcegroup '$resourceGroupStorageName'...";
New-AzureRmResourceGroup -Name $resourceGroupStorageName -Location $resourceGroupLocation -Force -ErrorAction SilentlyContinue
New-AzureRmResourceGroupDeployment `
    -Mode Incremental `
    -ResourceGroupName $resourceGroupStorageName `
    -TemplateUri $templateUri `
    -TemplateParameterObject $storageParameters `
    -Verbose;
Write-Host "Finished deployment of storage resources"
