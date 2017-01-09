# Synopsis: Delete all intermediate and build output files
Task Clean {
    Import-Properties -Project Pask

    if (Test-Path $BuildOutputFullPath) {
        Write-BuildMessage "Cleaning '$BuildOutputFullPath'"
        Remove-ItemSilently (Join-Path $BuildOutputFullPath "*")
    }
    
    Write-BuildMessage "Cleaning '$SolutionFullPath'"
    Get-ChildItem -Directory -Path (Join-Path $SolutionFullPath "**\bin"), (Join-Path $SolutionFullPath "**\obj") `
        | Sort -Descending @{Expression = {$_.FullName.Length}} `
        | Select -ExpandProperty FullName `
        | ForEach {
            Remove-ItemSilently (Join-Path $_ "*")
            CMD /C "RD /S /Q ""$($_)""" 
        }
}
