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

    # Folder name where the published ARM templates are present
    [parameter(Mandatory = $true)] 
    [String] 
    $rootFolder,    

    [parameter(Mandatory = $false)] 
    [String] 
    $DataFactoryName,

    [parameter(Mandatory = $false)] 
    [String] 
    $ResourcegroupName,
    # Array of trigger names which should be excluded from the deletion list
    # Pass the orphaned trigger names which are not part of the current ARM template deployments
    # If you pass the trigger names which are part of ARM templates, it won't take any delete action
    [parameter(Mandatory = $false)]
    [String[]] 
    $TriggerNamesToExcludeFromDeletion,
    # Array of pipeline names which should be excluded from the deletion list
    # Pass the orphaned pipeline names which are not part of the current ARM template deployments
    # If you pass the pipeline names which are part of ARM templates, it won't take any delete action
    [parameter(Mandatory = $false)]
    [String[]] 
    $PipelineNamesToExcludeFromDeletion,
    # Array of dataset names which should be excluded from the deletion list
    # Pass the orphaned dataset names which are not part of the current ARM template deployments
    # If you pass the dataset names which are part of ARM templates, it won't take any delete action
    [parameter(Mandatory = $false)] 
    [String[]] 
    $DatasetNamesToExcludeFromDeletion,
    # Array of linked service names which should be excluded from the deletion list
    # Pass the orphaned linked service names which are not part of the current ARM template deployments
    # If you pass the linked service names which are part of ARM templates, it won't take any delete action
    [parameter(Mandatory = $false)] 
    [String[]] 
    $LinkedServiceNamesToExcludeFromDeletion,
    # Array of integration runtime names which should be excluded from the deletion list
    # Pass the orphaned integration runtime names which are not part of the current ARM template deployments
    # If you pass the integration runtime names which are part of ARM templates, it won't take any delete action
    [parameter(Mandatory = $false)] 
    [String[]] 
    $IntegrationRuntimeNamesToExcludeFromDeletion = @('AlignSelfhostedIR')

)

Function Get-AzV2PipelinesListAPI {
    Param  
    (     
        # Azure Tenant ID.  
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()] 
        [String]  
        $TenantId,  
            
        # Client ID
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]  
        [String]  
        $ClientId,
        
        # Client  Secret.  
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]  
        [String]  
        $ClientSecret,  
            
        # Subscription ID
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]  
        [String]  
        $SubscriptionId,
        
        # Resource group Name.  
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]  
        [String]  
        $ResourceGroupName,  
            
        # Data factory name
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]  
        [String]  
        $ADFfactoryName    
                 
    )

    $body=@{grant_type="client_credentials"
    resource="https://management.core.windows.net/"
    client_id="$ClientId"
    client_secret="$ClientSecret"}
    $tokenResponse=Invoke-RestMethod -Uri "https://login.microsoftonline.com/$TenantId/oauth2/token" -Method Post -Body $body
    $access_token=$tokenResponse.access_token

    If ($access_token -eq $null) {
        Write-Error "Can't get the access token from the Azure with the specified credentials ..."
    }

    $header =@{
    "Content-Type"="application/json"
    "Authorization"="Bearer $access_token"
    }

    $TotalPipelinesObject = @()
    $uri1 = "https://management.azure.com/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.DataFactory/factories/$ADFfactoryName/pipelines?api-version=2018-06-01"

    $Ite = 1
    Do{
        Write-Host "Page Results # $ite"
        Try {
            $PipelinesResult = Invoke-RestMethod -Uri $uri1 -Method Get -Headers $header
        }
        Catch {
            Write-Host "Failed to get the pipelines list from ADF $DataFactoryName present in the resource group $ResourceGroupName Using the API. Exiting the script "
            Write-Host "Error Message :: $($_.Exception.Message)" 
            Write-Error "Error command :: $($_.InvocationInfo.PositionMessage)"    
            Break ;
        }
        $TotalPipelinesObject += $($PipelinesResult.value)
        $uri1 = $PipelinesResult.nextLink
        $Ite ++
    } until ($uri1 -eq $null)

    Remove-Variable access_token -ErrorAction SilentlyContinue
    return $TotalPipelinesObject
}

