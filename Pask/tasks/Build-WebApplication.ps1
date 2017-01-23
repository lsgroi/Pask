# Synopsis: Build the solution in which the default project is a web application
Task Build-WebApplication {
    Import-Properties -Package Pask

    Use $MSBuildVersion MSBuild

    # Select the project to build
    if ($BuildProjectOnly -eq $true) {
        $Project = $ProjectFullName
    } else {
        $Project = $SolutionFullName
    }

    if($Platform) { 
        $MSBuildPlatform = "/p:Platform=""$Platform""" 
    }

    "Building '$(Split-Path -Path $Project -Leaf)'`r`n"
    Exec { MSBuild "$Project" /t:Build /p:Configuration=$Configuration $MSBuildPlatform /p:WebProjectOutputDir="$WebApplicationOutputPath" /p:OutDir=".\bin\" /p:OutputPath="bin\$Configuration\" /Verbosity:quiet }
}