[CmdletBinding()]
Param
(
    [Parameter(Mandatory = $true)]
    [String]
    $DeployerID,

    [Parameter(Mandatory = $true)]
    [String]
    $DeployerPassword,

    [Parameter(Mandatory = $true)]
    [String]
    $Environment,

    [parameter(Mandatory = $true)] 
    [String] 
    $DataFactoryName,

    [parameter(Mandatory = $true)] 
    [String] 
    $ResourcegroupName,

    [parameter(Mandatory = $true)] 
    [String[]]
    $TriggersToDeploy,

    [parameter(Mandatory = $true)] 
    [String] 
    $FilePath
 )

If (!$Environment) 
{
    Write-Error "`$Environment variable is not specified. Skipping the execution..."
    Break;
}

If (!$DataFactoryName) 
{
    $DataFactoryName = "$($Environment.ToLower())" + "alignbiadfci"
}

If (!$ResourceGroupName) 
{
    $ResourceGroupName = "$($Environment.ToLower())" + "alignbiadfcirg"
}

## Import the Az module
Install-Module "Az" -Force -AllowClobber
Import-Module -Name "Az" -Force

## Initial Values - Only for testing
$TenantId = "9ac44c96-980a-481b-ae23-d8f56b82c605" #Align tenant ID - same for all subscriptions 

## Encrypt the password
$DepPassword = ConvertTo-SecureString $DeployerPassword -AsPlainText -Force
$PSCredential = New-Object System.Management.Automation.PSCredential($DeployerID, $DepPassword)

## Connect to Azure Context
Connect-AzAccount -ServicePrincipal -Credential $PSCredential -TenantId $TenantId

# Select right Azure Subscription
$SubName = $Environment.ToUpper()
$SubscriptionName = "BI-DW-$SubName"
Set-AzContext -Subscription $SubscriptionName -ErrorAction Stop | Out-Null

# If the trigger already exists, temporarily stop it and store it in one array
$TemporarilyStoppedTriggers = @()

Foreach ($TriggerName in $TriggersToDeploy) 
{
    ## Check if the trigger already exists, if yes, stop it
    $TriggerInstance = Get-AzDataFactoryV2Trigger -ResourceGroupName $ResourceGroupName `
    -DataFactoryName $DataFactoryName `
    -TriggerName $TriggerName `
    -ErrorAction SilentlyContinue

    if($TriggerInstance -ne $null)
    {
        $TemporarilyStoppedTriggers += $TriggerName
        Stop-AzDataFactoryV2Trigger -ResourceGroupName $ResourceGroupName -DataFactoryName $DataFactoryName -Name $TriggerName -Force -ErrorAction Stop
        Write-Host "Stopping the Trigger : $TriggerName"
    }

    $TriggerJSONFile = "$FilePath/trigger/" + $TriggerName + ".JSON"

    # Create/Update the trigger
    Set-AzDataFactoryV2Trigger -ResourceGroupName $ResourceGroupName `
    -DataFactoryName $DataFactoryName `
    -Name $TriggerName `
    -DefinitionFile $TriggerJSONFile -Force -ErrorAction Stop

    Write-Host "$TriggerName deployed successfully"
}

# Start the temporarily stopped triggers
Foreach ($TemporarilyStoppedTrigger in $TemporarilyStoppedTriggers)
{
    Start-AzDataFactoryV2Trigger -ResourceGroupName $ResourceGroupName `
        -DataFactoryName $DataFactoryName `
        -Name $TemporarilyStoppedTrigger `
        -Force -ErrorAction Stop

    Write-Host "$TemporarilyStoppedTrigger started successfully."
}
