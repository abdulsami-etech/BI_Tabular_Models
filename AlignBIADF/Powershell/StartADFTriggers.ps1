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
    [String] 
    $FiePath,

    [parameter(Mandatory = $true)] 
    [String] 
    $ReleaseName
)

## Initial Values - Only for testing
$TenantId = "9ac44c96-980a-481b-ae23-d8f56b82c605" #Align tenant ID - same for all subscriptions 
$TriggerNamesToExcludeFromStarting = ""

# Define Variables - QA3 - This is fixed and not going to change, hence hardcoded
$StorageAccountRG = "qa3alignbirg"
$StorageAccountName = "sharedalignbiblob"
$StorageContainerName = $DataFactoryName

## Encrypt the password
$DepPassword = ConvertTo-SecureString $DeployerPassword -AsPlainText -Force
$PSCredential = New-Object System.Management.Automation.PSCredential($DeployerID, $DepPassword)

## Import the Az module
Install-Module "Az" -Force -AllowClobber
Import-Module -Name "Az" -Force

## Connect to Azure Context
Connect-AzAccount -ServicePrincipal -Credential $PSCredential -TenantId $TenantId

# Select right Azure Subscription
$SubscriptionName = "BI-DW-QA3"
Set-AzContext -Subscription $SubscriptionName -ErrorAction Stop | Out-Null

# Get Storage Account Key
$StorageAccountKey = (Get-AzStorageAccountKey -ResourceGroupName $StorageAccountRG -AccountName $StorageAccountName).Value[0]

# Set AzStorageContext
$StorageContext = New-AzStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $StorageAccountKey

$BlobName = “Triggers-$ReleaseName.xml”

Get-AzStorageBlobContent -Blob "$BlobName" `
  -Container "$StorageContainerName" `
  -Destination "$FiePath" `
  -Context $StorageContext 

## Select the Azure Subscription
$SubscriptionName = "BI-DW-$Environment"
Set-AzContext -Subscription $SubscriptionName -ErrorAction Stop | Out-Null

## Collect the trigger information
$XML_Path = $FiePath + “\$BlobName”

## Get all the trigger information
$xmlDoc = [System.Xml.XmlDocument](Get-Content $XML_Path)
$ActiveTriggers = $xmlDoc.SelectNodes("/Triggers/Trigger[RuntimeState='Started']")

foreach($ActiveTrigger in $ActiveTriggers)
{
    $TriggerName = $ActiveTrigger.TriggerName
    
    #Start all triggers
    Write-Output "Starting deployed triggers in [$DataFactoryName] present in the resource group [$ResourceGroupName] ..."

    If ($TriggerNamesToExcludeFromStarting.Count -gt 0) 
    {                
        If ($TriggerNamesToExcludeFromStarting -icontains $TriggerName) 
        {
            Write-Output "Trigger:: [ $TriggerName ] is in the exclusion list. So ignoring to start the trigger ..."
        }
        Else 
        {
            Write-Output "Starting trigger:: [$TriggerName] in the datafactory [$DataFactoryName]"
            Try 
            {
                Start-AzDataFactoryV2Trigger -ResourceGroupName $ResourceGroupName -DataFactoryName $DataFactoryName -Name $TriggerName -Force  -ErrorAction Stop
            }
            Catch 
            {
                Write-Error "Failed to start the trigger [$TriggerName] in the datafactory [$DataFactoryName]. Skipping the execution..."
                Write-Output "Error Message :: $($_.Exception.Message)" 
                Write-Output "Error command :: $($_.InvocationInfo.PositionMessage)"      
                Break
            }            
        }
                
    }
    Else 
    {
        Write-Output "Starting trigger:: [$TriggerName] in the datafactory [$DataFactoryName]"
        Try 
        {
            Start-AzDataFactoryV2Trigger -ResourceGroupName $ResourceGroupName -DataFactoryName $DataFactoryName -Name $TriggerName -Force  -ErrorAction Stop
        }
        Catch 
        {
            Write-Error "Failed to start the trigger [$TriggerName] in the datafactory [$DataFactoryName]. Skipping the execution..."
            Write-Output "Error Message :: $($_.Exception.Message)" 
            Write-Output "Error command :: $($_.InvocationInfo.PositionMessage)"     
            Break
        }
    }
}
