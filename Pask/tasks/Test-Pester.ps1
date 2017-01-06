Set-Property TestName -Default ""

# Synopsis: Run PowerShell tests found in *.Tests.ps1 files
Task Test-Pester {
    # Import Pester module
    $PesterModule = Join-Path (Get-PackageDir "Pester") "tools\Pester.psm1"
    Import-Module -Name "$PesterModule" -Scope Local

    # Initialize test results directory
    New-Directory $TestsResultsFullPath | Out-Null
    
    # Run tests found in the scripts and tasks directories
    # Include the current solution
    $Path = @(
        (Join-Path (Join-Path $BuildFullPath "scripts") "*"),
        (Join-Path (Join-Path $BuildFullPath "tasks") "*")
    )
    # Include each Pask.* project in the solution
    foreach ($Project in (Get-SolutionProjects | Where { $_.Name -match "^Pask.*" })) {
        $Path += (Join-Path (Join-Path $Project.Directory "scripts") "*")
        $Path += (Join-Path (Join-Path $Project.Directory "tasks") "*")
    }
    
    # Define Pester parameters
    $Script = Get-ChildItem -Path $Path -File -Include *.Tests.ps1 -ErrorAction SilentlyContinue
    $OutputFile = Join-Path $TestsResultsFullPath "Pester.xml"
    
    # Invoke Perster
    $PesterResult = Invoke-Pester -Script $Script -Strict -PassThru -OutputFile "$OutputFile" -OutputFormat NUnitXml -TestName $TestName
    
    # Remove Pester module
    Remove-Module -Name Pester
    
    # Assert no failures
    Assert ($PesterResult.FailedCount -eq 0 -and $PesterResult.SkippedCount -eq 0 -and $PesterResult.PendingCount -eq 0) "Pester tests failed"
}