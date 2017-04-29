Import-Script Properties.MSBuild, Properties.WebApplication, Pask.MSBuild -Package Pask

# Synopsis: Build the solution in which the default project is a web application
Task Build-WebApplication {
    Use $MSBuildVersion MSBuild
    $Project = Get-MSBuildProjectFile
    $Platform = Get-MSBuildPlatformProperty

    "Building '{0}'`r`n" -f (Split-Path -Path $Project -Leaf)
    Exec { MSBuild "$Project" /t:Build /p:Configuration=$BuildConfiguration $Platform /p:WebProjectOutputDir="$WebApplicationOutputPath" /p:OutDir=".\bin\" /p:OutputPath="bin\$BuildConfiguration\" /Verbosity:$MSBuildVerbosity }
}