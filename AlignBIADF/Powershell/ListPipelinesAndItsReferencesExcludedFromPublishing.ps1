[CmdletBinding()]
Param
(
    # Folder name where the published ARM templates are present
    [parameter(Mandatory = $true)] 
    [String] 
    $rootFolder ,

    [parameter(Mandatory = $false)] 
    [String[]] 
    $PipelineNames = @()    
)

<#
Example: $JsonFile = Get-Content -path "C:\users\content.json" -Encoding UTF8 | ConvertFrom-Json 
         $JsonFile | ConvertTo-Json -Depth 100 | Format-Json 
#>
Function Format-Json {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$Json,

        [Parameter(Mandatory = $false)]
        [ValidateRange(1, 1024)]
        [int]$Indentation = 4,

        [Parameter(Mandatory = $false)]
        [switch]$AsArray
    )

    # If the input JSON text has been created with ConvertTo-Json -Compress
    # then we first need to reconvert it without compression
    If ($Json -notmatch '\r?\n') {
        $Json = ($Json | ConvertFrom-Json) | ConvertTo-Json -Depth 100
    }

    $indent = 0
    $regexUnlessQuoted = '(?=([^"]*"[^"]*")*[^"]*$)'

    $result = $Json -split '\r?\n' |
    ForEach-Object {
        # If the line contains a ] or } character, 
        # we need to decrement the indentation level unless it is inside quotes.
        If ($_ -match "[}\]]$regexUnlessQuoted") {
            $indent = [Math]::Max($indent - $Indentation, 0)
        }

        # Replace all colon-space combinations by ": " unless it is inside quotes.
        $line = (' ' * $indent) + ($_.TrimStart() -replace ":\s+$regexUnlessQuoted", ': ')

        # If the line contains a [ or { character, 
        # we need to increment the indentation level unless it is inside quotes.
        If ($_ -match "[\{\[]$regexUnlessQuoted") {
            $indent += $Indentation
        }
        $line
    }

    If ($AsArray) { return $result }
    return $result -Join [Environment]::NewLine
}

