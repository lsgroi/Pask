# Array of AssemblyInfo files to exclude (relative path from solution's directory)
Set-Property ExcludeAssemblyInfo -Default @()

# Synopsis: Version all the assemblies in the solution
Task Version-Assemblies {
    Import-Properties -Package Pask

    # Regular expression patterns to find version information for an assembly
    $AssemblyVersionRegex = 'AssemblyVersion\s*\(\s*\"(.+)?"\s*\)'
    $AssemblyFileVersionRegex = 'AssemblyFileVersion\s*\(\s*\"(.+)?"\s*\)'
    $AssemblyInformationalVersionRegex = 'AssemblyInformationalVersion\s*\(\s*\"(.+)?"\s*\)'

    # Version information override for an assembly
    $AssemblyVersion = "AssemblyVersion(""$($Version.Major).0.0.0"")"
    $AssemblyFileVersion = "AssemblyFileVersion(""$($Version.AssemblySemVer)"")"
    $AssemblyInformationalVersion = "AssemblyInformationalVersion(""$($Version.InformationalVersion)"")"

    # Limit the search of AssemblyInfo files to project folder depth 2
    $Files = Get-SolutionProjects `
    | foreach { Get-ChildItem -Path (Join-Path $_.Directory "*\*\*"),(Join-Path $_.Directory "*\*"),(Join-Path $_.Directory "*") `
    | Where { $_.Name -match "AssemblyInfo.cs" } }

    if ($Files) {
        "Apply $($Version.InformationalVersion) to $($Files.count) AssemblyInfo files"

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