If (!$Environment) {
    Write-Error "`$Environment variable is not specified. Skipping the execution..."
    Break;
}
If (!$DataFactoryName) {
    $DataFactoryName = "$($Environment.ToLower())" + "alignbiadfci"
}
If (!$ResourceGroupName) {
    $ResourceGroupName = "$($Environment.ToLower())" + "alignbiadfcirg"
}
$DepPassword = ConvertTo-SecureString $DeployerPassword -AsPlainText -Force
$tenantId = "9ac44c96-980a-481b-ae23-d8f56b82c605" #Align tenant ID - same for all subscriptions 
$pscredential = New-Object System.Management.Automation.PSCredential($DeployerID, $DepPassword)
If (-not (Get-InstalledModule -Name "Az" -ErrorAction SilentlyContinue)) {
    Install-Module -Name "Az" -Force -AllowClobber
}
Import-Module -Name "Az" -Force
Connect-AzAccount -ServicePrincipal -Credential $pscredential -TenantId $tenantId

$SubscriptionName = "BI-DW-$Environment"
Try {
    Set-AzContext -Subscription $SubscriptionName -ErrorAction Stop | Out-Null
}
Catch {
    Write-Output "Failed to set the subscription context for the subscription [$SubscriptionName] with the below error. Skipping the execution..." 
    Write-Output "Error Message :: $($_.Exception.Message)" 
    Write-Error "Error command :: $($_.InvocationInfo.PositionMessage)"     
    Break ;                
}

$SubContext = Get-AzContext
If ($SubContext){
   $SubscriptionId = $SubContext.Subscription.SubscriptionId 
   If ($SubscriptionId -eq $null) {
       Write-Error "Unable to find the subscription ID. Exiting the script ..."
   }
}

