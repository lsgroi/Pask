<#
.SYNOPSIS 
    Removes a build property

.PARAMETER NAme <string>
    The build property's name

.OUTPUTS
    None
#>
function script:Remove-BuildProperty {
    param([Parameter(Mandatory=$true)][string[]]$Name)

    $Name | ForEach { 
        Remove-Variable -Name $_ -Scope Script -Force
        ${!BuildProperties!}.Remove($_)
        ${script:!BuildProperties!} = ${!BuildProperties!}
    }
}

<#
.SYNOPSIS 
    Marks a file as imported

.PARAMETER FullName <string>
    The file full name

.OUTPUTS
    None
#>
function script:Add-File {
    param([Parameter(Mandatory=$true)][string[]]$FullName)

    $FullName | ForEach { 
        ${!Files!}.Add($_)
        ${script:!Files!} = ${!Files!}
    }
}

<#
.SYNOPSIS 
    Removes an imported file

.PARAMETER FullName <string>
    The file full name

.OUTPUTS
    None
#>
function script:Remove-File {
    param(
        [Parameter(Mandatory=$true)]
        [ValidateScript({ @( $_ | Where { [System.IO.Path]::IsPathRooted($_) -and $_ -match ".*\.(ps1)$" -and (Test-Path $_) } ).Count })]
        [string[]]$FullName
    )

    $FullName | ForEach { 
        ${!Files!}.Remove($_)
        ${script:!Files!} = ${!Files!}
    }
}

# Copy the files installed automatically by Pask into a given solution
function script:Copy-PaskFiles {
    param([parameter(ValueFromPipeline)][string]$TestSolutionFullPath)

    Exec { Robocopy "$(Join-Path $BuildFullPath "scripts")" "$(Join-Path $TestSolutionFullPath ".build\scripts")" "Pask.ps1" /256 /XO /NP /NFL /NDL /NJH /NJS } (0..7)
    Exec { Robocopy "$SolutionFullPath" "$TestSolutionFullPath" "Pask.ps1" /256 /XO /NP /NFL /NDL /NJH /NJS } (0..7)
    Exec { Robocopy "$(Join-Path $SolutionFullPath ".nuget")" "$(Join-Path $TestSolutionFullPath ".nuget")" "NuGet.exe" /256 /XO /NP /NFL /NDL /NJH /NJS } (0..7)
}