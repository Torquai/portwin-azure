$subscriptionId = "66c96f4e-ae9e-4ffe-a06c-0b9dc1daaad4"

#Location in Azure to place resources
$resourceGroupLocation = "North Europe"

#Resourcegroup prefix to generate new resourcegroups
$resourceGroupPrefix = "thomas-devtest"

#Environment to generate
$paramEnvironment = "devtest";

$paramSqlAdminLoginName = "sqladmin";
$paramSqlAdminPassword = "a!r(Fc#&blah";

$paramStorageSkuName = "Standard_LRS";
$paramStorageSkuTier = "Standard";


# sign in
Write-Host "Logging in...";
Login-AzureRmAccount;

# select subscription
Write-Host "Selecting subscription '$subscriptionId'";
Select-AzureRmSubscription -SubscriptionID $subscriptionId;

# Start deployment of application insights
$resourceGroupInsightsName = $resourceGroupPrefix + "-insights"
$insightParameters = @{
    "environment" = $paramEnvironment
};

Write-Host "Deploying application insights to resourcegroup '$resourceGroupInsightsName'...";
New-AzureRmResourceGroup -Name $resourceGroupInsightsName -Location $resourceGroupLocation -Force -ErrorAction SilentlyContinue
$insightsResult = New-AzureRmResourceGroupDeployment `
    -Mode Incremental `
    -ResourceGroupName $resourceGroupInsightsName `
    -TemplateFile ".\templates\templateInsights.json" `
    -TemplateParameterObject $insightParameters `
    -Verbose;

$frontendInsightsKey = $insightsResult.Outputs["frontendKey"].Value;
$settingsInsightsKey = $insightsResult.Outputs["settingsKey"].Value;
$gatewayInsightsKey = $insightsResult.Outputs["gatewayKey"].Value;
$backofficeInsightsKey = $insightsResult.Outputs["backofficeKey"].Value;
$backofficeClientInsightsKey = $insightsResult.Outputs["backofficeClientKey"].Value;

Write-Host "Finished deployment of application insights"


# Start deployment of storage
$resourceGroupStorageName = $resourceGroupPrefix + "-storage"
$storageParameters = @{ 
    "environment" = $paramEnvironment;
    
    "sqlAdminLoginName" = $paramSqlAdminLoginName;
    "sqlAdminPassword" = $paramSqlAdminPassword;
    
    "storageSkuTier" = $paramStorageSkuTier;
    "storageSkuName" = $paramStorageSkuName;
};

Write-Host "Deploying storage to resourcegroup '$resourceGroupStorageName'...";
New-AzureRmResourceGroup -Name $resourceGroupStorageName -Location $resourceGroupLocation -Force -ErrorAction SilentlyContinue
$storageResult = New-AzureRmResourceGroupDeployment `
    -Mode Incremental `
    -ResourceGroupName $resourceGroupStorageName `
    -TemplateFile ".\templates\templateStorage.json" `
    -TemplateParameterObject $storageParameters `
    -Verbose;

$settingsDatabaseConnectionString = $storageResult.Outputs["settingsDatabaseConnectionString"].Value;
$hangfireDatabaseConnectionString = $storageResult.Outputs["hangfireDatabaseConnectionString"].Value;

Write-Host "Finished deployment of storage resources"

Write-Host "Outputs:";
Write-Host "SettingsConnectionString:" $settingsDatabaseConnectionString;
Write-Host "HangfireConnectionString: " $hangfireDatabaseConnectionString;
Write-Host "FrontendKey: " $frontendInsightsKey;
Write-Host "GatewayKey: " $gatewayInsightsKey;
Write-Host "SettingsKey: " $settingsInsightsKey;
Write-Host "BackofficeKey: " $backofficeInsightsKey;
Write-Host "BackofficeClientKey: " $backofficeClientInsightsKey;