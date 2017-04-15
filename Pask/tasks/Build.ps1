Import-Script Properties.MSBuild -Package Pask

# Synopsis: Build the solution using MSBuild
Task Build {
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
    Exec { MSBuild "$Project" /t:Build /p:Configuration=$BuildConfiguration $MSBuildPlatform /Verbosity:quiet }
}