[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [String]
    $DeployerID,

    [Parameter(Mandatory = $true)]
    [String]
    $DeployerPassword,

    [Parameter(Mandatory = $true)]
    [String]
    $Environment,

    [parameter(Mandatory = $false)] 
    [String] 
    $DataFactoryName,

    [parameter(Mandatory = $false)] 
    [String] 
    $ResourcegroupName,
    # Pass the trigger JSON file path from which the pipeline reference is removed. 
    # The path should not include the actual JSON file or the ending backslash
    # Example: "C:\Data\ChangeTheTriggerSchedule\JSONfiles"
    [Parameter(Mandatory = $false)]
    [String]
    $DeletionTaskTemplatePathWithOutBackSlashAndFilename,
    # Pass the trigger name from which the pipeline reference is removed
    # Example: "every 1 hour at 00 minutes"
    [Parameter(Mandatory = $false)]
    [String]
    $DeletionTaskTriggerName,
    # Pass the pipeline name which will be removed from trigger JSON file 
    # Example: "ADLSv2_MESAFABMX1_Master"
    [Parameter(Mandatory = $false)]
    [String]
    $DeletionTaskPipelineName,
    # JSON content which needs to be added to the trigger JSON file
    # You could use online-multiline-to-single-line-converter or AWK or JQ to convert the JSON to single line
    # Only single quotes needs to be used to wrap the JSON input
    # Example: ' { "pipelineReference": { "referenceName": "ADLSv2_MESAFABMX1_Master", "type": "PipelineReference" }, "parameters": { "ObjectList": "11016,11032,11039" } } '
    [Parameter(Mandatory = $false)]
    [String]
    $ResourceJson,
    # Pass the trigger JSON file path to which the pipeline reference is added. 
    # The path should not include the actual JSON file or the ending backslash
    # Example: "C:\Data\ChangeTheTriggerSchedule\JSONfiles"
    [Parameter(Mandatory = $false)]
    [String]
    $AdditionTaskTemplatePathWithOutBackSlashAndFilename,
    # Pass the trigger name to which the pipeline reference is added
    # Example: "every 1 hour at 00 minutes"
    [Parameter(Mandatory = $false)]
    [String]
    $AdditionTaskTriggerName
)
#Note: This is the trigger schedule change for the old method, when we used to have many pipelines associated with the same trigger
<#
# Reference:
$ResourceJson = @'
{
	"pipelineReference": {
		"referenceName": "ADLSv2_MESAFABMX1_Master",
		"type": "PipelineReference"
	},
	"parameters": {
		"ObjectList": "11016,11032,11039"
	}
}
'@
# use online-multiline-to-single-line-converter  or AWK or JQ to convert the JSON to single line
# Only single quotes needs to be used
# $ResourceJson = ' { "pipelineReference": { "referenceName": "ADLSv2_MESAFABMX1_Master", "type": "PipelineReference" }, "parameters": { "ObjectList": "11016,11032,11039" } } '
#>
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
    Write-Error "Failed to set the subscription context for the subscription [$SubscriptionName] with the below error. Skipping the execution..." 
    Write-Output "Error Message :: $($_.Exception.Message)" 
    Write-Output "Error command :: $($_.InvocationInfo.PositionMessage)"    
    Break ;                
}
<#
Example: Get-Content -path "C:\users\content.json" | ConvertFrom-Json | Format-Json
#>
Function Format-Json {
    param 
    (
        [Parameter(Mandatory, ValueFromPipeline)]
        [String] 
        $json 
    )
    $indent = 0;
    ($json -Split '\n' |
        ForEach-Object {
            if ($_ -match '[\}\]]') {
                # This line contains  ] or }, decrement the indentation level
                $indent--
            }
            $line = (' ' * $indent * 2) + $_.TrimStart().Replace(':  ', ': ')
            if ($_ -match '[\{\[]') {
                # This line contains [ or {, increment the indentation level
                $indent++
            }
            $line
        }) -Join "`n"
}

<#
Example: New-AzArmTemplatePSobject -Json ' { "pipelineReference": { "referenceName": "ADLSv2_MESAFABMX1_Master", "type": "PipelineReference" }, "parameters": { "ObjectList": "11016,11032,11039" } } ' 
#>
Function New-AzArmTemplatePSobject {
    [OutputType('pscustomobject')]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Json
    )

    $Json | Out-String | ConvertFrom-Json
}

