# This script runs:
# - the first time a package is installed in a solution
# - every time the solution is opened (Package Manager Console window has to be open at the same time for the script to run)

param($InstallPath, $ToolsPath, $Package, $Project)

if ($Project -eq $null) {
    # Solution level packages are not supported in Visual Studio 2015
    return
}

$Solution = Get-Interface $dte.Solution ([EnvDTE80.Solution2])
$SolutionFullPath = Split-Path -Path $Solution.FullName

$PackagesConfig = Join-Path (Split-Path -Path $Project.FullName) "packages.config"
[xml]$PackagesXml = Get-Content $PackagesConfig
$Package = $PackagesXml.packages.package | Where { $_.id -eq $Package.Id -and $_.version -eq $Package.Version };

# To prevent NuGet Package Manager from running this for every version of the package that happens to be in the packages folder
if ($Package -ne $null) {
    Write-Host "Initializing '$($Package.Id) $($Package.Version)'."

    # Code here any initialization

    # Open the readme.txt
    $Window = $dte.ItemOperations.OpenFile($(Join-Path $InstallPath "readme.txt"))
}