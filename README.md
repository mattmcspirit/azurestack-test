# Credits

Brandon Royal

# Instructions

## Installation with PowerShell

```
Login-AzureRmAccount

git clone https://github.com/friism/azure-test

cd azure-test

$resource_group_name="<some-resource-group-you-pre-created>"

$adminPassword="<some-pw-with-special-char-and-capital-letters>"
$sshPublicKey="<your-pup-key>"
$prefix="<some-prefix-less-than-7-chars>"
$ucpVersion="2.2.0-20c177f"
$dtrVersion="2.2.5"
$dockerVersion="17.06.0-ce-rc2"
$workerCount=1
$hubUsername="<your-hub-username>"
$hubPassword="<your-hub-password>"

$parameters = @{ 'hubUsername'= $hubUsername; 'hubPassword' = $hubPassword; 'workerCount' = $workerCount; 'prefix' = $prefix; 'adminUsername' = "docker"; 'adminPassword' = $adminPassword; 'sshPublicKey' = $sshPublicKey; 'ucpVersion' = $ucpVersion; 'dtrVersion' = $dtrVersion; 'dockerVersion' = $dockerVersion }

New-AzureRmResourceGroupDeployment -ResourceGroupName $resource_group_name `
  -TemplateUri 'https://raw.githubusercontent.com/friism/azure-test/master/azuredeploy.json' `
  -TemplateParameterObject $parameters `
  -Verbose

```

## Setup

1. Find `MGR_UCP_HOSTNAME` in deployment output in Azure portal. Visit this in browser (using `https`) and log in with `admin` and the admin password
2. Visit `/manage/resources/nodes/create` to get the swarm join command
3. Remote-desktop into each worker (the above sample creates just one) and run the join command in PowerShell

Your swarm is now ready to use