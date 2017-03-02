# Synopsis: Delete all intermediate and build output files
Task Clean {
    if (Test-Path $BuildOutputFullPath) {
        Write-BuildMessage "Cleaning '$BuildOutputFullPath'"
        Remove-ItemSilently (Join-Path $BuildOutputFullPath "*")
    }
    
    Write-BuildMessage "Cleaning '$PaskFullPath'"
    Get-ChildItem -Directory -Path (Join-Path $PaskFullPath "**\bin"), (Join-Path $PaskFullPath "**\obj") `
        | Sort -Descending @{Expression = {$_.FullName.Length}} `
        | Select -ExpandProperty FullName `
        | ForEach {
            Remove-ItemSilently (Join-Path $_ "*")
            CMD /C "RD /S /Q ""$($_)""" 
        }
}
