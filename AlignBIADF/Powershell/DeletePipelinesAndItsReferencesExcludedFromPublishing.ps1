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
    $AllRequiredPipelines = @()
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
                    $RequiredPipelines = @()                       
                    Foreach ($Pipe in $PipelineNames) {
                        $TriggerResourcesWithDependenciesAndWithPipelineReferencesUpdated = @()
                        $TriggerResourcesWithDependenciesAndWithOutPipelineReferencesUpdated = @()
                        $TriggerResourcesWithOutDependenciesAndWithPipelineReferencesUpdated = @()                      
                        Try {
                            $templateJson = Get-Content -path $armTemplate -Raw | ConvertFrom-Json
                            $templateJsonPrimary = Get-Content -path $armTemplate -Raw | ConvertFrom-Json                 
                        }
                        Catch {
                            Write-Error "Failed to get the file contents from the file [$armTemplate]. Exiting the script "
                            Write-Output "Error Message :: $($_.Exception.Message)" 
                            Write-Output "Error command :: $($_.InvocationInfo.PositionMessage)"    
                            Break ;  
                        }
                        If ($templateJson.resources.Count -gt 0) {
                            $AdfResources = $($templateJson.resources)
                            $AllAdfResources = $($templateJsonPrimary.resources)
                            #Matching pipeline resource are added to the deletion list
                            $RequiredPipeline = $AdfResources | Where-Object { ($_.type -eq "Microsoft.DataFactory/factories/pipelines") -and ( ($_.name.Substring(37, $_.name.Length - 40) ) -eq $Pipe) }
                            If ($RequiredPipeline) {
                                Write-Output "Pipeline resource [ $($RequiredPipeline.name.Substring(37, $RequiredPipeline.name.Length - 40)) ] is present the in the file [ $Armtemplate ] . Adding to the deletion list..."
                                $RequiredPipelines += $RequiredPipeline 
                                $RequiredPipelineAndFile = @{"SourcePipeline" = $($RequiredPipeline.name.Substring(37, $RequiredPipeline.name.Length - 40)) ; "FileName" = $Armtemplate }
                                $AllRequiredPipelines += $RequiredPipelineAndFile                         
                                Write-Output ""
                            }
                            Remove-variable RequiredPipeline -ErrorAction SilentlyContinue                
                            
                            #Matching pipelines that have a dependency on the pipeline we are deleting, are added to the dependencies list. But we are not deleting them unless included explicitly
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
                            $TriggerResourcesWithDependenciesAndWithPipelineReferences = $AdfResources | Where-Object { ($_.type -eq "Microsoft.DataFactory/factories/triggers") -and ($_.properties.pipelines.count -gt 0 ) -and ($_.dependsOn.count -gt 0 ) } 
                            $TriggerResourcesWithDependenciesAndWithOutPipelineReferences = $AdfResources | Where-Object { ($_.type -eq "Microsoft.DataFactory/factories/triggers") -and ($_.properties.pipelines.count -le 0 ) -and ($_.dependsOn.count -gt 0 ) } 
                            $TriggerResourcesWithOutDependenciesAndWithPipelineReferences = $AdfResources | Where-Object { ($_.type -eq "Microsoft.DataFactory/factories/triggers") -and ($_.properties.pipelines.count -gt 0 ) -and ($_.dependsOn.count -le 0 ) } 
                            
                            Foreach ($TriggerResourceWithDependenciesAndWithPipelineReferences in $TriggerResourcesWithDependenciesAndWithPipelineReferences) {
                                $TriggerResourceWithDependenciesAndWithPipelineReferences_ReferenceChildResources = $TriggerResourceWithDependenciesAndWithPipelineReferences.properties.pipelines
                                $TriggerResourceWithDependenciesAndWithPipelineReferences_DependentChildResources = $TriggerResourceWithDependenciesAndWithPipelineReferences.dependsOn
                                If ( ($TriggerResourceWithDependenciesAndWithPipelineReferences_ReferenceChildResources.count -gt 0 ) -and ($TriggerResourceWithDependenciesAndWithPipelineReferences_DependentChildResources.count -gt 0 ) ) {
                                    $PipelineReferenceMatchedInTrigger = "false"
                                    $PipelineDependencyMatchedInTrigger = "false"
                                    Foreach ($TriggerResourceWithDependenciesAndWithPipelineReferences_ReferenceChildResource in $TriggerResourceWithDependenciesAndWithPipelineReferences_ReferenceChildResources) {
                                        If ( ( ($TriggerResourceWithDependenciesAndWithPipelineReferences_ReferenceChildResource.pipelineReference.referenceName ) -eq $Pipe )  ) {                           
                                            $PipelineReferenceMatchedInTrigger = "true"
                                        }
                                        Else {
                                            $PipelineReferenceMatchedInTrigger = "false"
                                        }
                                    }
                                    Foreach ($TriggerResourceWithDependenciesAndWithPipelineReferences_DependentChildResource in $TriggerResourceWithDependenciesAndWithPipelineReferences_DependentChildResources) {
                                        If ( ( ($TriggerResourceWithDependenciesAndWithPipelineReferences_DependentChildResource.Substring(37, $TriggerResourceWithDependenciesAndWithPipelineReferences_DependentChildResource.Length - 40) ) -eq $Pipe ) -or ( ($TriggerResourceWithDependenciesAndWithPipelineReferences_DependentChildResource.Substring(44, $TriggerResourceWithDependenciesAndWithPipelineReferences_DependentChildResource.Length - 47) ) -eq $Pipe ) ) {                           
                                            $PipelineDependencyMatchedInTrigger = "true"
                                        }
                                        Else {
                                            $PipelineDependencyMatchedInTrigger = "false"
                                        }
                                    }

                                    If ( ($PipelineReferenceMatchedInTrigger -eq "true") -and ($PipelineDependencyMatchedInTrigger -eq "true") ) {
                                        Write-Output "Pipeline dependency and reference [ $Pipe ] identified on the trigger [ $($TriggerResourceWithDependenciesAndWithPipelineReferences.name.Substring(37, $TriggerResourceWithDependenciesAndWithPipelineReferences.name.Length - 40)) ] present in the file [ $Armtemplate ] . Adding to the deletion list ..."
                                        Write-Output ""
                                        $TriggerAndPipelineReference = @{"SourcePipeline" = $pipe; "FileName" = $Armtemplate ; "TriggerName" = $($TriggerResourceWithDependenciesAndWithPipelineReferences.name.Substring(37, $TriggerResourceWithDependenciesAndWithPipelineReferences.name.Length - 40)) }
                                        $TriggerAndPipelineResourcesList += $TriggerAndPipelineReference
                                        $TriggerResourceWithDependenciesAndWithPipelineReferences.properties.pipelines = $TriggerResourceWithDependenciesAndWithPipelineReferences.properties.pipelines | Where-Object { $_.pipelineReference.referenceName -ne $Pipe }
                                        $TriggerResourceWithDependenciesAndWithPipelineReferences.dependsOn = $TriggerResourceWithDependenciesAndWithPipelineReferences.dependsOn | Where-Object { ($_.Substring(44, $_.Length - 47) -ne $Pipe) -and ($_.Substring(37, $_.Length - 40) -ne $Pipe) }
                                        $TriggerResourcesWithDependenciesAndWithPipelineReferencesUpdated += $TriggerResourceWithDependenciesAndWithPipelineReferences
                                    }
                                    ElseIf ( ($PipelineReferenceMatchedInTrigger -eq "true") -and ($PipelineDependencyMatchedInTrigger -eq "false") ) {
                                        Write-Output "Pipeline reference [ $Pipe ] identified on the trigger [ $($TriggerResourceWithDependenciesAndWithPipelineReferences.name.Substring(37, $TriggerResourceWithDependenciesAndWithPipelineReferences.name.Length - 40)) ] present in the file [ $Armtemplate ] . Adding to the deletion list ..."
                                        Write-Output ""
                                        $TriggerAndPipelineReference = @{"SourcePipeline" = $pipe; "FileName" = $Armtemplate ; "TriggerName" = $($TriggerResourceWithDependenciesAndWithPipelineReferences.name.Substring(37, $TriggerResourceWithDependenciesAndWithPipelineReferences.name.Length - 40)) }
                                        $TriggerAndPipelineResourcesList += $TriggerAndPipelineReference
                                        $TriggerResourceWithDependenciesAndWithPipelineReferences.properties.pipelines = $TriggerResourceWithDependenciesAndWithPipelineReferences.properties.pipelines | Where-Object { $_.pipelineReference.referenceName -ne $Pipe }
                                        $TriggerResourcesWithDependenciesAndWithPipelineReferencesUpdated += $TriggerResourceWithDependenciesAndWithPipelineReferences
                                    }
                                    ElseIf ( ($PipelineReferenceMatchedInTrigger -eq "false") -and ($PipelineDependencyMatchedInTrigger -eq "true") ) {
                                        Write-Output "Pipeline dependency [ $Pipe ] identified on the trigger [ $($TriggerResourceWithDependenciesAndWithPipelineReferences.name.Substring(37, $TriggerResourceWithDependenciesAndWithPipelineReferences.name.Length - 40)) ] present in the file [ $Armtemplate ] . Adding to the deletion list ..."
                                        Write-Output ""
                                        $TriggerAndPipelineReference = @{"SourcePipeline" = $pipe; "FileName" = $Armtemplate ; "TriggerName" = $($TriggerResourceWithDependenciesAndWithPipelineReferences.name.Substring(37, $TriggerResourceWithDependenciesAndWithPipelineReferences.name.Length - 40)) }
                                        $TriggerAndPipelineResourcesList += $TriggerAndPipelineReference
                                        $TriggerResourceWithDependenciesAndWithPipelineReferences.dependsOn = $TriggerResourceWithDependenciesAndWithPipelineReferences.dependsOn | Where-Object { ($_.Substring(44, $_.Length - 47) -ne $Pipe) -and ($_.Substring(37, $_.Length - 40) -ne $Pipe) }
                                        $TriggerResourcesWithDependenciesAndWithPipelineReferencesUpdated += $TriggerResourceWithDependenciesAndWithPipelineReferences
                                    }
                                    Else {
                                        $TriggerResourcesWithDependenciesAndWithPipelineReferencesUpdated += $TriggerResourceWithDependenciesAndWithPipelineReferences
                                    }
                                    Remove-variable TriggerResourceWithDependenciesAndWithPipelineReferences -ErrorAction SilentlyContinue 
                                }
                            }

                            Foreach ($TriggerResourceWithDependenciesAndWithOutPipelineReferences in $TriggerResourcesWithDependenciesAndWithOutPipelineReferences) {
                                $TriggerResourceWithDependenciesAndWithOutPipelineReferences_DependentChildResources = $TriggerResourceWithDependenciesAndWithOutPipelineReferences.dependsOn
                                If ( ($TriggerResourceWithDependenciesAndWithOutPipelineReferences_DependentChildResources.count -gt 0 ) ) {
                                    $2PipelineDependencyMatchedInTrigger = $false
                                    Foreach ($TriggerResourceWithDependenciesAndWithOutPipelineReferences_DependentChildResource in $TriggerResourceWithDependenciesAndWithOutPipelineReferences_DependentChildResources) {
                                        If ( ( ($TriggerResourceWithDependenciesAndWithOutPipelineReferences_DependentChildResource.Substring(37, $TriggerResourceWithDependenciesAndWithOutPipelineReferences_DependentChildResource.Length - 40) ) -eq $Pipe ) -or ( ($TriggerResourceWithDependenciesAndWithOutPipelineReferences_DependentChildResource.Substring(44, $TriggerResourceWithDependenciesAndWithOutPipelineReferences_DependentChildResource.Length - 47) ) -eq $Pipe ) ) {                           
                                            $2PipelineDependencyMatchedInTrigger = $true
                                        }
                                        Else {
                                            $2PipelineDependencyMatchedInTrigger = $false
                                        }
                                    }
                                    If ($2PipelineDependencyMatchedInTrigger) {
                                        Write-Output "Pipeline dependency [ $Pipe ] identified on the trigger [ $($TriggerResourceWithDependenciesAndWithOutPipelineReferences.name.Substring(37, $TriggerResourceWithDependenciesAndWithOutPipelineReferences.name.Length - 40)) ] present in the file [ $Armtemplate ] . Adding to the deletion list ..."
                                        Write-Output ""
                                        $TriggerAndPipelineReference = @{"SourcePipeline" = $pipe; "FileName" = $Armtemplate ; "TriggerName" = $($TriggerResourceWithDependenciesAndWithOutPipelineReferences.name.Substring(37, $TriggerResourceWithDependenciesAndWithOutPipelineReferences.name.Length - 40)) }
                                        $TriggerAndPipelineResourcesList += $TriggerAndPipelineReference
                                        $TriggerResourceWithDependenciesAndWithOutPipelineReferences.dependsOn = $TriggerResourceWithDependenciesAndWithOutPipelineReferences.dependsOn | Where-Object { ($_.Substring(44, $_.Length - 47) -ne $Pipe) -and ($_.Substring(37, $_.Length - 40) -ne $Pipe) }
                                        $TriggerResourcesWithDependenciesAndWithOutPipelineReferencesUpdated += $TriggerResourceWithDependenciesAndWithOutPipelineReferences
                                    }
                                    Else {
                                        $TriggerResourcesWithDependenciesAndWithOutPipelineReferencesUpdated += $TriggerResourceWithDependenciesAndWithOutPipelineReferences
                                    }
                                    Remove-variable TriggerResourceWithDependenciesAndWithOutPipelineReferences -ErrorAction SilentlyContinue
                                }
                            }

                            Foreach ($TriggerResourceWithOutDependenciesAndWithPipelineReferences in $TriggerResourcesWithOutDependenciesAndWithPipelineReferences) {
                                $TriggerResourceWithOutDependenciesAndWithPipelineReferences_ReferenceChildResources = $TriggerResourceWithOutDependenciesAndWithPipelineReferences.properties.pipelines
                                If ( ($TriggerResourceWithOutDependenciesAndWithPipelineReferences_ReferenceChildResources.count -gt 0 ) ) {
                                    $2PipelineReferenceMatchedInTrigger = $false
                                    Foreach ($TriggerResourceWithOutDependenciesAndWithPipelineReferences_ReferenceChildResource in $TriggerResourceWithOutDependenciesAndWithPipelineReferences_ReferenceChildResources) {
                                        If ( ( ($TriggerResourceWithOutDependenciesAndWithPipelineReferences_ReferenceChildResource.pipelineReference.referenceName ) -eq $Pipe ) ) {                           
                                            $2PipelineReferenceMatchedInTrigger = $true
                                        }
                                        Else {
                                            $2PipelineReferenceMatchedInTrigger = $false
                                        }
                                    }
                                    If ($2PipelineReferenceMatchedInTrigger) {
                                        Write-Output "Pipeline reference [ $Pipe ] identified on the trigger [ $($TriggerResourceWithOutDependenciesAndWithPipelineReferences.name.Substring(37, $TriggerResourceWithOutDependenciesAndWithPipelineReferences.name.Length - 40)) ] present in the file [ $Armtemplate ] . Adding to the deletion list ..."
                                        Write-Output ""
                                        $TriggerAndPipelineReference = @{"SourcePipeline" = $pipe; "FileName" = $Armtemplate ; "TriggerName" = $($TriggerResourceWithOutDependenciesAndWithPipelineReferences.name.Substring(37, $TriggerResourceWithOutDependenciesAndWithPipelineReferences.name.Length - 40)) }
                                        $TriggerAndPipelineResourcesList += $TriggerAndPipelineReference
                                        $TriggerResourceWithOutDependenciesAndWithPipelineReferences.properties.pipelines = $TriggerResourceWithOutDependenciesAndWithPipelineReferences.properties.pipelines | Where-Object { $_.pipelineReference.referenceName -ne $Pipe }
                                        $TriggerResourcesWithOutDependenciesAndWithPipelineReferencesUpdated += $TriggerResourceWithOutDependenciesAndWithPipelineReferences
                                    }
                                    Else {
                                        $TriggerResourcesWithOutDependenciesAndWithPipelineReferencesUpdated += $TriggerResourceWithOutDependenciesAndWithPipelineReferences
                                    }
                                    Remove-variable TriggerResourceWithOutDependenciesAndWithPipelineReferences -ErrorAction SilentlyContinue

                                }

                            }
                            
                            Write-Output "Pipeline Name :: $Pipe"
                            Write-Output "File Path :: [ $Armtemplate ] "
                            Write-Output "Original Resources count: $($templateJson.resources.Count)"                        
                            #Removing the piepline resources. #we are not removing the dependent pipelines
                            If ($RequiredPipelines.count -gt 0) {
                                Foreach ($RequiredPipeline in $RequiredPipelines) {
                                    $AllAdfResources = $AllAdfResources | Where-Object { ($_.name –ne $RequiredPipeline.name) }
                                }
                            }
                            $templateJson.resources = $AllAdfResources                        
                            #Write-Output "Resources count after removing pipelines: $($templateJson.resources.Count)"
                            Write-Output "Resources count after removing pipelines: $($AllAdfResources.count) "
                            #Filter the trigger resources and add back the rest of the resources.
                            $ResourcesWithoutTriggers = @()
                            $ResourcesWithoutTriggers += $AllAdfResources | Where-Object { ($_.type -ne "Microsoft.DataFactory/factories/triggers") }  
                            $templateJson.resources = $ResourcesWithoutTriggers
                            Write-Output "Resources count after removing triggers: $($templateJson.resources.Count)"
                            #Add back the triggers which doesn't have any dependencies on the resources or any pipeline references
                            $TriggerResourcesWithoutDependenciesAndWithoutPipelineReferences = $AllAdfResources | Where-Object { ($_.type -eq "Microsoft.DataFactory/factories/triggers") -and ($_.dependsOn.count -le 0 ) -and ($_.properties.pipelines.count -le 0 ) }                           
                            $templateJson.resources += $TriggerResourcesWithoutDependenciesAndWithoutPipelineReferences
                            $TriggerResourcesWithoutDependenciesAndWithoutPipelineReferences | Foreach-Object { $_.name }
                            Write-Output "Resources count after adding back the triggers with no dependencies and no pipeline references: $($templateJson.resources.Count)"
                            #Add back the triggers which have dependencies on the resources as well as having pipeline references
                            $templateJson.resources += $TriggerResourcesWithDependenciesAndWithPipelineReferencesUpdated
                            $TriggerResourcesWithDependenciesAndWithPipelineReferencesUpdated | Foreach-Object { $_.name }
                            Write-Output "Resources count after adding back the triggers with dependencies as well as pipeline references: $($templateJson.resources.Count)"
                            #Add back the triggers which have dependencies on other resources, but do not have pipeline references
                            $templateJson.resources += $TriggerResourcesWithDependenciesAndWithOutPipelineReferencesUpdated
                            $TriggerResourcesWithDependenciesAndWithOutPipelineReferencesUpdated | Foreach-Object { $_.name }
                            Write-Output "Resources count after adding back the triggers with dependencies but no pipeline references: $($templateJson.resources.Count)"
                            #Add back the triggers which do not have dependencies, but have pipeline references
                            $templateJson.resources += $TriggerResourcesWithOutDependenciesAndWithPipelineReferencesUpdated
                            $TriggerResourcesWithOutDependenciesAndWithPipelineReferencesUpdated | Foreach-Object { $_.name }
                            Write-Output "Resources count after adding back the triggers with no dependencies but have pipeline references: $($templateJson.resources.Count)"
                 
                            #Removing the \u0027 unicode characters and doing inplace update of the file
                            Try {
                                Write-Output "Updating the ARM template file [ $Armtemplate ] ..."
                                Write-Output ""
                                $templateJson | ConvertTo-Json -Depth 100 | ForEach-Object {
                                    [Regex]::Replace($_, 
                                        "\\u(?<Value>[a-zA-Z0-9]{4})", {
                                            param($m) ([char]([int]::Parse($m.Groups['Value'].Value,
                                                        [System.Globalization.NumberStyles]::HexNumber))).ToString() } )
                                } | Format-Json | Set-Content $Armtemplate -Force
                            }
                            Catch {
                                Write-Error "Failed to update the ARM template file [ $Armtemplate ]. Exiting the script ..."
                                Write-Output "Error Message :: $($_.Exception.Message)" 
                                Write-Output "Error command :: $($_.InvocationInfo.PositionMessage)"    
                                Break ; 
                            }                                    

                        }
                        Else {
                            Write-Output "There are no resources found in the file [ $armTemplate ]. Skipping ..."

                        }
                        #Include the wait time if there are any lock issues
                        #Start-Sleep 3                           
                    }            
             
                }
            }
            #List the overall output
            Write-Output ""
            Write-Output ""
            Write-Output "Below listed Source pipelines are deleted from the templates. ..."
            Write-Output ""
            If ($AllRequiredPipelines.Count -gt 0) {
                Foreach ($item in $AllRequiredPipelines) {
                    Write-Output "    Source Pipeline :: [ $($item.SourcePipeline) ]"
                    Write-Output "    File Path :: [ $($item.FileName) ]"
                    Write-Output ""
                }
            }
            Else {
                Write-Output "No source pipelines are deleted ..."
            }
            Write-Output ""
            Write-Output "Below listed source pipelines are removed from the trigger references ..."
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
                Write-Output "No source pipelines are removed from the trigger references ..."
            }
            Write-Output ""
            Write-Output "The below listed pipeline dependencies are removed from the triggers ..."
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
                Write-Output "No pipeline dependencies are removed from the triggers ..."
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

