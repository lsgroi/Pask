# Synopsis: Test manually the package installation
Task Test-PackageInstallation Clean, Pack-Nuspec, Push-Local, {
    # Arrange
        $SolutionName = "Application"    
        $SolutionFullPath = Join-Path $Env:Temp ([guid]::NewGuid())
        $SolutionFullName = Join-Path $SolutionFullPath "$SolutionName.sln"
        Write-Host "Loading Visual Studio 2015 ..."
        $DTE = New-Object -ComObject "VisualStudio.DTE.14.0"
 
        try {
            New-Solution ([ref]$DTE) "$SolutionFullPath" $SolutionName
            Write-Host "Manual steps:"
            Write-Host "  1 Install the package in Visual Studio via NuGet Package Manager"
            Write-Host "    - Select the " -NoNewline; Write-Host "Local" -ForegroundColor Yellow -NoNewline; Write-Host " NuGet feed"
            Write-Host "    - Search " -NoNewline; Write-Host "Pask" -ForegroundColor Yellow -NoNewline; Write-Host " package"
            Write-Host "    - Install in all projects"
            Write-Host "  2 Continue for validation"

    # Act
            Write-Host "Press 'C' to continue ..."
	        do { $Key = [Console]::ReadKey($true).Key } until ($Key -eq "C")
            $DTE.Solution.SaveAs($SolutionFullName)
    # Assert    
            $BuildProject = $DTE.Solution.Projects | Where { $_.Name -eq ".build" }
            Assert ($BuildProject) "Cannot find solution folder '.build'"
            Assert ($BuildProject.ProjectItems | Where { $_.Name -eq "build.ps1" }) "Cannot find build script 'build.ps1'"
            Assert ($BuildProject.ProjectItems | Where { $_.Name -eq "tasks" }) "Cannot find solution folder 'tasks'"
            Assert ($BuildProject.ProjectItems | Where { $_.Name -eq "scripts" }) "Cannot find solution folder 'scripts'"
            Assert (Test-Path (Join-Path $SolutionFullPath "Pask.ps1")) "Cannot find Pask build runner"
            Assert (Test-Path (Join-Path $SolutionFullPath ".build\scripts\Pask.ps1")) "Cannot find Pask build script"
            Assert (Test-Path (Join-Path $SolutionFullPath ".build\tasks")) "Cannot find 'tasks' directory"
            Assert (Test-Path (Join-Path $SolutionFullPath ".build\.gitignore")) "Cannot find .gitignore'"
            Assert (Test-Path (Join-Path $SolutionFullPath "go.bat")) "Cannot find go.bat'"
            Write-Host " [+] package installation succeeded" -ForegroundColor Green
        } catch {
            $dte.Quit()
            throw
        }
    
    # Teardown
        $dte.Quit()
}