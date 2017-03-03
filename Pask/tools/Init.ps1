# This script runs:
# - the first time a package is installed in a solution
# - every time the solution is opened (Package Manager Console window has to be open at the same time for the script to run)

param($InstallPath, $ToolsPath, $Package, $Project)

if ($Project -eq $null) {
    # Solution level packages are not supported in Visual Studio 2015
    return
}

<#
.SYNOPSIS 
   Copies a file

.PARAMETER Source <string>
   Full name of the source file

.PARAMETER Destination <string>
   Full name of the destination file

.OUTPUTS
   None
#>
function Copy-File {
	param([string]$Source, [string]$Destination)

	$FileName = Split-Path -Path $Destination -Leaf
	
	if (-not (Test-Path $Destination)) {
		Write-Host "Copying '$FileName'."
		Copy-Item $Source $Destination | Out-Null
	}
}

<#
.SYNOPSIS 
   Adds a file to a solution folder

.PARAMETER File <string>
   Full name of the file

.PARAMETER $SolutionFolder <EnvDTE.Project>
   A solution folder

.OUTPUTS
   None
#>
function Add-FileToSolutionFolder {	
	param([string]$File, $SolutionFolder)

	$FileName = Split-Path -Path $File -Leaf
	$ProjectItems = Get-Interface $SolutionFolder.ProjectItems ([EnvDTE.ProjectItems])

	if($ProjectItems -and $($ProjectItems.GetEnumerator() | Where { $_.FileNames(1) -eq $File }) -eq $null) {
		Write-Host "Adding '$FileName' to solution folder '$($SolutionFolder.Name)'."
		$ProjectItems.AddFromFile($File) | Out-Null
	}
}

<#
.SYNOPSIS 
   Adds a solution folder, if it does not already exist, to a solution or a solution folder

.PARAMETER $Name <string>
   The solution folder name

.PARAMETER Solution <EnvDTE80.Solution2>
   A solution

.PARAMETER SolutionFolder <EnvDTE80.SolutionFolder>
   A solution folder

.OUTPUTS <EnvDTE.Project>
   The solution folder
#>
function Add-SolutionFolder {	
	param(
        [Parameter(Position=0)] 
        [string]$Name,

        [Parameter(ParameterSetName="Solution",Position=1)]
        $Solution,

        [Parameter(ParameterSetName="SolutionFolder",Position=1)]
        $SolutionFolder
    )

    switch ($PsCmdlet.ParameterSetName) {
        "Solution" {
            $NewSolutionFolder = $Solution.Projects | Where { $_.Name -eq $Name }

            if ($NewSolutionFolder -eq $null) {
                Write-Host "Adding solution folder '$Name'."
                $NewSolutionFolder = $Solution.AddSolutionFolder($Name)
            }

            return $NewSolutionFolder
        }
        "SolutionFolder" {
            $NewSolutionFolder = $SolutionFolder.ProjectItems | Where { $_.Name -eq $Name }

            if ($NewSolutionFolder -eq $null) {
                Write-Host "Adding solution folder '$($SolutionFolder.Name)\$Name'."
                $NewSolutionFolder = $SolutionFolder.Object.AddSolutionFolder($Name)
            }

            return $NewSolutionFolder
        }
        default {
            return $null
        }
    }
}


<#
.SYNOPSIS 
   Removes a project item from the solution

.PARAMETER $ProjectItems <EnvDTE.ProjectItem>
   The project item

.OUTPUTS
   None
#>
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
    $NuGetSolutionFolder = $Solution.Projects | Where { $_.Name -eq ".nuget" }
	$BuildFullPath = Join-Path $SolutionFullPath ".build"

	# Add '.build' solution folder
    $BuildSolutionFolder = Add-SolutionFolder ".build" -Solution $Solution
    Add-SolutionFolder "tasks" -SolutionFolder $BuildSolutionFolder | Out-Null
    Add-SolutionFolder "scripts" -SolutionFolder $BuildSolutionFolder | Out-Null
        
    if ($NuGetSolutionFolder -ne $null) {
        # Remove NuGet.exe from the solution
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
        $NuGetSolutionFolder = Add-SolutionFolder ".nuget" -Solution $Solution
        Add-FileToSolutionFolder $NuGetTargetsFile $NuGetSolutionFolder
	}
    
    # Add Nuget.config to the solution
	$NuGetConfigFile = Join-Path (Join-Path $SolutionFullPath ".nuget") "NuGet.config"
	if (Test-Path $NuGetConfigFile) {
        # Inside the '.nuget' directory
        $NuGetSolutionFolder = Add-SolutionFolder ".nuget" -Solution $Solution
        Add-FileToSolutionFolder $NuGetConfigFile $NuGetSolutionFolder
	} else {
        # In the solution directory
        $NuGetConfigFile = Join-Path $SolutionFullPath "NuGet.config"
        if (Test-Path $NuGetConfigFile) {
            $NuGetSolutionFolder = Add-SolutionFolder ".nuget" -Solution $Solution
            Add-FileToSolutionFolder $NuGetConfigFile $NuGetSolutionFolder
	    }
    }
   
    # Creating .build directory
    $BuildFullPath = Join-Path $SolutionFullPath ".build"
    if (-not (Test-Path $BuildFullPath)) {
        Write-Host "Creating '.build' direcotry."
        New-Directory $BuildFullPath | Out-Null
    }
    
    # Creating tasks directory
    $TasksFullPath = Join-Path $BuildFullPath "tasks"
    if (-not (Test-Path $TasksFullPath)) {
        Write-Host "Creating '.build\tasks' directory."
        New-Directory $TasksFullPath | Out-Null
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
    Copy-File (Join-Path $InstallPath "init\.build\build.ps1") (Join-Path $SolutionFullPath ".build\build.ps1")
    Add-FileToSolutionFolder (Join-Path $SolutionFullPath ".build\build.ps1") $BuildSolutionFolder

    $Solution.SaveAs($Solution.FullName)

    # Open the readme.txt
    $Window = $dte.ItemOperations.OpenFile($(Join-Path $InstallPath "readme.txt"))
}