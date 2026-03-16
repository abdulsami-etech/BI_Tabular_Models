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

    [parameter(Mandatory = $false)] 
    [String] 
    $DataFactoryName,

    [parameter(Mandatory = $false)] 
    [String] 
    $ResourcegroupName,    
    
    # Folder name where the published ARM templates are present
    [parameter(Mandatory = $true)] 
    [String] 
    $rootFolderForTemplates ,
    
    #Pipeline Name and the associated trigger name should be passed as a hash table in the below listed format
    #@( @{TriggerName = "every 1 hour at 00 minutes"; PipelineNameToRemove = "ADLSv2_MESCorp_Master"}, @{TriggerName = "every 1 hour at 00 minutes2"; PipelineNameToRemove = "ADLSv2_MESFABMX1_Master"} )
    #
    # Minute Format:: @{TriggerName = "every 1 hour at 00 minutes3"; ScheduleFrequency = "Minute" ; ScheduleInterval = 5 } 
    #              # ScheduleInterval should not be empty and it should be a positive number
    #
    # Hour Format:: @{TriggerName = "every 1 hour at 00 minutes3"; ScheduleFrequency = "Hour" ; ScheduleInterval = 6 }
    #              # ScheduleInterval should not be empty and it should be a positive number 
    #
    # Day Format:: @{TriggerName = "every 1 hour at 00 minutes3"; ScheduleFrequency = "Day" ; ScheduleInterval = 1 ; ScheduleHours = @(2,5) ; ScheduleMinutes = @(30,40)  } 
    #              # If you pass ScheduleHours = @(2,5) ; ScheduleMinutes = @(30,40). It means it will run for every 2:30, 2:40, 5:30, 5:40 etc
    #              # ScheduleInterval should not be empty and it should be a positive number
    #
    # Week Format:: @{TriggerName = "every 1 hour at 00 minutes3"; ScheduleFrequency = "Week" ; ScheduleInterval = 1 ; ScheduleHours = @(2,5) ; ScheduleMinutes = @(30,40) ; ScheduleWeekDays = @("Monday","Wednesday","Tuesday") } 
    #              # If you pass ScheduleHours = @(2,5) ; ScheduleMinutes = @(30,40). It means it will run for every 2:30, 2:40, 5:30, 5:40 etc
    #              # ScheduleInterval should not be empty and it should be a positive number
    #              # Valid WeekDays are "Monday", "Tuesday", "Wednesday", "Thursday", "Friday" , "Saturday" , "Sunday"
    #
    # Month Format:: @{TriggerName = "every 1 hour at 00 minutes3"; ScheduleFrequency = "Month" ; ScheduleInterval = 1 ; ScheduleHours = @(2,5) ; ScheduleMinutes = @(30,40) ; ScheduleMonthDays = @(1,31) } 
    #              # If you pass ScheduleHours = @(2,5) ; ScheduleMinutes = @(30,40). It means it will run for every 2:30, 2:40, 5:30, 5:40 etc
    #              # ScheduleInterval should not be empty and it should be a positive number
    #              # Valid monthkDays are 1 through 31
    [parameter(Mandatory = $false)] 
    [Hashtable[]] 
    $TriggerNamesAndSchedules = @( )     
)

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
        [string]$ScheduleFrequency,

        [Parameter(Mandatory = $false)]
        [Int]$ScheduleInterval,

        [Parameter(Mandatory = $false)]
        [int[]]$ScheduleHours,

        [Parameter(Mandatory = $false)]
        [int[]]$ScheduleMinutes,

        [Parameter(Mandatory = $false)]
        [string[]]$ScheduleWeekDays,

        [Parameter(Mandatory = $false)]
        [int[]]$ScheduleMonthDays

    )
