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
    $ReleaseName
)

## Initial Values - Only for testing
$TenantId = "9ac44c96-980a-481b-ae23-d8f56b82c605" #Align tenant ID - same for all subscriptions 

## Encrypt the password
$DepPassword = ConvertTo-SecureString $DeployerPassword -AsPlainText -Force
$PSCredential = New-Object System.Management.Automation.PSCredential($DeployerID, $DepPassword)

## Import the Az module
Install-Module "Az" -Force -AllowClobber
Import-Module -Name "Az" -Force

## Connect to Azure Context
Connect-AzAccount -ServicePrincipal -Credential $PSCredential -TenantId $TenantId

## Select the Azure Subscription
$SubscriptionName = "BI-DW-$Environment"
Set-AzContext -Subscription $SubscriptionName -ErrorAction Stop | Out-Null

## Collect the trigger information
Write-Output "Getting triggers from [$DataFactoryName] present in the resource group [$ResourceGroupName]..."

$AllTriggers = Get-AzDataFactoryV2Trigger -DataFactoryName $DataFactoryName -ResourceGroupName $ResourceGroupName -ErrorAction Stop

$XML_Path = “Triggers-$ReleaseName.xml”

# Create the XML File Tags
$xmlWriter = New-Object System.XMl.XmlTextWriter($XML_Path,$Null)
$xmlWriter.Formatting = 'Indented'
$xmlWriter.Indentation = 1
$XmlWriter.IndentChar = "`t"
$xmlWriter.WriteStartDocument()
$xmlWriter.WriteStartElement('Triggers')
$xmlWriter.WriteEndElement()
$xmlWriter.WriteEndDocument()
$xmlWriter.Flush()
$xmlWriter.Close()

## Get all the trigger information
$xmlDoc = [System.Xml.XmlDocument](Get-Content $XML_Path);
$AllTriggers | ForEach-Object { 

    $triggerNode = $xmlDoc.CreateElement("Trigger")

    $TriggerNameElement = $triggerNode.AppendChild($xmlDoc.CreateElement("TriggerName"))
    $TriggerNameElement.InnerText = $_.Name

    $ResourceGroupNameElement = $triggerNode.AppendChild($xmlDoc.CreateElement("ResourceGroupName"))
    $ResourceGroupNameElement.InnerText = $_.ResourceGroupName

    $DataFactoryNameElement = $triggerNode.AppendChild($xmlDoc.CreateElement("DataFactoryName"))
    $DataFactoryNameElement.InnerText = $_.DataFactoryName

    $RuntimeStateElement = $triggerNode.AppendChild($xmlDoc.CreateElement("RuntimeState"))
    $RuntimeStateElement.InnerText = $_.RuntimeState

    $xmlDoc.SelectSingleNode("//Triggers").AppendChild($triggerNode)
}

$xmlDoc.Save($XML_Path)


## Stopping the 'Started' triggers
If ($AllTriggers) 
{
    $ActiveTriggers = $AllTriggers | Where-Object { $_.properties.runtimeState -eq "Started" -and ($_.properties.pipelines.Count -gt 0 -or $_.properties.pipelines.pipelineReference -ne $null)}
}
If ($ActiveTriggers) 
{
    #Stop all triggers
    Write-Output "Stopping deployed triggers in datafactory [$DataFactoryName]"

    $ActiveTriggers | ForEach-Object { 
        Write-Output "Disabling trigger:: $($_.Name) in datafactory [$DataFactoryName]"
        Try 
        {
            Stop-AzDataFactoryV2Trigger -ResourceGroupName $ResourceGroupName -DataFactoryName $DataFactoryName -Name $_.name -Force -ErrorAction Stop
        }
        Catch 
        {
            Write-Error "Failed to stop the trigger [$($_.Name)] in the datafactory [$DataFactoryName]. Skipping the execution..."
            Write-Output "Error Message :: $($_.Exception.Message)" 
            Write-Output "Error command :: $($_.InvocationInfo.PositionMessage)"      
            Break
        }
            
    }
}
Else 
{
    Write-Output "No active triggers found in the datafactory [$DataFactoryName]."
}

## Uploading the file to blob

# Define Variables - QA3 - This is fixed and not going to change, hence hardcoded
$StorageAccountRG = "qa3alignbirg"
$StorageAccountName = "sharedalignbiblob"
$StorageContainerName = $DataFactoryName

# Select right Azure Subscription
$SubscriptionName = "BI-DW-QA3"
Set-AzContext -Subscription $SubscriptionName -ErrorAction Stop | Out-Null

# Get Storage Account Key
$StorageAccountKey = (Get-AzStorageAccountKey -ResourceGroupName $StorageAccountRG -AccountName $StorageAccountName).Value[0]

# Set AzStorageContext
$DestinationContext = New-AzStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $StorageAccountKey

# Upload File and overwrite if exists
$UploadFile = @{
    Context = $DestinationContext;
    Container = "$StorageContainerName";
    File = "$XML_Path";
    }

Set-AzStorageBlobContent @UploadFile -Force

Write-Output "Trigger information is stored in [$XML_Path] in container [$StorageContainerName] in Azure Storage Account [$StorageAccountName]"

## $xmlDoc.SelectNodes("/Triggers/Trigger[RuntimeState='Stopped']")
## $xmlDoc.SelectNodes("/Triggers/Trigger[RuntimeState='Started']")