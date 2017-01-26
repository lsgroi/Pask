# Synopsis: Create an artifact in the form of ZIP archive
Task Zip-Artifact {
    Import-Properties -Package Pask

    Assert ($ArtifactFullPath -and (Test-Path $ArtifactFullPath)) "Cannot not find artifact directory '$ArtifactFullPath'"

    $7za = Join-Path (Get-PackageDir "7-Zip.CommandLine") "tools\7za.exe"
	
    $ZipFile = "$ArtifactFullPath.$($Version.InformationalVersion).zip"
	
    "Creating archive $ZipFile"
    Exec { & "$7za" u -tzip "$ZipFile" "-ir!$(Join-Path "$ArtifactFullPath" "*")" -mx9 | Out-Null }
}