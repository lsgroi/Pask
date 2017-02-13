Import-Script Properties.MSBuild, Properties.WebApplication -Package Pask

# Synopsis: Build the solution in which the default project is a web application and the output should be a web deployment package
Task Build-WebDeployPackage {
    Import-Properties -Package Pask

    Use $MSBuildVersion MSBuild

    # Select the project to build
    if ($BuildProjectOnly -eq $true) {
        $Project = $ProjectFullName
    } else {
        $Project = $SolutionFullName
    }

    if($BuildPlatform) { 
        $MSBuildPlatform = "/p:Platform=""$BuildPlatform""" 
    }

    "Building '$(Split-Path -Path $Project -Leaf)'`r`n"
    Exec { MSBuild "$Project" /t:Build /p:Configuration=$BuildConfiguration $MSBuildPlatform /p:PackageLocation="$WebApplicationOutputPath" /p:_DestinationType=AzureWebSite /p:DeployOnBuild=true /p:WebPublishMethod=Package /p:PackageAsSingleFile=true /p:SkipInvalidConfigurations=true /Verbosity:quiet }
}