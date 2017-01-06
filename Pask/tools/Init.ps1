# This script runs:
# - the first time a package is installed in a solution
# - every time the solution is opened (Package Manager Console window has to be open at the same time for the script to run)

param($InstallPath, $ToolsPath, $Package, $Project)

if ($Project -eq $null) {
    # Solution level packages are not supported in Visual Studio 2015
    return
}

function Add-FileToSolution {	
	param($ProjectItems, [string]$Source, [string]$Destination)

	$FileName = Split-Path -Path $Destination -Leaf
	
	if (-not (Test-Path $Destination)) {
		Write-Host "Copying '$FileName'."
		Copy-Item $Source $Destination | Out-Null
	}

	if($($ProjectItems.GetEnumerator() | Where { $_.FileNames(1) -eq $destination }) -eq $null) {
		Write-Host "Adding to the solution '$FileName'."
		$BuildProjectItems.AddFromFile($Destination) | Out-Null
	}
}

function Remove-ProjectItem {
	param($ProjectItem)

	if($ProjectItem -ne $null) {
		Write-Host "Removing from the solution '$($ProjectItem.Name)'."
		$ProjectItem.Delete() | Out-Null
	}
}

$Solution = Get-Interface $dte.Solution ([EnvDTE80.Solution2])
$SolutionFullPath = Split-Path -Path $Solution.FullName

$PackagesConfig = Join-Path (Split-Path -Path $Project.FullName) "packages.config"
[xml]$PackagesXml = Get-Content $PackagesConfig
$Package = $PackagesXml.packages.package | Where { $_.id -eq $Package.Id -and $_.version -eq $Package.Version };

# To prevent NuGet Package Manager from running this for every version of the package that happens to be in the packages folder
if ($Package -ne $null) {
    Write-Host "Initializing '$($Package.Id) $($Package.Version)'."

    . (Join-Path $InstallPath "scripts\$($Package.Id).ps1")

	$SolutionName = ($Solution.Properties | Where { $_.Name -eq "Name" }).Value
	$BuildSolutionFolder = $Solution.Projects | Where { $_.Name -eq ".build" }
	$BuildFullPath = Join-Path $SolutionFullPath ".build"

	# Add '.build' solution folder if it does not already exist
	if ($BuildSolutionFolder -eq $null) {
        $BuildSolutionFolder = $Solution.AddSolutionFolder(".build")
        $BuildSolutionFolder.Object.AddSolutionFolder("tasks") | Out-Null
        $BuildSolutionFolder.Object.AddSolutionFolder("scripts") | Out-Null
	}

	# Remove NuGet.exe from the solution
	$NuGetSolutionFolder = $solution.Projects | Where { $_.Name -eq ".nuget" }
	if ($NuGetSolutionFolder -ne $null) {
		Remove-ProjectItem ($NuGetSolutionFolder.ProjectItems | Where { $_.Name -eq "NuGet.exe" })
	}

    # Change NuGet.targets to download NuGet.exe if it does not already exist
	$NuGetTargetsFile = Join-Path (Join-Path $SolutionFullPath ".nuget") "NuGet.targets"
	if (Test-Path $NuGetTargetsFile) {
        [xml]$NuGetTargets = New-Object System.Xml.XmlDocument
        $NuGetTargets.PreserveWhitespace = $true
		$NuGetTargets.Load($NuGetTargetsFile)
		$NuGetTargets.Project.PropertyGroup[0].DownloadNuGetExe.InnerText = "true"
		$NuGetTargets.Save($NuGetTargetsFile)
	}
    
    $BuildProjectItems = Get-Interface $BuildSolutionFolder.ProjectItems ([EnvDTE.ProjectItems])
    
    # Creating .build directory
    $BuildFullPath = Join-Path $SolutionFullPath ".build"
    if (-not (Test-Path $BuildFullPath)) {
        Write-Host "Creating '.build'."
        New-Directory $BuildFullPath | Out-Null
    }
    
    # Add .build\.gitignore
    $GitIgnore = Join-Path $BuildFullPath ".gitignore"
    if(-not (Test-Path $GitIgnore)) {
        Write-Host "Creating '.build\.gitignore'."
        Copy-Item (Join-Path $InstallPath "init\.build\.gitignore") $GitIgnore -Force | Out-Null
    }

    # Add go.bat
    $GoBat = Join-Path $SolutionFullPath "go.bat"
    if (-not (Test-Path $GoBat)) {
        Write-Host "Creating 'go.bat'."
        Copy-Item (Join-Path $InstallPath "init\go.bat") $GoBat -Force | Out-Null
    }

    # Add build scripts
    New-Directory (Join-Path $SolutionFullPath ".build\scripts") | Out-Null
    Write-Host "Copying $($Package.Id) build runner."
    Copy-Item (Join-Path $InstallPath "init\$($Package.Id).ps1") (Join-Path $SolutionFullPath "$($Package.Id).ps1") -Force | Out-Null
    Write-Host "Copying $($Package.Id) build script."
    Copy-Item (Join-Path $InstallPath "scripts\$($Package.Id).ps1") (Join-Path $SolutionFullPath ".build\scripts\$($Package.Id).ps1") -Force | Out-Null
    
    # Add solution build scripts
    Add-FileToSolution $BuildProjectItems (Join-Path $InstallPath "init\.build\build.ps1") (Join-Path $SolutionFullPath ".build\build.ps1")

    $Solution.SaveAs($Solution.FullName)

    # Open the readme.txt
    $Window = $dte.ItemOperations.OpenFile($(Join-Path $InstallPath "readme.txt"))
}