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
    # Pask specific parameters
    [string]$SolutionFilePath,
    [string]$SolutionName,
    [string]$ProjectName,
    [switch]$Tree,

    # Invoke-Build specific parameters
    [Alias("Task")][Parameter(Position=0)][string[]]$private:PaskTask = ".",
    [Alias("Result")]$private:PaskResult,
    [Alias("Safe")][switch]$private:PaskSafe,
    [Alias("Summary")][switch]$private:PaskSummary = $true,
    [Parameter(ValueFromRemainingArguments=$true)]$Properties
)

$ErrorActionPreference = "Stop"
$private:OriginalLocation = Get-Location
$private:ScriptFullPath = if ($PSScriptRoot -ne $null) { $PSScriptRoot } else { Split-Path $MyInvocation.MyCommand.Path -Parent }

# Default parameters
if (-not $SolutionName) {
    $SolutionName = (Get-ChildItem -Path (Join-Path $ScriptFullPath $SolutionFilePath) *.sln | Sort-Object -Descending | Select-Object -First 1).BaseName
}
if (-not $ProjectName) {
    $ProjectName = $SolutionName
}

# Include Pask script
. (Join-Path $ScriptFullPath ".build\scripts\Pask.ps1")

# Expose properties passed to the script
for ($i=0; $i -lt $Properties.Count; $i+=2) {
    Set-BuildProperty -Name ($Properties[$i] -replace '^-+') -Value $Properties[$i+1]
}

# Set default properties
Set-BuildProperty -Name PaskFullPath -Value $ScriptFullPath
Set-BuildProperty -Name SolutionName -Value $SolutionName
Set-BuildProperty -Name SolutionFullPath -Value (Join-Path $PaskFullPath $SolutionFilePath)
Set-BuildProperty -Name SolutionFullName -Value (Join-Path $SolutionFullPath "$SolutionName.sln")
Set-BuildProperty -Name BuildFullPath -Value (Join-Path $PaskFullPath ".build")
Set-BuildProperty -Name BuildOutputFullPath -Value (Join-Path $BuildFullPath "output")
Set-BuildProperty -Name TestResultsFullPath -Value (Join-Path $BuildOutputFullPath "TestResults")

# Test solution existence
if(-not (Test-Path $SolutionFullName)) { Write-Error "Cannot find '$SolutionName' solution in '$SolutionFullPath'" }

# Restore NuGet packages marked as development-only-dependency
Write-BuildMessage "Restore NuGet development dependencies" -ForegroundColor "Cyan"
Restore-NuGetDevelopmentPackages

# Create the build script
$private:BuildScript = New-Item -ItemType File -Name "$([System.IO.Path]::GetRandomFileName()).ps1" -Path $Env:Temp -Value {
    Import-Script Init -Safe
    Import-Properties -All
    . (Join-Path $BuildFullPath "build.ps1")
}

# Dot source Invoke-Build
. (Join-Path (Get-PackageDir "Invoke-Build") "tools\Invoke-Build.ps1")

try {
    # Define the default project
    Set-Project -Name $ProjectName

    # Invoke the build
    if ($Tree) {
        Write-BuildMessage "Show build task tree" -ForegroundColor "Cyan"
        Import-Script Show-BuildTree
        Show-BuildTree -File $BuildScript.FullName -Task $private:PaskTask
    } else {
        Invoke-Build -File $BuildScript.FullName -Task $private:PaskTask -Result "!InvokeBuildResult!" -Safe:$private:PaskSafe -Summary:$private:PaskSummary
        if ($private:PaskResult -and $private:PaskResult -is [string]) {
            New-Variable -Name $private:PaskResult -Force -Scope 1 -Value ${!InvokeBuildResult!}
        } elseif ($private:PaskResult) {
            $private:PaskResult.Value = ${!InvokeBuildResult!}
        }
    }
} catch {
    throw $_
} finally {
    Remove-Item $BuildScript.FullName -Force
    # By dot-sourcing Invoke-Build, the current location changes to $BuildRoot
    Set-Location -Path $private:OriginalLocation.Path
}