If ($PipelineNames.Count -gt 0) {
    $SourceAndDependentResourcesList = @()
    $TriggerAndPipelineResourcesList = @()
    $TriggerAndPipelineDependenciesList = @()
    If (Test-Path $RootFolder) {
        $RootFolder = $RootFolder.TrimEnd("\")
        Try {            
            $TotalFileNames = Get-ChildItem -Path $RootFolder | Select-Object name
        }
        Catch {
            Write-Error "Failed to get the files from the path [$RootFolder]. Exiting the script "
            Write-Output "Error Message :: $($_.Exception.Message)" 
            Write-Output "Error command :: $($_.InvocationInfo.PositionMessage)"    
            Break ;            
        }
        If ($TotalFileNames.count -gt 0) {        
            Foreach ($FileName in $TotalFileNames) {
                $Armtemplate = $RootFolder + "\" + $($FileName.Name)
                If ($Armtemplate -match 'json') {
                    Try {
                        $templateJson = Get-Content -path $armTemplate -Raw | ConvertFrom-Json                
                    }
                    Catch {
                        Write-Error "Failed to get the file contents from the file [$armTemplate]. Exiting the script "
                        Write-Output "Error Message :: $($_.Exception.Message)" 
                        Write-Output "Error command :: $($_.InvocationInfo.PositionMessage)"    
                        Break ;  
                    }

                    If ($templateJson.resources.Count -gt 0) {                
                        $AdfResources = $($templateJson.resources)

                        $RequiredPipelines = @()
                        $TriggerResourcesUpdated = @()
                        $TriggerResourcesWithPipelineDependenciesUpdated = @()

                        Foreach ($Pipe in $PipelineNames) {
                            #Matching pipeline resource are added to the deletion list
                            $RequiredPipeline = $AdfResources | Where-Object { ($_.type -eq "Microsoft.DataFactory/factories/pipelines") -and ( ($_.name.Substring(37, $_.name.Length - 40) ) -eq $Pipe) }
                            If ($RequiredPipeline) {
                                Write-Output "Pipeline resource [ $($RequiredPipeline.name.Substring(37, $RequiredPipeline.name.Length - 40)) ] is present the in the file [ $Armtemplate ] . Adding to the deletion list..."
                                $RequiredPipelines += $RequiredPipeline                           
                                Write-Output ""
                            }
                            Remove-variable RequiredPipeline -ErrorAction SilentlyContinue                
                            
                            #Matching pipelines that have a dependency on the pipeline we are deleting, are added to the deletion list
                            #Make sure this pipeline also is included in the deletion list. If  not the ARM template deployment fails as we have deleted the parent pipeline
                            $PipelineResourcesWithDependencies = $AdfResources | Where-Object { ($_.type -eq "Microsoft.DataFactory/factories/pipelines") -and ($_.dependson.count -gt 0 ) }                
                            Foreach ($PipelineResourceWithDependency in $PipelineResourcesWithDependencies) {                                
                                $DependentResourceChildResources = $PipelineResourceWithDependency.dependson
                                If ($DependentResourceChildResources.count -gt 0) {
                                    Foreach ($DependentResourceChildResource in $DependentResourceChildResources) {
                                        If ( ( ($DependentResourceChildResource.Substring(44, $DependentResourceChildResource.Length - 47) ) -eq $Pipe ) -or ( ($DependentResourceChildResource.Substring(37, $DependentResourceChildResource.Length - 40) ) -eq $Pipe ) ) {
                                            $DependentResourceName = $PipelineResourceWithDependency.name.Substring(37, $PipelineResourceWithDependency.name.Length - 40)
                                            Write-Output "Pipeline [$DependentResourceName] present in file [$Armtemplate] is dependent on the pipeline [$pipe].`nThis pipeline also should be included in the deletion list. If not remove both pipelines from the deletion list ..."
                                            Write-Output ""
                                            $TwoResources = @{"SourcePipeline" = $pipe; "DependentPipeline" = $DependentResourceName ; "FileName" = $Armtemplate }
                                            $SourceAndDependentResourcesList += $TwoResources
                                        }
                                        Remove-variable TwoResources -ErrorAction SilentlyContinue 
                                    }
                                }
                            }

                            #List the triggers where the pipeline that is being deleted, is referenced in the triggers
                            $TriggerResources = $AdfResources | Where-Object { ($_.type -eq "Microsoft.DataFactory/factories/triggers") -and ($_.properties.pipelines.count -gt 0 ) } 
                            $TriggerResourcesWithoutPipeleneReferences = $AdfResources | Where-Object { ($_.type -eq "Microsoft.DataFactory/factories/triggers") -and ($_.properties.pipelines.count -le 0 ) } 
                            If ($TriggerResourcesWithoutPipeleneReferences.count -gt 0) {
                                $TriggerResourcesUpdated += $TriggerResourcesWithoutPipeleneReferences
                            }
                            Foreach ($TriggerResource in $TriggerResources) {
                                $TriggerResourceChildResources = $TriggerResource.properties.pipelines
                                If ($TriggerResourceChildResources.count -gt 0) {
                                    $PipelineReferenceMatchedInTrigger = $false
                                    Foreach ($TriggerResourceChildResource in $TriggerResourceChildResources) {
                                        If ( ( ($TriggerResourceChildResource.pipelineReference.referenceName ) -eq $Pipe )  ) {                           
                                            $PipelineReferenceMatchedInTrigger = $true
                                        }
                                        Else {
                                            $PipelineReferenceMatchedInTrigger = $false
                                        }
                                    }
                                }
                                If ($PipelineReferenceMatchedInTrigger) {
                                    Write-Output "Pipeline reference [ $Pipe ] identified on the trigger [ $($TriggerResource.name.Substring(37, $TriggerResource.name.Length - 40)) ] present in the file [ $Armtemplate ] . Adding to the deletion list ..."
                                    Write-Output ""
                                    $TriggerAndPipelineReference = @{"SourcePipeline" = $pipe; "FileName" = $Armtemplate ; "TriggerName" = $($TriggerResource.name.Substring(37, $TriggerResource.name.Length - 40)) }
                                    $TriggerAndPipelineResourcesList += $TriggerAndPipelineReference
                                    $TriggerResource.properties.pipelines = $TriggerResource.properties.pipelines | Where-Object { $_.pipelineReference.referenceName -ne $Pipe }
                                    $TriggerResourcesUpdated += $TriggerResource
                                }
                                Else {
                                    $TriggerResourcesUpdated += $TriggerResource
                                }
                                Remove-variable TriggerResource -ErrorAction SilentlyContinue 
                            }

                            #List the triggers that have a dependency on the pipeline which is getting deleted
                            $TriggerResourcesWithPipelineDependencies = $AdfResources | Where-Object { ($_.type -eq "Microsoft.DataFactory/factories/triggers") -and ($_.dependsOn.count -gt 0 ) } 
                            $TriggerResourcesWithoutPipeleneDependencies = $AdfResources | Where-Object { ($_.type -eq "Microsoft.DataFactory/factories/triggers") -and ($_.dependsOn.count -le 0 ) } 
                            If ($TriggerResourcesWithoutPipeleneDependencies.count -gt 0) {
                                $TriggerResourcesWithPipelineDependenciesUpdated += $TriggerResourcesWithoutPipeleneDependencies
                            }
                            Foreach ($TriggerResourceWithPipelineDependencies in $TriggerResourcesWithPipelineDependencies) {
                                $TriggerResourceWithPipelineDependenciesChildResources = $TriggerResourceWithPipelineDependencies.dependsOn
                                If ($TriggerResourceWithPipelineDependenciesChildResources.count -gt 0) {
                                    $PipelineDependencyMatchedInTrigger = $false
                                    Foreach ($TriggerResourceWithPipelineDependenciesChildResource in $TriggerResourceWithPipelineDependenciesChildResources) {
                                        If ( ( ($TriggerResourceWithPipelineDependenciesChildResource.Substring(37, $TriggerResourceWithPipelineDependenciesChildResource.Length - 40) ) -eq $Pipe ) -or ( ($TriggerResourceWithPipelineDependenciesChildResource.Substring(44, $TriggerResourceWithPipelineDependenciesChildResource.Length - 47) ) -eq $Pipe )  ) {                           
                                            $PipelineDependencyMatchedInTrigger = $true
                                        }
                                        Else {
                                            $PipelineDependencyMatchedInTrigger = $false
                                        }
                                    }
                                }
                                If ($PipelineDependencyMatchedInTrigger) {
                                    Write-Output "Trigger [ $($TriggerResourceWithPipelineDependencies.name.Substring(37, $TriggerResourceWithPipelineDependencies.name.Length - 40)) ] present in file [$Armtemplate] is dependent on the pipeline [$pipe]. Adding this trigger to the deletion list ..."
                                    $TriggerAndPipelineDependency = @{"SourcePipeline" = $pipe; "FileName" = $Armtemplate ; "TriggerName" = $($TriggerResourceWithPipelineDependencies.name.Substring(37, $TriggerResourceWithPipelineDependencies.name.Length - 40)) }
                                    $TriggerAndPipelineDependenciesList += $TriggerAndPipelineDependency
                                    $TriggerResourceWithPipelineDependencies.dependsOn = $TriggerResourceWithPipelineDependencies.dependsOn | Where-Object { ($_.Substring(44, $_.Length - 47) -ne $Pipe) -and ($_.Substring(37, $_.Length - 40) -ne $Pipe) }
                                    $TriggerResourcesWithPipelineDependenciesUpdated += $TriggerResourceWithPipelineDependencies
                                }
                                Else {
                                    $TriggerResourcesWithPipelineDependenciesUpdated += $TriggerResourceWithPipelineDependencies
                                }
                                Remove-variable TriggerResourceWithPipelineDependencies -ErrorAction SilentlyContinue 
                            }                           
                        }                     
                    }
                    Else {
                        Write-Output "There are no resources found in the file [ $armTemplate ]. Skipping ..."
                    }                
 
                }
            }
            #List the overall output
            Write-Output ""
            Write-Output ""
            Write-Output "Make sure the below listed Source and dependent pipelines are included in the deletion list. If not the ARM template deployment fails ..."
            Write-Output ""
            If ($SourceAndDependentResourcesList.Count -gt 0) {
                Foreach ($item in $SourceAndDependentResourcesList) {
                    Write-Output "    Source Pipeline :: [ $($item.SourcePipeline) ]"
                    Write-Output "    Dependent Pipeline :: [ $($item.DependentPipeline) ]"
                    Write-Output "    Dependent Pipeline File Path :: [ $($item.FileName) ]"
                    Write-Output ""
                }
            }
            Else {
                Write-Output "    No need to take any action. No dependent pipelines are there for the listed source pipelines ..."
            }
            Write-Output ""
            Write-Output "The list of Triggers which has references of the pipeline ..."
            Write-Output ""
            If ($TriggerAndPipelineResourcesList.Count -gt 0 ) {
                Foreach ($TrItem in $TriggerAndPipelineResourcesList) {
                    Write-Output "    Source Pipeline :: [ $($TrItem.SourcePipeline) ]" 
                    Write-Output "    FileName :: [ $($TrItem.FileName) ]"
                    Write-Output "    TriggerName :: [ $($TrItem.TriggerName) ]"
                    Write-Output ""
                }
            }
            Else {
                Write-Output "No trigger references are there for the listed pipelines ..."
            }
            Write-Output ""
            Write-Output "The list of Triggers which has dependency on the pipeline ..."
            Write-Output ""
            If ($TriggerAndPipelineDependenciesList.Count -gt 0 ) {
                Foreach ($TrItem in $TriggerAndPipelineDependenciesList) {
                    Write-Output "    Source Pipeline :: [ $($TrItem.SourcePipeline) ]" 
                    Write-Output "    FileName :: [ $($TrItem.FileName) ]"
                    Write-Output "    TriggerName :: [ $($TrItem.TriggerName) ]"
                    Write-Output ""
                }
            }
            Else {
                Write-Output "No trigger dependencies are there for the listed pipelines ..."
            }
        }
        Else {
            Write-Error "There are no files present in the path [$RootFolder].`nPlease make sure path to the templates is correct. Exiting the script ..."
            Break ;
        }

    }
    Else {
        Write-Error "Unable to find the path [$RootFolder] for the JSON templates.`nPlease make sure the path to the templates is correct. Exiting the script ..."
        Break ;
    }

}
Else {
    Write-Output "There are no pipeline names passed for the parameter `$pipelinenames . Skipping to remove resources from the template ..."
}

