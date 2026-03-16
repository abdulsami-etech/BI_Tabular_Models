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
    $PastDays = 2,

    [parameter(Mandatory = $false)] 
    [String] 
    $DataFactoryName,

    [parameter(Mandatory = $false)] 
    [String] 
    $ResourcegroupName,

    [parameter(Mandatory = $false)] 
    [String] 
    $TotalIterations = 15,
    
    [parameter(Mandatory = $false)] 
    [String] 
    $BreakIterations = 10,
    
    [parameter(Mandatory = $false)] 
    [String] 
    $SleepSeconds = 60     
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
    Write-Output "Failed to set the subscription context for the subscription [$SubscriptionName] with the below error. Skipping the execution..." -ForegroundColor yellow
    Write-Output "Error Message :: $($_.Exception.Message)" -ForegroundColor Red
    Write-Error "Error command :: $($_.InvocationInfo.PositionMessage)" -ForegroundColor Red     
    Break ;                
}

For($i = 1; $i -le $TotalIterations; $i++) {
    Write-Output "Iteration# $i :: Fetching the pipeline runs which are currently running..."
    Try {        
        $InProgressRuns = Get-AzDataFactoryV2PipelineRun -ResourceGroupName $ResourcegroupName `
            -DataFactoryName $DatafactoryName `
            -LastUpdatedAfter (Get-Date).Adddays(-$PastDays) `
            -LastUpdatedBefore (Get-Date).AddHours(1) | Where-Object {$_.Status -eq "InProgress"} -ErrorAction Stop
    }
    Catch {
        Write-Output "Failed to get the list of the pipeline runs in the datafactory [$DataFactoryName]. Exiting the script..."
        Write-Output "Error Message :: $($_.Exception.Message)" 
        Write-Error "Error command :: $($_.InvocationInfo.PositionMessage)"
        Break;
    }

    If ($($InProgressRuns.count) -le "0") {
        Write-Output  "There are no pipelines runs in Inprogress state in the datafactory [$DataFactoryName]. Exiting the script..."
        Break;
    }
    Else {
        Write-Output "Still $($InProgressRuns.count) pipeline runs are in Inprogress state in the datafactory [$DataFactoryName]."
        Foreach ($InProgressRun in $InProgressRuns) {
            Write-Output "    Pipeline [$($InProgressRun.PipelineName)] with the RunID [$($InProgressRun.RunId)] is still running ..."
        }
        If ($i -ge $BreakIterations) {
            Write-Output "Reached the break iterations limit#[$BreakIterations]. Cancelling the inprogress runs..."
            Foreach ($InProgressRun in $InProgressRuns) {
                Write-Output "Cancelling the pipeline [$($InProgressRun.PipelineName)] with the RunID [$($InProgressRun.RunId)] in the datafactory [$DataFactoryName] ..."
                Stop-AzDataFactoryV2PipelineRun -ResourceGroupName "$ResourcegroupName" -DataFactoryName "$DataFactoryName" -PipelineRunId "$($InProgressRun.RunId)" -PassThru -Confirm:$false -ErrorAction "SilentlyContinue"

            }
        }
        Write-Output "Sleeping for $SleepSeconds seconds"
        Start-Sleep -Seconds $SleepSeconds
    }

    If ($i -ge $TotalIterations) {
        Write-Output "$($InProgressRuns.count) Pipeline runs are still in Inprogress state after $i iterations in the datafactory [$DataFactoryName]. Skipping the execution..."
        Write-Error "Please retry again..."
        Break;
    }
}




