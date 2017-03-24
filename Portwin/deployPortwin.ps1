$subscriptionId = "66c96f4e-ae9e-4ffe-a06c-0b9dc1daaad4"
$resourceGroupName = "templatetest"
$resourceGroupLocation = "North Europe"

$StorageTemplate = ".\templateStorage.json"
$StorageParameters = ".\parameters.dev.storage.json"

$InsightsTemplate = ".\templateInsights.json"
$InsightsParameters = ".\parameters.dev.insights.json"

$TemplateFile = ".\templateServicePlan.json"
$ParameterFile = ".\parameters.dev.json"


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
Write-Host "Starting deployment...";
New-AzureRmResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile $InsightsTemplate -TemplateParameterFile $InsightsParameters -DeploymentDebugLogLevel All;
#New-AzureRmResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile $StorageTemplate -TemplateParameterFile $StorageParameters -DeploymentDebugLogLevel All;

