# Synopsis: Build the solution using MSBuild
Task Build {
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
    Exec { MSBuild "$Project" /t:Build /p:Configuration=$Configuration $MSBuildPlatform /Verbosity:quiet }
}