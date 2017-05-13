# Synopsis: Delete all intermediate and build output files
Task Clean {
    if (Test-Path $BuildOutputFullPath) {
        Write-BuildMessage "Cleaning '$BuildOutputFullPath'"
        Clear-Directory $BuildOutputFullPath
    }
    
    Write-BuildMessage "Cleaning '$SolutionName' solution projects"
    $SolutionProjects = Get-SolutionProjects | Select -ExpandProperty Directory
    @($SolutionProjects | % { Join-Path $_ "bin" }) + @($SolutionProjects | % { Join-Path $_ "obj" }) `
        | Remove-PaskItem
}