$CurrentDate = [DateTime]::UtcNow | get-date -Format "yyyy-MM-ddTHH:mm:ss.000Z"
If (!$CurrentDate) {
    $CurrentDate = "2020-02-06T18:28:52.000Z"
}
switch ($ScheduleFrequency) {
"Minute" {
$RecurrenceBlock = @"
{
    "frequency": "Minute",
    "interval": 1,
    "startTime": "$($CurrentDate)",
    "timeZone": "UTC"
}
"@
}
"Hour" {
$RecurrenceBlock = @"
{
    "frequency": "Hour",
    "interval": 1,
    "startTime": "$($CurrentDate)",
    "timeZone": "UTC"
}
"@
}
"Day" {
$RecurrenceBlock = @"
{
    "frequency": "Day",
    "interval": 1,
    "startTime": "$($CurrentDate)",
    "timeZone": "UTC",
    "schedule": {
        "minutes": [
            30,
            40
        ],
        "hours": [
            2,
            5
        ]
    }
}
"@
}
"Week" {
$RecurrenceBlock = @"
{
    "frequency": "Week",
    "interval": 1,
    "startTime": "$($CurrentDate)",
    "timeZone": "UTC",
    "schedule": {
        "minutes": [
            30,
            40
        ],
        "hours": [
            2,
            5
        ],
        "weekDays": [
            "Monday",
            "Wednesday"
        ]
    }
}
"@
}
"Month" {
$RecurrenceBlock = @"
{
    "frequency": "Month",
    "interval": 1,
    "startTime": "$($CurrentDate)",
    "timeZone": "UTC",
    "schedule": {
        "minutes": [
            30,
            40
        ],
        "hours": [
            2,
            5
        ],
        "monthDays": [
            1,
            31
        ]
    }
}
"@
}        
}

    $FileName = $TriggerName + ".JSON"
    $TemplatePath = $($TemplatePathWithOutBackSlashAndFilename.TrimEnd("\")) + "\" + $FileName
    If (Test-Path $TemplatePath) {
        ## Read the template and convert to an object
        $ConvertedFileContent = Get-Content -Path $TemplatePath -Raw | ConvertFrom-Json
        If ($ConvertedFileContent) {
            $CurrentActionPreference = $ErrorActionPreference
            $ErrorActionPreference = 'Stop'
            Try {
                #Here no need to change the 'recurrence' block. We are just using the same block as the current frequency and requested frequency are the same values
                If ( ($ConvertedFileContent.properties.typeProperties.recurrence.frequency -eq $ScheduleFrequency) -and ($ConvertedFileContent.properties.type -eq "ScheduleTrigger")) {
                    Write-Output "Requested frequency [ $ScheduleFrequency ] is the same as the current frequency [ $($ConvertedFileContent.properties.typeProperties.recurrence.frequency) ]. Just updating the values ..."
                    If ( ($ScheduleFrequency -eq "Minute") -or ($ScheduleFrequency -eq "Hour")) {
                        ## Update the type properties for the trigger
                        If ($ScheduleFrequency -and $ScheduleInterval) {
                            $ConvertedFileContent.properties.typeProperties.recurrence.frequency = $ScheduleFrequency
                            $ConvertedFileContent.properties.typeProperties.recurrence.interval = $ScheduleInterval
                        }
                        Elseif ($ScheduleFrequency) {
                            $ConvertedFileContent.properties.typeProperties.recurrence.frequency = $ScheduleFrequency
                        }
                        Elseif ($ScheduleInterval) {
                            $ConvertedFileContent.properties.typeProperties.recurrence.interval = $ScheduleInterval
                        }
                    }
                    ElseIf ( ($ScheduleFrequency -eq "Day") ) {
                        If ($ScheduleFrequency -and $ScheduleInterval) {
                            $ConvertedFileContent.properties.typeProperties.recurrence.frequency = $ScheduleFrequency
                            $ConvertedFileContent.properties.typeProperties.recurrence.interval = $ScheduleInterval
                            $ConvertedFileContent.properties.typeProperties.recurrence.schedule.hours = $ScheduleHours
                            $ConvertedFileContent.properties.typeProperties.recurrence.schedule.minutes = $ScheduleMinutes
                        }
                        Elseif ($ScheduleFrequency) {
                            $ConvertedFileContent.properties.typeProperties.recurrence.frequency = $ScheduleFrequency
                            $ConvertedFileContent.properties.typeProperties.recurrence.schedule.hours = $ScheduleHours
                            $ConvertedFileContent.properties.typeProperties.recurrence.schedule.minutes = $ScheduleMinutes
                        }
                        Elseif ($ScheduleInterval) {
                            $ConvertedFileContent.properties.typeProperties.recurrence.interval = $ScheduleInterval
                            $ConvertedFileContent.properties.typeProperties.recurrence.schedule.hours = $ScheduleHours
                            $ConvertedFileContent.properties.typeProperties.recurrence.schedule.minutes = $ScheduleMinutes
                        }

                    }
                    ElseIf ( ($ScheduleFrequency -eq "Week") ) {
                        If ($ScheduleFrequency -and $ScheduleInterval) {
                            $ConvertedFileContent.properties.typeProperties.recurrence.frequency = $ScheduleFrequency
                            $ConvertedFileContent.properties.typeProperties.recurrence.interval = $ScheduleInterval
                            $ConvertedFileContent.properties.typeProperties.recurrence.schedule.hours = $ScheduleHours
                            $ConvertedFileContent.properties.typeProperties.recurrence.schedule.minutes = $ScheduleMinutes
                            $ConvertedFileContent.properties.typeProperties.recurrence.schedule.weekDays = $ScheduleWeekDays
                        }
                        Elseif ($ScheduleFrequency) {
                            $ConvertedFileContent.properties.typeProperties.recurrence.frequency = $ScheduleFrequency
                            $ConvertedFileContent.properties.typeProperties.recurrence.schedule.hours = $ScheduleHours
                            $ConvertedFileContent.properties.typeProperties.recurrence.schedule.minutes = $ScheduleMinutes
                            $ConvertedFileContent.properties.typeProperties.recurrence.schedule.weekDays = $ScheduleWeekDays
                        }
                        Elseif ($ScheduleInterval) {
                            $ConvertedFileContent.properties.typeProperties.recurrence.interval = $ScheduleInterval
                            $ConvertedFileContent.properties.typeProperties.recurrence.schedule.hours = $ScheduleHours
                            $ConvertedFileContent.properties.typeProperties.recurrence.schedule.minutes = $ScheduleMinutes
                            $ConvertedFileContent.properties.typeProperties.recurrence.schedule.weekDays = $ScheduleWeekDays
                        }

                    }
                    ElseIf ( ($ScheduleFrequency -eq "Month") ) {
                        If ($ScheduleFrequency -and $ScheduleInterval) {
                            $ConvertedFileContent.properties.typeProperties.recurrence.frequency = $ScheduleFrequency
                            $ConvertedFileContent.properties.typeProperties.recurrence.interval = $ScheduleInterval
                            $ConvertedFileContent.properties.typeProperties.recurrence.schedule.hours = $ScheduleHours
                            $ConvertedFileContent.properties.typeProperties.recurrence.schedule.minutes = $ScheduleMinutes
                            $ConvertedFileContent.properties.typeProperties.recurrence.schedule.monthDays = $ScheduleMonthDays
                        }
                        Elseif ($ScheduleFrequency) {
                            $ConvertedFileContent.properties.typeProperties.recurrence.frequency = $ScheduleFrequency
                            $ConvertedFileContent.properties.typeProperties.recurrence.schedule.hours = $ScheduleHours
                            $ConvertedFileContent.properties.typeProperties.recurrence.schedule.minutes = $ScheduleMinutes
                            $ConvertedFileContent.properties.typeProperties.recurrence.schedule.monthDays = $ScheduleMonthDays
                        }
                        Elseif ($ScheduleInterval) {
                            $ConvertedFileContent.properties.typeProperties.recurrence.interval = $ScheduleInterval
                            $ConvertedFileContent.properties.typeProperties.recurrence.schedule.hours = $ScheduleHours
                            $ConvertedFileContent.properties.typeProperties.recurrence.schedule.minutes = $ScheduleMinutes
                            $ConvertedFileContent.properties.typeProperties.recurrence.schedule.monthDays = $ScheduleMonthDays
                        }

                    }
                }
                Elseif ( ($ConvertedFileContent.properties.typeProperties.recurrence.frequency -ne $ScheduleFrequency) -and ($ConvertedFileContent.properties.type -eq "ScheduleTrigger") ) {
                    Write-Output "Requested frequency [ $ScheduleFrequency ] is different to that of current frequency [ $($ConvertedFileContent.properties.typeProperties.recurrence.frequency) ]. So adding new recurrence block and updating the values ..."
                    #Here we are changing the 'recurrence' block as current frequency and the requested frequency are different
                    If ($ScheduleFrequency -eq "Minute") {
                        $ConvertedFileContent.properties.typeProperties.recurrence = $RecurrenceBlock | ConvertFrom-Json
                        If ($ScheduleFrequency -and $ScheduleInterval) {
                            $ConvertedFileContent.properties.typeProperties.recurrence.frequency = $ScheduleFrequency
                            $ConvertedFileContent.properties.typeProperties.recurrence.interval = $ScheduleInterval
                        }
                        Elseif ($ScheduleFrequency) {
                            $ConvertedFileContent.properties.typeProperties.recurrence.frequency = $ScheduleFrequency
                        }
                        Elseif ($ScheduleInterval) {
                            $ConvertedFileContent.properties.typeProperties.recurrence.interval = $ScheduleInterval
                        }

                    }
                    ElseIf ($ScheduleFrequency -eq "Hour") {
                        $ConvertedFileContent.properties.typeProperties.recurrence = $RecurrenceBlock | ConvertFrom-Json
                        If ($ScheduleFrequency -and $ScheduleInterval) {
                            $ConvertedFileContent.properties.typeProperties.recurrence.frequency = $ScheduleFrequency
                            $ConvertedFileContent.properties.typeProperties.recurrence.interval = $ScheduleInterval
                        }
                        Elseif ($ScheduleFrequency) {
                            $ConvertedFileContent.properties.typeProperties.recurrence.frequency = $ScheduleFrequency
                        }
                        Elseif ($ScheduleInterval) {
                            $ConvertedFileContent.properties.typeProperties.recurrence.interval = $ScheduleInterval
                        }

                    }
                    ElseIf ($ScheduleFrequency -eq "Day") {
                        $ConvertedFileContent.properties.typeProperties.recurrence = $RecurrenceBlock | ConvertFrom-Json
                        If ($ScheduleFrequency -and $ScheduleInterval) {
                            $ConvertedFileContent.properties.typeProperties.recurrence.frequency = $ScheduleFrequency
                            $ConvertedFileContent.properties.typeProperties.recurrence.interval = $ScheduleInterval
                            $ConvertedFileContent.properties.typeProperties.recurrence.schedule.hours = $ScheduleHours
                            $ConvertedFileContent.properties.typeProperties.recurrence.schedule.minutes = $ScheduleMinutes
                        }
                        Elseif ($ScheduleFrequency) {
                            $ConvertedFileContent.properties.typeProperties.recurrence.frequency = $ScheduleFrequency
                            $ConvertedFileContent.properties.typeProperties.recurrence.schedule.hours = $ScheduleHours
                            $ConvertedFileContent.properties.typeProperties.recurrence.schedule.minutes = $ScheduleMinutes
                        }
                        Elseif ($ScheduleInterval) {
                            $ConvertedFileContent.properties.typeProperties.recurrence.interval = $ScheduleInterval
                            $ConvertedFileContent.properties.typeProperties.recurrence.schedule.hours = $ScheduleHours
                            $ConvertedFileContent.properties.typeProperties.recurrence.schedule.minutes = $ScheduleMinutes
                        }

                    }
                    ElseIf ($ScheduleFrequency -eq "Week") {
                        $ConvertedFileContent.properties.typeProperties.recurrence = $RecurrenceBlock | ConvertFrom-Json
                        If ($ScheduleFrequency -and $ScheduleInterval) {
                            $ConvertedFileContent.properties.typeProperties.recurrence.frequency = $ScheduleFrequency
                            $ConvertedFileContent.properties.typeProperties.recurrence.interval = $ScheduleInterval
                            $ConvertedFileContent.properties.typeProperties.recurrence.schedule.hours = $ScheduleHours
                            $ConvertedFileContent.properties.typeProperties.recurrence.schedule.minutes = $ScheduleMinutes
                            $ConvertedFileContent.properties.typeProperties.recurrence.schedule.weekDays = $ScheduleWeekDays
                        }
                        Elseif ($ScheduleFrequency) {
                            $ConvertedFileContent.properties.typeProperties.recurrence.frequency = $ScheduleFrequency
                            $ConvertedFileContent.properties.typeProperties.recurrence.schedule.hours = $ScheduleHours
                            $ConvertedFileContent.properties.typeProperties.recurrence.schedule.minutes = $ScheduleMinutes
                            $ConvertedFileContent.properties.typeProperties.recurrence.schedule.weekDays = $ScheduleWeekDays
                        }
                        Elseif ($ScheduleInterval) {
                            $ConvertedFileContent.properties.typeProperties.recurrence.interval = $ScheduleInterval
                            $ConvertedFileContent.properties.typeProperties.recurrence.schedule.hours = $ScheduleHours
                            $ConvertedFileContent.properties.typeProperties.recurrence.schedule.minutes = $ScheduleMinutes
                            $ConvertedFileContent.properties.typeProperties.recurrence.schedule.weekDays = $ScheduleWeekDays
                        }

                    }
                    ElseIf ($ScheduleFrequency -eq "Month") {
                        $ConvertedFileContent.properties.typeProperties.recurrence = $RecurrenceBlock | ConvertFrom-Json
                        If ($ScheduleFrequency -and $ScheduleInterval) {
                            $ConvertedFileContent.properties.typeProperties.recurrence.frequency = $ScheduleFrequency
                            $ConvertedFileContent.properties.typeProperties.recurrence.interval = $ScheduleInterval
                            $ConvertedFileContent.properties.typeProperties.recurrence.schedule.hours = $ScheduleHours
                            $ConvertedFileContent.properties.typeProperties.recurrence.schedule.minutes = $ScheduleMinutes
                            $ConvertedFileContent.properties.typeProperties.recurrence.schedule.monthDays = $ScheduleMonthDays
                        }
                        Elseif ($ScheduleFrequency) {
                            $ConvertedFileContent.properties.typeProperties.recurrence.frequency = $ScheduleFrequency
                            $ConvertedFileContent.properties.typeProperties.recurrence.schedule.hours = $ScheduleHours
                            $ConvertedFileContent.properties.typeProperties.recurrence.schedule.minutes = $ScheduleMinutes
                            $ConvertedFileContent.properties.typeProperties.recurrence.schedule.monthDays = $ScheduleMonthDays
                        }
                        Elseif ($ScheduleInterval) {
                            $ConvertedFileContent.properties.typeProperties.recurrence.interval = $ScheduleInterval
                            $ConvertedFileContent.properties.typeProperties.recurrence.schedule.hours = $ScheduleHours
                            $ConvertedFileContent.properties.typeProperties.recurrence.schedule.minutes = $ScheduleMinutes
                            $ConvertedFileContent.properties.typeProperties.recurrence.schedule.monthDays = $ScheduleMonthDays
                        }

                    }

                }
            }
            Catch {
                Write-Output "Failed to update the schedule properties in the JSON file with the below error. Exiting the script..."
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

            Write-Output "Updating the schedule on the trigger [ $TriggerName ] from the file [ $TemplatePath ]"
            Try {
                ## Commit to disk
                $TemplateR | Set-Content -Path $TemplatePath
            }
            Catch {
                Write-Error "Failed to update the schedule on the trigger [ $TriggerName ] from the file [ $TemplatePath ]. Exiting the script ..."
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
        Write-Output "Failed to get the trigger [$AdfTriggerName] from the datafactory [$AdfDatafactoryName] located in the resource group [$AdfResourceGroupName] with the below error. Skipping the execution..."
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
                Write-Output "Failed to set the trigger [$AdfTriggerName] using the definition file [$DefinitionFilePath] in the datafactory [$AdfDatafactoryName] located in the resource group [$AdfResourceGroupName] with the below error. Skipping the execution..."
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


If ($TriggerNamesAndSchedules.count -gt 0) {
    Foreach ($TriggerNameAndSchedule in $TriggerNamesAndSchedules) {
        $TriggerNameAndSchedule.Add("TemplatePathWithOutBackSlashAndFilename", "$rootFolderForTemplates") | Out-Null
        $AllValues = $TriggerNameAndSchedule        
        Remove-AzArmTemplateTriggerResource @AllValues
        Set-TheTriggerUsingTheDefinitionFile -AdfTemplatePathWithOutBackSlashAndFilename "$rootFolderForTemplates" -AdfTriggerName $($AllValues.TriggerName) -AdfResourceGroupName $ResourceGroupName -AdfDatafactoryName $DataFactoryName     
    }
}
Else {
    Write-Output ""
    Write-Output "No trigger and schedules are specified for doing the trigger schedules update. Skipping to take any action ..."
}