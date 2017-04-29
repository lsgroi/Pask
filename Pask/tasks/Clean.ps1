# Synopsis: Delete all intermediate and build output files
Task Clean {
    if (Test-Path $BuildOutputFullPath) {
        Write-BuildMessage "Cleaning '$BuildOutputFullPath'"
        Remove-ItemSilently (Join-Path $BuildOutputFullPath "*")
    }
    
    Write-BuildMessage "Cleaning '$PaskFullPath'"
    (@(Get-ChildItem -Directory -Path $PaskFullPath -Recurse -Filter bin) + @(Get-ChildItem -Directory -Path $PaskFullPath -Recurse -Filter obj)) `
        | Sort -Descending @{Expression = {$_.FullName.Length}} `
        | Select -ExpandProperty FullName `
        | Remove-ItemSilently
}
