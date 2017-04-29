<#
.SYNOPSIS 
   Gets the project/solution file to build

.OUTPUTS <string>
   The full name
#>
function script:Get-MSBuildProjectFile {
    if ($BuildProjectOnly -and $BuildProjectOnly -eq $true) {
        return $ProjectFullName
    } else {
        return $SolutionFullName
    }
}

<#
.SYNOPSIS 
   Gets the Platform property override

.OUTPUTS <string>
   The MSBuild property parameter
#>
function script:Get-MSBuildPlatformProperty {
    if($BuildPlatform) { 
        return "/p:Platform=""$BuildPlatform"""
    }
}
