Import-Properties -Package Pask

# Array of AssemblyInfo files to exclude (relative path from solution's directory)
Set-Property ExcludeAssemblyInfo -Default @()

# Synopsis: Version all the assemblies in the solution
Task Version-Assemblies {
    # Regular expression patterns to find version information for an assembly
    $AssemblyVersionRegex = 'AssemblyVersion\s*\(\s*\"(.+)?"\s*\)'
    $AssemblyFileVersionRegex = 'AssemblyFileVersion\s*\(\s*\"(.+)?"\s*\)'
    $AssemblyInformationalVersionRegex = 'AssemblyInformationalVersion\s*\(\s*\"(.+)?"\s*\)'

    # Version information override for an assembly
    $AssemblyVersion = "AssemblyVersion(""{0}.0.0.0"")" -f $Version.Major
    $AssemblyFileVersion = "AssemblyFileVersion(""{0}"")" -f $Version.AssemblySemVer
    $AssemblyInformationalVersion = "AssemblyInformationalVersion(""{0}"")" -f $Version.InformationalVersion

    # Limit the search of AssemblyInfo files to project folder depth 2
    $Files = Get-SolutionProjects `
    | foreach { Get-ChildItem -Path (Join-Path $_.Directory "*\*\*"),(Join-Path $_.Directory "*\*"),(Join-Path $_.Directory "*") `
    | Where { $_.Name -match "AssemblyInfo.cs" } }

    if ($Files) {
        "Apply {0} to {1} AssemblyInfo files" -f $Version.InformationalVersion, $Files.Count

        foreach ($File in $Files) {
            if (-not ($ExcludeAssemblyInfo | Where { $File.FullName.EndsWith($_) })) {
                $FileContent = [IO.File]::ReadAllText($File.FullName)
                attrib $File.FullName -r # Clears the read-only file attribute
                $FileContent -replace $AssemblyVersionRegex, $AssemblyVersion `
                    -replace $AssemblyFileVersionRegex, $AssemblyFileVersion `
                    -replace $AssemblyInformationalVersionRegex, $AssemblyInformationalVersion `
                    | % { [IO.File]::WriteAllText($File.FullName, $_) }
            }
        }
    } else {
        Write-BuildMessage -Message "Found no AssemblyInfo files" -ForegroundColor "Yellow"
    }
}