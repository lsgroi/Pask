Set-Property Version -Default (Get-Version)

# Test-Pester task
Set-Property TestName -Default ""

# Push-Local task
Set-Property LocalNuGetFeed -Default "C:\LocalNuGetFeed"

# MSBuild tasks
Set-Property BuildProjectOnly -Default $false
Set-Property BuildConfiguration -Default "Debug"
Set-Property MSBuildVersion -Default "14.0"
Set-Property BuildPlatform -Default ""

# New-Artifact task
Set-Property RemoveArtifactPDB -Default $true

# MSBuild and New-Artifact tasks
Set-Property WebApplicationOutputPath -Default "obj/WebOut"

# Extract-Artifact task
# Array of specific file names to extract only (e.g. MyAssembly.dll)
Set-Property FileNameToExtract -Default @()

# Version-Assemblies task
# Array of AssemblyInfo files to exclude (relative path from solution's directory)
Set-Property ExcludeAssemblyInfo -Default @()