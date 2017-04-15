Import-Script Properties.MSBuild, Properties.WebApplication -Package Pask

# Synopsis: Build the solution in which the default project is a web application
Task Build-WebApplication {
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

    "Building '{0}'`r`n" -f (Split-Path -Path $Project -Leaf)
    Exec { MSBuild "$Project" /t:Build /p:Configuration=$BuildConfiguration $MSBuildPlatform /p:WebProjectOutputDir="$WebApplicationOutputPath" /p:OutDir=".\bin\" /p:OutputPath="bin\$BuildConfiguration\" /Verbosity:quiet }
}