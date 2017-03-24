$subscriptionId = "66c96f4e-ae9e-4ffe-a06c-0b9dc1daaad4"
$resourceGroupName = "templatetest"
$resourceGroupLocation = "North Europe"

$resourceGroupPrefix = "devtest"
$environment = "devtest"

$baseParameterUrl = "https://github.com/Torquai/portwin-azure/blob/master/Portwin/parameters/"

$baseTemplateUrl = "https://github.com/Torquai/portwin-azure/blob/master/Portwin/templates/"
$templateInsightsFile = $baseTemplateUrl + "templateInsights.json"
$templateStorageFile = $baseTemplateUrl + "templateStorage.json"
$templateServiceplanFile = $baseTemplateUrl + "templateServiceplan.json"
$templateFrontendFile = $baseTemplateUrl + "templateFrontend.json"

# sign in
Write-Host "Logging in...";
Login-AzureRmAccount;

# select subscription
Write-Host "Selecting subscription '$subscriptionId'";
Select-AzureRmSubscription -SubscriptionID $subscriptionId;

#Create or check for existing resource group
$resourceGroup = Get-AzureRmResourceGroup -Name $resourceGroupName -ErrorAction SilentlyContinue
if(!$resourceGroup)
{
    Write-Host "Creating resource group '$resourceGroupName' in location '$resourceGroupLocation'";
    New-AzureRmResourceGroup -Name $resourceGroupName -Location $resourceGroupLocation
}
else{
    Write-Host "Using existing resource group '$resourceGroupName'";
}

# Start the deployment
Write-Host "Deploying application insights...";
New-AzureRmResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile $InsightsTemplate -TemplateParameterFile $InsightsParameters -Verbose;
Write-Host "Finished deployment of application insights"

Write-Host "Deploying storage"

Write-Host "Finished deployment of storage"

#New-AzureRmResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile $StorageTemplate -TemplateParameterFile $StorageParameters -DeploymentDebugLogLevel All;

