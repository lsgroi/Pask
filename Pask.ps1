<#
.SYNOPSIS
Modular task-oriented PowerShell build automation for .NET

.DESCRIPTION
This command invokes a set of PowerShell build automation tasks.

.LINK
https://github.com/lsgroi/Pask
https://github.com/nightroman/Invoke-Build

.PARAMETER Task
One or more tasks to be invoked.
Special task '?' would list the tasks with brief information without invoking.

.PARAMETER Result
Tells to output build information using a variable.

.PARAMETER Safe
Tells to catch a build failure, store an error as the property Error of Result and return quietly.

.PARAMETER Summary
Tells to show summary information after the build.

.PARAMETER Properties
A set of properties passed to the build script.

.PARAMETER SolutionFilePath
The relative path to the solution file.

.PARAMETER SolutionName
Base name of the solution.

.PARAMETER ProjectName
Base name of the default project.

.PARAMETER Tree
Tells to visualize specified build task tree as indented text with brief task details.
#>

param(
    # Invoke-Build specific parameters
    [Parameter(Position=0)][string[]]$Task = ".",
    $Result,
    [switch]$Safe,
    [switch]$Summary = $true,
    [Parameter(ValueFromRemainingArguments=$true)]$Properties,
    
    # Pask specific parameters
    [string]$SolutionFilePath,
    [string]$SolutionName = (Get-ChildItem -Path (Join-Path $PSScriptRoot $SolutionFilePath) *.sln | Sort-Object -Descending | Select-Object -First 1).BaseName,
    [string]$ProjectName = $SolutionName,
    [switch]$Tree
)

$ErrorActionPreference = "Stop"

# Include Pask script
$private:PaskScriptFullName = Join-Path $PSScriptRoot ".build\scripts\Pask.ps1"
. $PaskScriptFullName

# Expose properties passed to the script
for ($i=0; $i -lt $Properties.Count; $i+=2) {
    Set-BuildProperty -Name ($Properties[$i] -replace '^-+') -Value $Properties[$i+1]
}

# Set default properties
Set-BuildProperty -Name PaskFullPath -Value $PSScriptRoot
Set-BuildProperty -Name SolutionName -Value $SolutionName
Set-BuildProperty -Name SolutionFullPath -Value (Join-Path $PaskFullPath $SolutionFilePath)
Set-BuildProperty -Name SolutionFullName -Value (Join-Path $SolutionFullPath "$SolutionName.sln")
Set-BuildProperty -Name BuildFullPath -Value (Join-Path $PaskFullPath ".build")
Set-BuildProperty -Name BuildOutputFullPath -Value (Join-Path $BuildFullPath "output")
Set-BuildProperty -Name TestsArtifactFullPath -Value (Join-Path $BuildOutputFullPath "Tests")
Set-BuildProperty -Name TestsResultsFullPath -Value (Join-Path $BuildOutputFullPath "TestsResults")

# Test solution existence
if(-not (Test-Path $SolutionFullName)) { Write-Error "Cannot find '$SolutionName' solution in '$SolutionFullPath'" }

# Restore NuGet packages marked as development-only-dependency
Write-BuildMessage -Message "Restore NuGet development dependencies" -ForegroundColor "Cyan"
Restore-NuGetDevelopmentPackages

# Define the default project
Set-Project -Name $ProjectName

# Set Invoke-Build alias
Set-Alias Invoke-Build (Join-Path (Get-PackageDir "Invoke-Build") "tools\Invoke-Build.ps1") -Scope Script

# Invoke the build
$private:BuildScript = New-Item -ItemType File -Name "$([System.IO.Path]::GetRandomFileName()).ps1" -Path $Env:Temp -Value {
    Import-Script Init -Safe
    Import-Properties -All
    . "$(Join-Path $BuildFullPath "build.ps1")"
}
if ($Tree) {
    Write-BuildMessage -Message "Show build task tree" -ForegroundColor "Cyan"
    Import-Script Show-BuildTree
    Show-BuildTree -File "$($BuildScript.FullName)" -Task $Task
} else {
    Invoke-Build -File "$($BuildScript.FullName)" -Task $Task -Result "!BuildResult!" -Safe:$Safe -Summary:$Summary
    if ($Result -and $Result -is [string]) {
        New-Variable -Name $Result -Force -Scope 1 -Value ${!BuildResult!}
    } elseif ($Result) {
        $Result.Value = ${!BuildResult!}
    }
}
Remove-Item "$($BuildScript.FullName)" -Force