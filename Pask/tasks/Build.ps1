Import-Script Properties.MSBuild, Pask.MSBuild -Package Pask

# Synopsis: Build the solution using MSBuild
Task Build {
    Use $MSBuildVersion MSBuild
    $Project = Get-MSBuildProjectFile
    $Platform = Get-MSBuildPlatformProperty

    "Building '{0}'`r`n" -f (Split-Path -Path $Project -Leaf)
    Exec { MSBuild "$Project" /t:Build /p:Configuration=$BuildConfiguration $Platform /Verbosity:$MSBuildVerbosity }
}