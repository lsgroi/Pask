Import-Script Pask.Tests.Infrastructure
Set-Property GitHubOwner -Value "lsgroi"
Set-Property GitHubRepo -Value $ProjectName
Import-Task Clean, Pack-Nuspec, Test-Pester, Push-Local, Push, Version-BuildServer, Test-PackageInstallation, New-GitHubRelease

Enter-Build {
    # Before the first task in the script scope, remove any Pask package fro mthe pacakges directory,
    # mainly to clean up unecessary dependencies of Pask.NuGet
    Get-ChildItem (Get-PackagesDir) | Where { $_.Name -match 'Pask.[\d]' } | Select -ExpandProperty FullName | Remove-PaskItem
}

# Synopsis: Default task; pack, test and push locally
Task . Clean, Pack-Nuspec, Test, Push-Local

# Synopsis: Run all automated tests
Task Test Pack-Nuspec, Test-Pester

# Synopsis: Test a release
Task PreRelease Version-BuildServer, Clean, Pack-Nuspec, Test

# Synopsis: Release the package
Task Release Version-BuildServer, Clean, Pack-Nuspec, Test, Push, New-GitHubRelease