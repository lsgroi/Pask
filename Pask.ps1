<#
.SYNOPSIS
PowerShell Build Automation for .NET

.DESCRIPTION
This command invokes a set of PowerShell build automation scripts.

.LINK
https://github.com/lsgroi/Pask/wiki
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
An hashtable of properties passed in the build script.

.PARAMETER Tree
Tells to visualize specified build task trees as indented text with brief task details.

.PARAMETER SolutionPath
The relative path to the solution directory.

.PARAMETER SolutionName
Default to the first solution found in SolutionPath.

.PARAMETER ProjectName
Name of the default project.
#>

param(
    # Invoke-Build specific parameters
    [Parameter(Position=0)][string[]]$Task = ".",
	$Result,
	[switch]$Safe,
	[switch]$Summary = $true,
    [Parameter(Mandatory=$false,ValueFromRemainingArguments=$true)]$Properties,
    
    # Pask specific parameters
    [switch]$Tree,
    [Alias("SolutionPath")][string]$private:SolutionPath = (Split-Path $PSScriptRoot -Leaf),
    [string]$SolutionName = (Get-ChildItem -Path "$(Join-Path (Split-Path $PSScriptRoot) $SolutionPath)" *.sln | Select-Object -First 1).BaseName,
    [string]$ProjectName = $SolutionName
)

$ErrorActionPreference = "Stop"

# Set main properties
$SolutionFullPath = Join-Path (Split-Path $PSScriptRoot) $private:SolutionPath
$SolutionFullName = Join-Path $SolutionFullPath "$SolutionName.sln"
$BuildFullPath = Join-Path $SolutionFullPath ".build"
$BuildOutputFullPath = Join-Path $BuildFullPath "output"
$TestsArtifactFullPath = Join-Path $BuildOutputFullPath "Tests"
$TestsResultsFullPath = Join-Path $BuildOutputFullPath "TestsResults"

# Include Pask script
. (Join-Path $BuildFullPath "scripts\Pask.ps1")

# Define the default project
Set-Project -Name $ProjectName

# Restore NuGet packages
Write-BuildMessage -Message "Restore NuGet packages" -ForegroundColor "Cyan"
Restore-NuGetPackages

# Expose properties as variables
for ($i=0; $i -lt $Properties.Count; $i+=2) {
    New-Variable -Name ($Properties[$i] -replace '^-+') -Value $Properties[$i+1] -Force
}

# Invoke the build
$private:InvokeBuild = Join-Path (Get-PackageDir "Invoke-Build") "tools\Invoke-Build.ps1"
$private:BuildScript = Join-Path $BuildFullPath "build.ps1"
if ($Tree) {
    # Visualize task trees
    Write-BuildMessage -Message "Show build tree" -ForegroundColor "Cyan"
    Import-Script Show-BuildTree
    Show-BuildTree -InvokeBuild "$InvokeBuild" -File "$BuildScript" -Task $Task
} else {
    & "$InvokeBuild" -File "$BuildScript" -Task $Task -Result $Result -Safe:$Safe -Summary:$Summary
    if($Result -and $Result -is [string]) {
        Set-Variable -Name "$Result" -Value (Get-Variable -Name $Result).Value -Force -Scope 1
    }
}