$TotalResources = @()    
If (Test-Path $RootFolder) {
    $RootFolder = $RootFolder.TrimEnd("\")
    Try {
        $TotalFileNames = Get-ChildItem -Path $RootFolder | Select-Object name
    }
    Catch {
        Write-Output "Failed to get the files from the path [$RootFolder]. Exiting the script "
        Write-Output "Error Message :: $($_.Exception.Message)" 
        Write-Error "Error command :: $($_.InvocationInfo.PositionMessage)"     
        Break ;            
    }        
    Foreach ($FileName in $TotalFileNames) {
        $Armtemplate = $RootFolder + "\" + $($FileName.Name)
        If ($Armtemplate -match 'json') {
            Try {
                $templateJson = Get-Content $armTemplate | ConvertFrom-Json
            }
            Catch {
                Write-Output "Failed to get the file contents from the file [$armTemplate]. Exiting the script "
                Write-Output "Error Message :: $($_.Exception.Message)" 
                Write-Error "Error command :: $($_.InvocationInfo.PositionMessage)"      
                Break ;  
            }                
            $resources = $templateJson.resources
            $TotalResources += $resources 
        }
    }
}
Else {
    Write-Error "Unable to find the path [$RootFolder] for the JSON templates.`nPlease make sure the path to the templates is correct. Exiting the script ..."
    Break ;
}

If ($TotalResources.count -le 0) {
    Write-Error "Unable to find any resources in the templates present in the path:: [$RootFolder].`nPlease make sure the path to the templates is correct. Exiting the script ..."
    Break ;
}

#Orphaned resources
#Triggers 
Write-Output "Getting all the triggers from ADF $DataFactoryName present in the resource group $ResourceGroupName ..."
Try {
    $triggersADF = Get-AzDataFactoryV2Trigger -DataFactoryName $DataFactoryName -ResourceGroupName $ResourceGroupName -ErrorAction Stop
}
Catch {
    Write-Output "Failed to get the triggers list from ADF $DataFactoryName present in the resource group $ResourceGroupName . Exiting the script "
    Write-Output "Error Message :: $($_.Exception.Message)" 
    Write-Error "Error command :: $($_.InvocationInfo.PositionMessage)"     
    Break ;    
}
If ($triggersADF) {
    If ($TriggerNamesToExcludeFromDeletion) {
        $triggersADF = $triggersADF | Where-Object { $TriggerNamesToExcludeFromDeletion -notcontains $_ }
    }    
    $triggersTemplate = $TotalResources | Where-Object { $_.type -eq "Microsoft.DataFactory/factories/triggers" }
    $triggerNames = $triggersTemplate | ForEach-Object { $_.name.Substring(37, $_.name.Length - 40) }
    Write-Output "Listed below are the orphaned triggers from ADF $DataFactoryName present in the resource group $ResourceGroupName ..."
    $Orphanedtriggers = $triggersADF | Where-Object { $triggerNames -notcontains $_.Name } 
    $Orphanedtriggers 
    If (!$Orphanedtriggers) {
        Write-Output "No orphaned triggers found in ADF $DataFactoryName present in the resource group $ResourceGroupName ..."
    }
}
Else {
    Write-Output "There are no triggers in the ADF $DataFactoryName present in the resource group $ResourceGroupName ..."
}

#pipelines
Write-Output "Getting all the pipelines from ADF $DataFactoryName present in the resource group $ResourceGroupName ..."
Try {
    #$pipelinesADF = Get-AzDataFactoryV2Pipeline -DataFactoryName $DataFactoryName -ResourceGroupName $ResourceGroupName -ErrorAction Stop
    $pipelinesADF = Get-AzV2PipelinesListAPI -TenantId "$tenantId" -ClientId "$DeployerID" -ClientSecret "$DeployerPassword" -SubscriptionId "$SubscriptionId" -ResourceGroupName "$ResourcegroupName" -ADFfactoryName "$DataFactoryName"
    If ($pipelinesADF.count -lt 1) {
        Write-Error "Failed to get the pipelines list from ADF $DataFactoryName present in the resource group $ResourceGroupName using the API. Exiting the script "
    }
}
Catch {
    Write-Output "Failed to get the pipelines list from ADF $DataFactoryName present in the resource group $ResourceGroupName . Exiting the script "
    Write-Output "Error Message :: $($_.Exception.Message)" 
    Write-Error "Error command :: $($_.InvocationInfo.PositionMessage)"    
    Break ;       
}
If ($pipelinesADF) {
    If ($PipelineNamesToExcludeFromDeletion) {
        #$pipelinesADF = $pipelinesADF | Where-Object { $PipelineNamesToExcludeFromDeletion -notcontains $_ }
        $pipelinesADF = $pipelinesADF | Where-Object { $PipelineNamesToExcludeFromDeletion -notcontains $_.Name }
    }    
    $pipelinesTemplate = $TotalResources | Where-Object { $_.type -eq "Microsoft.DataFactory/factories/pipelines" }
    $pipelinesNames = $pipelinesTemplate | ForEach-Object { $_.name.Substring(37, $_.name.Length - 40) }
    Write-Output "Listed below are the orphaned pipelines from ADF $DataFactoryName present in the resource group $ResourceGroupName ..."
    $Orphanedpipelines = $pipelinesADF | Where-Object { $pipelinesNames -notcontains $_.Name }
    $Orphanedpipelines
    If (!$Orphanedpipelines) {
        Write-Output "No orphaned pipelines found in ADF $DataFactoryName present in the resource group $ResourceGroupName ..."
    }
}
Else {
    Write-Output "There are no pipelines in the ADF $DataFactoryName present in the resource group $ResourceGroupName ..."
}

#datasets
Write-Output "Getting all datasets from ADF $DataFactoryName present in the resource group $ResourceGroupName ..."
Try {
    $datasetsADF = Get-AzDataFactoryV2Dataset -DataFactoryName $DataFactoryName -ResourceGroupName $ResourceGroupName -ErrorAction Stop
}
Catch {
    Write-Output "Failed to get the datasets list from ADF $DataFactoryName present in the resource group $ResourceGroupName . Exiting the script "
    Write-Output "Error Message :: $($_.Exception.Message)" 
    Write-Error "Error command :: $($_.InvocationInfo.PositionMessage)"    
    Break ;     
}
If ($datasetsADF) {
    If ($DatasetNamesToExcludeFromDeletion) {
        $datasetsADF = $datasetsADF | Where-Object { $DatasetNamesToExcludeFromDeletion -notcontains $_ }
    }
    $datasetsTemplate = $TotalResources | Where-Object { $_.type -eq "Microsoft.DataFactory/factories/datasets" }
    $datasetsNames = $datasetsTemplate | ForEach-Object { $_.name.Substring(37, $_.name.Length - 40) }
    Write-Output "Listed below are the orphaned datasets from ADF $DataFactoryName present in the resource group $ResourceGroupName ..."
    $Orphaneddatasets = $datasetsADF | Where-Object { $datasetsNames -notcontains $_.Name }
    $Orphaneddatasets
    If (!$Orphaneddatasets) {
        Write-Output "No orphaned datasets found in ADF $DataFactoryName present in the resource group $ResourceGroupName ..."
    }

}
Else {
    Write-Output "There are no datasets in the ADF $DataFactoryName present in the resource group $ResourceGroupName ..."
}

#linkedservices
Write-Output "Getting all linked services from ADF $DataFactoryName present in the resource group $ResourceGroupName ..."
Try {
    $linkedservicesADF = Get-AzDataFactoryV2LinkedService -DataFactoryName $DataFactoryName -ResourceGroupName $ResourceGroupName -ErrorAction Stop
}
Catch {
    Write-Output "Failed to get the linked services list from ADF $DataFactoryName present in the resource group $ResourceGroupName . Exiting the script "
    Write-Output "Error Message :: $($_.Exception.Message)" 
    Write-Error "Error command :: $($_.InvocationInfo.PositionMessage)"    
    Break ;     
}
If ($linkedservicesADF) {
    If ($LinkedServiceNamesToExcludeFromDeletion) {
        $linkedservicesADF = $linkedservicesADF | Where-Object { $LinkedServiceNamesToExcludeFromDeletion -notcontains $_ }
    }
    $linkedservicesTemplate = $TotalResources | Where-Object { $_.type -eq "Microsoft.DataFactory/factories/linkedservices" }
    $linkedservicesNames = $linkedservicesTemplate | ForEach-Object { $_.name.Substring(37, $_.name.Length - 40) }
    Write-Output "Listed below are the orphaned linked services from ADF $DataFactoryName present in the resource group $ResourceGroupName ..."
    $Orphanedlinkedservices = $linkedservicesADF | Where-Object { $linkedservicesNames -notcontains $_.Name }
    $Orphanedlinkedservices
    If (!$Orphanedlinkedservices) {
        Write-Output "No orphaned linked services found in ADF $DataFactoryName present in the resource group $ResourceGroupName ..."
    }
}
Else {
    Write-Output "There are no linked services in the ADF $DataFactoryName present in the resource group $ResourceGroupName ..."
}

#Integrationruntimes
Write-Output "Getting all Integration runtimes from ADF $DataFactoryName present in the resource group $ResourceGroupName ..."
Try {
    $integrationruntimesADF = Get-AzDataFactoryV2IntegrationRuntime -DataFactoryName $DataFactoryName -ResourceGroupName $ResourceGroupName -ErrorAction Stop
}
Catch {
    Write-Output "Failed to get the integration runtime list from ADF $DataFactoryName present in the resource group $ResourceGroupName . Exiting the script "
    Write-Output "Error Message :: $($_.Exception.Message)" 
    Write-Error "Error command :: $($_.InvocationInfo.PositionMessage)"    
    Break ;     
}
If ($integrationruntimesADF) {
    If ($IntegrationRuntimeNamesToExcludeFromDeletion) {
        $integrationruntimesADF = $integrationruntimesADF | Where-Object { $IntegrationRuntimeNamesToExcludeFromDeletion -notcontains $_ }
    }    
    $integrationruntimesTemplate = $TotalResources | Where-Object { $_.type -eq "Microsoft.DataFactory/factories/integrationruntimes" }
    $integrationruntimesNames = $integrationruntimesTemplate | ForEach-Object { $_.name.Substring(37, $_.name.Length - 40) }
    Write-Output "Listed below are the orphaned integration runtimes from ADF $DataFactoryName present in the resource group $ResourceGroupName ..."
    $Orphanedintegrationruntimes = $integrationruntimesADF | Where-Object { $integrationruntimesNames -notcontains $_.Name }
    $Orphanedintegrationruntimes
    If (!$Orphanedintegrationruntimes) {
        Write-Output "No orphaned integration runtimes found in ADF $DataFactoryName present in the resource group $ResourceGroupName ..."
    }
}
Else {
    Write-Output "There are no integration runtimes in the ADF $DataFactoryName present in the resource group $ResourceGroupName ..."
}
