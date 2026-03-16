[CmdletBinding()]
param
(
    [Parameter(Mandatory = $True)]
    [String]
    $DeployerID,

    [Parameter(Mandatory = $True)]
    [String]
    $DeployerPassword,

    [Parameter(Mandatory = $True)]
    [String]
    $Environment,

    [parameter(Mandatory = $false)] 
    [String] 
    $ResourceGroupName,

    [parameter(Mandatory = $false)] 
    [String] 
    $DataFactoryName,

    [parameter(Mandatory = $false)] 
    [String[]] 
    $TriggerNamesToExcludeFromStarting,

    [parameter(Mandatory = $false)] 
    [Bool] 
    $predeployment=$True
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

# Triggers 
Write-Output "Getting triggers from [$DataFactoryName] present in the resource group [$ResourceGroupName]..."
Try {
    $TriggersADF = Get-AzDataFactoryV2Trigger -DataFactoryName $DataFactoryName -ResourceGroupName $ResourceGroupName -ErrorAction Stop
}
Catch {
    Write-Error "Failed to get the triggers from [$DataFactoryName] present in the resource group [$ResourceGroupName] with the provided parameters. Skipping the execution..."
    Write-Output "Error Message :: $($_.Exception.Message)" 
    Write-Output "Error command :: $($_.InvocationInfo.PositionMessage)"      
    Break ;      
}

If ($predeployment -eq $true) {
    If ($TriggersADF) {
        $ActiveTriggers = $TriggersADF | Where-Object { $_.properties.runtimeState -eq "Started" -and ($_.properties.pipelines.Count -gt 0 -or $_.properties.pipelines.pipelineReference -ne $null)}
    }
    If ($ActiveTriggers) {
        #Stop all triggers
        Write-Output "Stopping deployed triggers in [$DataFactoryName] present in the resource group [$ResourceGroupName] ..."
        $ActiveTriggers | ForEach-Object { 
            Write-Output "Disabling trigger:: $($_.Name) in [$DataFactoryName] present in the resource group [$ResourceGroupName]"
            Try {
                Stop-AzDataFactoryV2Trigger -ResourceGroupName $ResourceGroupName -DataFactoryName $DataFactoryName -Name $_.name -Force -ErrorAction Stop
            }
            Catch {
                Write-Error "Failed to stop the trigger [$($_.Name)] in the datafactory [$DataFactoryName]. Skipping the execution..."
                Write-Output "Error Message :: $($_.Exception.Message)" 
                Write-Output "Error command :: $($_.InvocationInfo.PositionMessage)"      
                Break ;
            }
            
        }
    }
    Else {
        Write-Output "No active triggers found in the datafactory [$DataFactoryName]. Skipping to take any action..."
    }
}
Else {
    If ($TriggersADF) {
        $InActiveTriggers = $TriggersADF | Where-Object { $_.properties.runtimeState -eq "Stopped" -and ($_.properties.pipelines.Count -gt 0 -or $_.properties.pipelines.pipelineReference -ne $null)}
    }
    If ($InActiveTriggers) {
        #Start all triggers
        Write-Output "Starting deployed triggers in [$DataFactoryName] present in the resource group [$ResourceGroupName] ..."
        $InActiveTriggers | ForEach-Object {
            If ($TriggerNamesToExcludeFromStarting.Count -gt 0) {                
                If ($TriggerNamesToExcludeFromStarting -icontains $_.Name) {
                    Write-Output "Trigger::  [ $($_.Name) ] is in the exclusion list. So ignoring to start the trigger ..."
                }
                Else {
                    Write-Output "Starting trigger:: $($_.Name) within [$DataFactoryName] present in the resource group [$ResourceGroupName] ..."
                    Try {
                        Start-AzDataFactoryV2Trigger -ResourceGroupName $ResourceGroupName -DataFactoryName $DataFactoryName -Name $_.name -Force  -ErrorAction Stop
                    }
                    Catch {
                        Write-Error "Failed to start the trigger [$($_.Name)] in the datafactory [$DataFactoryName]. Skipping the execution..."
                        Write-Output "Error Message :: $($_.Exception.Message)" 
                        Write-Output "Error command :: $($_.InvocationInfo.PositionMessage)"      
                        Break ;
                    }            
                }
                
            }
            Else {
                Write-Output "Starting trigger:: $($_.Name) within [$DataFactoryName] present in the resource group [$ResourceGroupName] ..."
                Try {
                    Start-AzDataFactoryV2Trigger -ResourceGroupName $ResourceGroupName -DataFactoryName $DataFactoryName -Name $_.name -Force  -ErrorAction Stop
                }
                Catch {
                    Write-Error "Failed to start the trigger [$($_.Name)] in the datafactory [$DataFactoryName]. Skipping the execution..."
                    Write-Output "Error Message :: $($_.Exception.Message)" 
                    Write-Output "Error command :: $($_.InvocationInfo.PositionMessage)"     
                    Break ;
                }
            }
            
        }
    }
    Else {
        Write-Output "No inactive triggers found in the datafactory [$DataFactoryName]. Skipping to take any action..."
    }
}
Remove-Variable DataFactoryName, ResourceGroupName -ErrorAction SilentlyContinue
