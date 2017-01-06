Import-Script Pask.Tests.Infrastructure
Import-Task Test-Pester, Test-PackageInstallation, SimultaneousTask1, SimultaneousTask2, Version-BuildServer

# Synopsis: Default task; pack, test and push locally
Task . Clean, Pack-Nuspec, Test, Push-Local

# Synopsis: Run all automated tests
Task Test Pack-Nuspec, Test-Pester

# Synopsis: Test a release
Task PreRelease Version-BuildServer, Clean, Pack-Nuspec, Test

# Synopsis: Release the package
Task Release Version-BuildServer, Clean, Pack-Nuspec, Test

# Synopsis: Delete all intermediate and build output files
Task Clean {
    Import-Properties -Project Pask

    if (Test-Path $BuildOutputFullPath) {
        Write-BuildMessage "Cleaning '$BuildOutputFullPath'"
        Remove-ItemSilently (Join-Path $BuildOutputFullPath "*")
    }
    
    Write-BuildMessage "Cleaning '$SolutionFullPath'"
    Get-ChildItem -Directory -Path (Join-Path $SolutionFullPath "**\bin"), (Join-Path $SolutionFullPath "**\obj") `
        | Sort -Descending @{Expression = {$_.FullName.Length}} `
        | Select -ExpandProperty FullName `
        | ForEach {
            Remove-ItemSilently (Join-Path $_ "*")
            CMD /C "RD /S /Q ""$($_)""" 
        }
}

# Synopsis: Create a NuGet package targeting a Nuspec
Task Pack-Nuspec {
    Import-Properties -Project Pask
    $IncludePdb = (property IncludePdb $false)

    New-Directory $BuildOutputFullPath | Out-Null

    # Set or not the symbols package flag
    $Symbols = @{$true="-Symbols";$false=""}[$CreateSymbolsPackage -eq $true]

    if ($CreateSymbolsPackage -eq $false -and $IncludePdb -eq $false) {
        # Exclude PDB files
        $Exclude = "-Exclude"
        $ExcludePattern = "**/*.pdb"
    } else {
        $Exclude = $ExcludePattern = ""
    }

    # Create the build output directory
    New-Directory $BuildOutputFullPath | Out-Null

    $Nuspec = "$(Join-Path "$ProjectFullPath" "$ProjectName").nuspec"
    "Packing $Nuspec"
	Exec { & (Get-NuGetExe) pack "$Nuspec" -BasePath "$ProjectFullPath" -NoDefaultExcludes -OutputDirectory "$BuildOutputFullPath" -Version $Version.SemVer -Properties "id=$ProjectName" $Symbols $Exclude $ExcludePattern }
}

# Synopsis: Push the NuGet package(s) to a remote source
Task Push {
    Import-Script Pask.Utilities

    $NuGetApiKey = (property NuGetApiKey "")
    $NuGetPushSource = (property NuGetPushSource "")

	$Packages = Get-ChildItem -Path "$(Join-Path "$BuildOutputFullPath" "*")" -Include *.nupkg

	if ($NuGetApiKey -and $NuGetPushSource) {
		Exec { Push-Package -Packages $Packages -ApiKey $NuGetApiKey -Source "$NuGetPushSource" }
	} elseif ($NuGetApiKey) {
		Exec { Push-Package -Packages $Packages -ApiKey $NuGetApiKey }
	} else {
        throw "Cannot Push without NuGetPushSource or NuGetApiKey"
    }
}

# Synopsis: Push the NuGet package(s) to a local NuGet feed
Task Push-Local {
    Import-Properties -Project Pask
    Import-Script Pask.Utilities
    
    $Packages = Get-ChildItem (Join-Path $BuildOutputFullPath "*") -Include *.nupkg

	New-Directory $LocalNuGetFeed | Out-Null

	Exec { Push-Package -Packages $Packages -Source "$LocalNuGetFeed" }
}