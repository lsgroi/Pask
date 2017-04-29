Import-Script Properties.MSBuild, Properties.WebApplication, Pask.MSBuild -Package Pask

# Synopsis: Build the solution in which the default project is a web application and the output should be a web deployment package
Task Build-WebDeployPackage {
    Use $MSBuildVersion MSBuild
    $Project = Get-MSBuildProjectFile
    $Platform = Get-MSBuildPlatformProperty

    "Building '{0}'`r`n" -f (Split-Path -Path $Project -Leaf)
    Exec { MSBuild "$Project" /t:Build /p:Configuration=$BuildConfiguration $Platform /p:PackageLocation="$WebApplicationOutputPath" /p:_DestinationType=AzureWebSite /p:DeployOnBuild=true /p:WebPublishMethod=Package /p:PackageAsSingleFile=true /p:SkipInvalidConfigurations=true /Verbosity:$MSBuildVerbosity }
}