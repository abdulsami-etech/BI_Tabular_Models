param(
    #DevOps PAT Token ; -DevOpsToken "tyyyyytyyyt"
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]
    $DevOpsToken,

    #DevOps org ; -DevOpsOrg "AlignDataAnalytics"
    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [string]
    $DevOpsOrg = "AlignDataAnalytics",

    #DevOps Project ; -DevOpsProject "ADFFrameworkDataPipeline"
    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [string]
    $DevOpsProject = "ADFFrameworkDataPipeline",

    #DevOps Feed ; -DevOpsFeed "SqlArtifacts"
    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [string]
    $DevOpsFeed = "SqlArtifacts",

    #Package Name ; -PackageName "SqlContributor"
    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [string]
    $PackageName = "sqlcontributor",

    #Package Version ; -PackageVersion "0.0.1"
    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [string]
    $PackageVersion = "0.0.1"
    )
$Env:AZURE_DEVOPS_EXT_PAT = "$DevOpsToken"
Az --version
$SqlPackageExecutablePath = (Get-ChildItem -Path "C:\Program Files\Microsoft SQL Server" -Recurse SQLPackage.exe).directoryname
Write-Output "SQL Executable Path: $SqlPackageExecutablePath"
$CheckExt = az extension list --query "[?name=='azure-devops']" -o json
If ($CheckExt.length -le 2) {
az extension add --name azure-devops
}
az devops configure --defaults organization="https://dev.azure.com/$DevOpsOrg" project="$DevOpsProject"
az artifacts universal download --organization "https://dev.azure.com/$DevOpsOrg" --project="$DevOpsProject" --scope project --feed "$DevOpsFeed" --name "$PackageName" --version "$PackageVersion" --path "$SqlPackageExecutablePath"

Write-output "Path Contents:: "
Get-ChildItem -Path $SqlPackageExecutablePath