<#
Example: Set-AzArmTemplateTriggerResource -TemplatePathWithOutBackSlashAndFilename "C:\testpath\linkedTemplates" -PipelineReference "$ResourceJson" -TriggerName "Trigger Name"
#>
Function Set-AzArmTemplateTriggerResource {
    [OutputType('void')]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$TemplatePathWithOutBackSlashAndFilename,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$TriggerName,

        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [pscustomobject]$PipelineReference
    )

    $FileName = $TriggerName + ".JSON"
    $TemplatePath = $($TemplatePathWithOutBackSlashAndFilename.TrimEnd("\")) + "\" + $FileName
    If (Test-Path $TemplatePath) {
        ## Read the template and convert to an object
        $armTemplate = Get-Content -Path $TemplatePath -Raw | ConvertFrom-Json    

        If ($armTemplate) {
            $CurrentActionPreference = $ErrorActionPreference
            $ErrorActionPreference = 'Stop'
            Try {
                ## Append the resource object to the end of the resource section
                $armTemplate.properties.pipelines += $PipelineReference
            }
            Catch {
                Write-Output "Failed to set the pipeline reference in the JSON file with the below error. Exiting the script..." 
                Write-Output "Error Message :: $($_.Exception.Message)" 
                Write-Output "Error command :: $($_.InvocationInfo.PositionMessage)"     
                Break ;
            }
            $ErrorActionPreference = $CurrentActionPreference
            ## Remove escaped unicode characters
            $template = $armTemplate | ConvertTo-Json -Depth 100 | ForEach-Object {
                [Regex]::Replace($_, 
                    "\\u(?<Value>[a-zA-Z0-9]{4})", {
                        param($m) ([char]([int]::Parse($m.Groups['Value'].Value,
                                    [System.Globalization.NumberStyles]::HexNumber))).ToString() } )
            } | Format-Json

            Try {
                ## Commit to disk
                $template | Set-Content -Path $TemplatePath
            }
            Catch {
                Write-Error "Failed to set the given pipeline reference on the trigger [ $TriggerName ] on the file [ $TemplatePath ]. Exiting the script ..."
                Write-Output "Error Message :: $($_.Exception.Message)" 
                Write-Output "Error command :: $($_.InvocationInfo.PositionMessage)"    
                Break ;         
            }
        }
    }
    Else {
        Write-Output "The path [$TemplatePath] for the trigger [$TriggerName] is not found. Please verify the trigger details. Skipping to set the trigger ..."
    }
}

<#
Example: Remove-AzArmTemplateTriggerResource -TemplatePathWithOutBackSlashAndFilename "C:\testpath\JSONfiles" -TriggerName "every 1 hour at 00 minutes2" -PipelineNameToRemove "ADLSv2_MESAFABMX1_Master"
#>
function Remove-AzArmTemplateTriggerResource {
    [OutputType('void')]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$TemplatePathWithOutBackSlashAndFilename,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$TriggerName,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$PipelineNameToRemove
    )

    $FileName = $TriggerName + ".JSON"
    $TemplatePath = $($TemplatePathWithOutBackSlashAndFilename.TrimEnd("\")) + "\" + $FileName
    If (Test-Path $TemplatePath) {
        ## Read the template and convert to an object
        $ConvertedFileContent = Get-Content -Path $TemplatePath -Raw | ConvertFrom-Json    

        If ($ConvertedFileContent) {
            $CurrentActionPreference = $ErrorActionPreference
            $ErrorActionPreference = 'Stop'
            Try {
                ## Append the resource object to the end of the resource section
                $ConvertedFileContent.properties.pipelines = $ConvertedFileContent.properties.pipelines | Where-Object { $_.pipelineReference.referenceName -ne $PipelineNameToRemove }
            }
            Catch {
                Write-Output "Failed to remove the pipeline reference in the JSON file with the below error. Exiting the script..."
                Write-Output "Error Message :: $($_.Exception.Message)" 
                Write-Output "Error command :: $($_.InvocationInfo.PositionMessage)"      
                Break ;
            }
            $ErrorActionPreference = $CurrentActionPreference
            ## Remove escaped unicode characters
            $TemplateR = $ConvertedFileContent | ConvertTo-Json -Depth 100 | ForEach-Object {
                [Regex]::Replace($_, 
                    "\\u(?<Value>[a-zA-Z0-9]{4})", {
                        param($m) ([char]([int]::Parse($m.Groups['Value'].Value,
                                    [System.Globalization.NumberStyles]::HexNumber))).ToString() } )
            } | Format-Json

            Try {
                ## Commit to disk
                $TemplateR | Set-Content -Path $TemplatePath
            }
            Catch {
                Write-Error "Failed to Remove the pipeine [ $PipelineNameToRemove ] on the trigger [ $TriggerName ] from the file [ $TemplatePath ]. Exiting the script ..."
                Write-Output "Error Message :: $($_.Exception.Message)" 
                Write-Output "Error command :: $($_.InvocationInfo.PositionMessage)"    
                Break ;
            }            

        }
    }
    Else {
        Write-Output "The path [$TemplatePath] for the trigger [$TriggerName] is not found. Please verify the trigger details. Skipping to remove the trigger reference ..."
    }
}
<#
Example: Set-TheTriggerUsingTheDefinitionFile -AdfTemplatePathWithOutBackSlashAndFilename "I:\testpath\JSONfiles" -AdfTriggerName "every 1 hour at 00 minutes2" -AdfResourceGroupName "testrg" -AdfDatafactoryName "testadf"
#>
Function Set-TheTriggerUsingTheDefinitionFile {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$AdfTemplatePathWithOutBackSlashAndFilename,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$AdfTriggerName,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$AdfResourceGroupName,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$AdfDatafactoryName
    )

    Try {
        $GetTheTrigger = Get-AzDataFactoryV2Trigger -Name $AdfTriggerName -ResourceGroupName $AdfResourceGroupName -DataFactoryName $AdfDatafactoryName -ErrorAction Stop
    }
    Catch {
        Write-Error "Failed to get the trigger [$AdfTriggerName] from the datafactory [$AdfDatafactoryName] located in the resource group [$AdfResourceGroupName] with the below error. Skipping the execution..."
        Write-Output "Error Message :: $($_.Exception.Message)" 
        Write-Output "Error command :: $($_.InvocationInfo.PositionMessage)"     
        Break ; 
    }
    If ($GetTheTrigger) {        
        $DefinitionFilePath = $($AdfTemplatePathWithOutBackSlashAndFilename.TrimEnd("\")) + "\" + "$AdfTriggerName" + ".JSON"
        If (Test-Path $DefinitionFilePath) {
            Try {
                Set-AzDataFactoryV2Trigger -ResourceGroupName $AdfResourceGroupName -DataFactoryName $AdfDatafactoryName -Name $AdfTriggerName -DefinitionFile $DefinitionFilePath -Force -ErrorAction Stop
            }
            Catch {
                Write-Error "Failed to set the trigger [$AdfTriggerName] using the definition file [$DefinitionFilePath] in the datafactory [$AdfDatafactoryName] located in the resource group [$AdfResourceGroupName] with the below error. Skipping the execution..."
                Write-Output "Error Message :: $($_.Exception.Message)" 
                Write-Output "Error command :: $($_.InvocationInfo.PositionMessage)"    
                Break ;
            }
        }
        Else {
            Write-Output "Trigger definition file can't be found in the specified path [$DefinitionFilePath]. Skipping to set the trigger using definition file ..."
            Write-Output "Error Message :: $($_.Exception.Message)" 
            Write-Output "Error command :: $($_.InvocationInfo.PositionMessage)" 
        }

    }
}

If ($DeletionTaskTemplatePathWithOutBackSlashAndFilename -and $DeletionTaskTriggerName -and $DeletionTaskPipelineName -and $ResourceJson -and $AdditionTaskTemplatePathWithOutBackSlashAndFilename -and $AdditionTaskTriggerName) {
    Write-Output "Starting to remove the pipeline reference for the pipeline [$DeletionTaskPipelineName] from the trigger [$DeletionTaskTriggerName]"
    Remove-AzArmTemplateTriggerResource -TemplatePathWithOutBackSlashAndFilename $DeletionTaskTemplatePathWithOutBackSlashAndFilename -TriggerName $DeletionTaskTriggerName -PipelineNameToRemove $DeletionTaskPipelineName
    start-sleep 2
    Write-Output "Starting to set the trigger [$DeletionTaskTriggerName] in the ADF [$DataFactoryName] located in the resource group [$ResourceGroupName]"
    Set-TheTriggerUsingTheDefinitionFile -AdfTemplatePathWithOutBackSlashAndFilename $DeletionTaskTemplatePathWithOutBackSlashAndFilename -AdfTriggerName $DeletionTaskTriggerName -AdfResourceGroupName $ResourceGroupName -AdfDatafactoryName $DataFactoryName
    Write-Output "Sleeping for 5 seconds"
    Start-Sleep 5
    Write-Output "Starting to add the specified pipeline reference on the trigger [$AdditionTaskTriggerName]"
    New-AzArmTemplatePSobject -Json $ResourceJson | Set-AzArmTemplateTriggerResource -TemplatePathWithOutBackSlashAndFilename $AdditionTaskTemplatePathWithOutBackSlashAndFilename -TriggerName $AdditionTaskTriggerName
    start-sleep 2
    Write-Output "Starting to set the trigger [$AdditionTaskTriggerName] in the ADF [$DataFactoryName] located in the resource group [$ResourceGroupName]"
    Set-TheTriggerUsingTheDefinitionFile -AdfTemplatePathWithOutBackSlashAndFilename $AdditionTaskTemplatePathWithOutBackSlashAndFilename -AdfTriggerName $AdditionTaskTriggerName -AdfResourceGroupName $ResourceGroupName -AdfDatafactoryName $DataFactoryName

}
Elseif ($DeletionTaskTemplatePathWithOutBackSlashAndFilename -and $DeletionTaskTriggerName -and $DeletionTaskPipelineName ) {
    Write-Output "Starting to remove the pipeline reference for the pipeline [$DeletionTaskPipelineName] from the trigger [$DeletionTaskTriggerName]"
    Remove-AzArmTemplateTriggerResource -TemplatePathWithOutBackSlashAndFilename $DeletionTaskTemplatePathWithOutBackSlashAndFilename -TriggerName $DeletionTaskTriggerName -PipelineNameToRemove $DeletionTaskPipelineName
    start-sleep 2
    Write-Output "Starting to set the trigger [$DeletionTaskTriggerName] in the ADF [$DataFactoryName] located in the resource group [$ResourceGroupName]"
    Set-TheTriggerUsingTheDefinitionFile -AdfTemplatePathWithOutBackSlashAndFilename $DeletionTaskTemplatePathWithOutBackSlashAndFilename -AdfTriggerName $DeletionTaskTriggerName -AdfResourceGroupName $ResourceGroupName -AdfDatafactoryName $DataFactoryName

}
Elseif ($ResourceJson -and $AdditionTaskTemplatePathWithOutBackSlashAndFilename -and $AdditionTaskTriggerName) {
    Write-Output "Starting to add the specified pipeline reference on the trigger [$AdditionTaskTriggerName]"    
    New-AzArmTemplatePSobject -Json $ResourceJson | Set-AzArmTemplateTriggerResource -TemplatePathWithOutBackSlashAndFilename $AdditionTaskTemplatePathWithOutBackSlashAndFilename -TriggerName $AdditionTaskTriggerName
    start-sleep 2
    Write-Output "Starting to set the trigger [$AdditionTaskTriggerName] in the ADF [$DataFactoryName] located in the resource group [$ResourceGroupName]"
    Set-TheTriggerUsingTheDefinitionFile -AdfTemplatePathWithOutBackSlashAndFilename $AdditionTaskTemplatePathWithOutBackSlashAndFilename -AdfTriggerName $AdditionTaskTriggerName -AdfResourceGroupName $ResourceGroupName -AdfDatafactoryName $DataFactoryName
}
Remove-Variable DeletionTaskTemplatePathWithOutBackSlashAndFilename, DeletionTaskTriggerName, DeletionTaskPipelineName, ResourceJson, AdditionTaskTemplatePathWithOutBackSlashAndFilename, AdditionTaskTriggerName, GetTheTrigger -ErrorAction SilentlyContinue