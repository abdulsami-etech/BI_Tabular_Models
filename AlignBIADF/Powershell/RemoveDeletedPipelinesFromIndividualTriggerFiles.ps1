[CmdletBinding()]
Param
(
    # Folder name where the published ARM templates are present
    [parameter(Mandatory = $true)] 
    [String] 
    $rootFolderForTemplates,
    
    #Pipeline Name and the associated trigger name should be passed as a hash table in the below listed format
    #@( @{TriggerName = "every 1 hour at 00 minutes"; PipelineNameToRemove = "ADLSv2_MESCorp_Master"}, @{TriggerName = "every 1 hour at 00 minutes2"; PipelineNameToRemove = "ADLSv2_MESFABMX1_Master"} ) 
    [parameter(Mandatory = $false)] 
    [Hashtable[]] 
    $PipelineAndTriggerNames = @( )     
)
<#
Notes:
1) This script needs to be run before changing the schedules
2) If the pipeline is listed in the deletion list of the Azure DevOps pipeline variable, and the pipeline has a trigger associated with it, then you MUST include that pipeline name and trigger name in this list as well. 
If you do not include them, then the rest of scripts for changing the trigger schedules could fail, in the pipeline
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

Function Remove-AzArmTemplateTriggerResource {
    [OutputType('void')]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$TemplatePathWithOutBackSlashAndFilename,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$TriggerName,

        [Parameter(Mandatory = $false)]
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

            Write-Output "Removing the pipeine [ $PipelineNameToRemove ] on the trigger [ $TriggerName ] from the file [ $TemplatePath ]"
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

If ($PipelineAndTriggerNames.count -gt 0) {
    Foreach ($PipelineAndTriggerName in $PipelineAndTriggerNames.GetEnumerator()) {
        $PipelineAndTriggerName.Add("TemplatePathWithOutBackSlashAndFilename", "$rootFolderForTemplates") | Out-Null
        $AllValues = $PipelineAndTriggerName        
        Remove-AzArmTemplateTriggerResource @AllValues        
    }
}
Else {
    Write-Output ""
    Write-Output "No pipeline and trigger names are specified for the deletion. Skipping to take any action ..."
}