Import-Script Pask.Tests.Infrastructure
Import-Task Clean, Version-BuildServer, Test-Pester, Test-PackageInstallation, SimultaneousTask1, SimultaneousTask2

# Synopsis: Default task; pack, test and push locally
Task . Clean, Pack-Nuspec, Test, Push-Local

# Synopsis: Run all automated tests
Task Test Pack-Nuspec, Test-Pester

# Synopsis: Test a release
Task PreRelease Version-BuildServer, Clean, Pack-Nuspec, Test

# Synopsis: Release the package
Task Release Version-BuildServer, Clean, Pack-Nuspec, Test, Push

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

    Set-Property NuGetApiKey
    
    # Starting with NuGet 3.4.2, the push source is a mandatory parameter
    $NuGet = Get-NuGetExe
    try {
        Push-Location -Path (Split-Path $NuGet)
        $NuGetDefaultPushSource = Invoke-Command -ScriptBlock { & $NuGet config DefaultPushSource 2>$1 }
    } catch {
    } finally {
        Pop-Location
        $NuGetDefaultPushSource = $PSCmdlet.GetVariableValue("private:NuGetDefaultPushSource", "https://www.nuget.org/api/v2/package")
        Set-Property NuGetPushSource -Default $NuGetDefaultPushSource
    }

	$Packages = Get-ChildItem -Path "$(Join-Path "$BuildOutputFullPath" "*")" -Include *.nupkg

    Exec { Push-Package -Packages $Packages -ApiKey "$NuGetApiKey" -Source "$NuGetPushSource" }
}

# Synopsis: Push the NuGet package(s) to a local NuGet feed
Task Push-Local {
    Import-Properties -Project Pask
    Import-Script Pask.Utilities
    
    $Packages = Get-ChildItem (Join-Path $BuildOutputFullPath "*") -Include *.nupkg

	New-Directory $LocalNuGetSource | Out-Null

	Exec { Push-Package -Packages $Packages -Source "$LocalNuGetSource" }
}