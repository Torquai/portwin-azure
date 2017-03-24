$subscriptionId = "66c96f4e-ae9e-4ffe-a06c-0b9dc1daaad4"

#Location in Azure to place resources
$resourceGroupLocation = "North Europe"

#Resourcegroup prefix to generate new resourcegroups
$resourceGroupPrefix = "thomas-devtest"

#Parameters to use as base for environment
#Valid names: dev
$baseEnvironment = "dev"

$parameters = @{}
$parameters.Add("environment", $baseEnvironment);

#Url for parameters
$baseParameterUrl = "https://github.com/Torquai/portwin-azure/raw/master/Portwin/parameters/"

#Url for templates
$baseTemplateUrl = "https://github.com/Torquai/portwin-azure/raw/master/Portwin/templates/"

$resourceGroupAuxName = $resourceGroupPrefix + "-aux"
$resourceGroupInsightsName = $resourceGroupPrefix + "-insights"
$resourceGroupStorageName = $resourceGroupPrefix + "-storage"
$resourceGroupWebName = $resourceGroupPrefix + "-web"

$parameterEnvironmentUrl = $baseParameterUrl + $baseEnvironment + ".json"
$parameterInsightsUrl = $baseParameterUrl + $baseEnvironment + ".insights.json"
$parameterStorageUrl = $baseParameterUrl + $baseEnvironment + ".storage.json"
$parameterServiceplanUrl = $baseParameterUrl + $baseEnvironment + ".serviceplan.json"

$templateInsightsUrl = $baseTemplateUrl + "templateInsights.json"
$templateStorageUrl = $baseTemplateUrl + "templateStorage.json"
$templateServiceplanUrl = $baseTemplateUrl + "templateServiceplan.json"
$templateFrontendUrl = $baseTemplateUrl + "templateFrontend.json"

# sign in
Write-Host "Logging in...";
Login-AzureRmAccount;

# select subscription
Write-Host "Selecting subscription '$subscriptionId'";
Select-AzureRmSubscription -SubscriptionID $subscriptionId;

# Start the deployment
Write-Host "Deploying application insights to resourcegroup '$resourceGroupInsightsName'...";
New-AzureRmResourceGroup -Name $resourceGroupInsightsName -Location $resourceGroupLocation -Force -ErrorAction SilentlyContinue
New-AzureRmResourceGroupDeployment -Mode Incremental -ResourceGroupName $resourceGroupInsightsName -TemplateUri $templateInsightsUrl -TemplateParameterUri $parameterInsightsUrl -TemplateParameterObject $parameters -Verbose
Write-Host "Finished deployment of application insights"
