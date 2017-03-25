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

$paramRedisCacheSku = "Basic";
$paramRedisCacheSkuFamily = "C";
$paramRedisCacheSkuCapacity = 1;

$paramServicePlanTier = "Standard";
$paramServicePlanFamily = "S";
$paramServicePlanSize = "1"

# sign in
Write-Host "Logging in...";
Login-AzureRmAccount;

# select subscription
Write-Host "Selecting subscription '$subscriptionId'";
Select-AzureRmSubscription -SubscriptionID $subscriptionId;



#---------------------------- Start deployment of application insights
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



#---------------------------- Start deployment of storage
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



#---------------------------- Start deployment of Asp
$aspResourceGroupName = $resourceGroupPrefix + "-web"
$aspParamaters = @{
    "environment" = $paramEnvironment;

    "redisCacheSku" = $paramRedisCacheSku;
    "redisCacheSkuFamily" = $paramRedisCacheSkuFamily;
    "redisCacheSkuCapacity" = $paramRedisCacheSkuCapacity;

    "ServicePlanTier" = $paramServicePlanTier;
    "ServicePlanFamily" = $paramServicePlanFamily;
    "ServicePlanSize" = $paramServicePlanSize;
}

Write-Host "Deploying Asp to resourceGroup '$aspResourceGroupName'...";
New-AzureRmResourceGroup -Name $aspResourceGroupName -Location $resourceGroupLocation -Force -ErrorAction SilentlyContinue
$aspResult = New-AzureRmResourceGroupDeployment `
    -Mode Incremental `
    -ResourceGroupName $aspResourceGroupName `
    -TemplateFile ".\templates\templateServiceplan.json" `
    -TemplateParameterObject $aspParamaters `
    -Verbose

$aspRedisCacheUrl = $aspResult.Outputs["redisCacheUrl"].Value;
$aspServicebusEndPoint = $aspResult.Outputs["servicebusEndPoint"].Value;

Write-Host "Finished deployment of Asp"

Write-Host "Outputs:";
Write-Host "SettingsConnectionString:" $settingsDatabaseConnectionString;
Write-Host "HangfireConnectionString: " $hangfireDatabaseConnectionString;
Write-Host "FrontendKey: " $frontendInsightsKey;
Write-Host "GatewayKey: " $gatewayInsightsKey;
Write-Host "SettingsKey: " $settingsInsightsKey;
Write-Host "BackofficeKey: " $backofficeInsightsKey;
Write-Host "BackofficeClientKey: " $backofficeClientInsightsKey;