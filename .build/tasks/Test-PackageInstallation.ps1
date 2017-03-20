# Synopsis: Test manually the package installation
Task Test-PackageInstallation Clean, Pack-Nuspec, Push-Local, {
    $Assertion = {
        $BuildProject = $DTE.Solution.Projects | Where { $_.Name -eq ".build" }
        Assert ($BuildProject) "Cannot find solution folder '.build'"
        Assert ($BuildProject.ProjectItems | Where { $_.Name -eq "build.ps1" }) "Cannot find build script 'build.ps1'"
        Assert ($BuildProject.ProjectItems | Where { $_.Name -eq "tasks" }) "Cannot find solution folder 'tasks'"
        Assert ($BuildProject.ProjectItems | Where { $_.Name -eq "scripts" }) "Cannot find solution folder 'scripts'"
        Assert (Test-Path (Join-Path $SolutionFullPath "Pask.ps1")) "Cannot find Pask build runner"
        Assert (Test-Path (Join-Path $SolutionFullPath ".build\scripts\Pask.ps1")) "Cannot find Pask build script"
        Assert (Test-Path (Join-Path $SolutionFullPath ".build\tasks")) "Cannot find 'tasks' directory"
        Assert (Test-Path (Join-Path $SolutionFullPath ".build\.gitignore")) "Cannot find '.build\.gitignore'"
        Assert (Test-Path (Join-Path $SolutionFullPath ".nuget\.gitignore")) "Cannot find '.nuget\.gitignore'"
        Assert (Test-Path (Join-Path $SolutionFullPath "go.bat")) "Cannot find go.bat'"
        $InvokeBuildVersion = (([xml](Get-Content (Join-Path $ProjectFullPath "Pask.nuspec"))).package.metadata.dependencies.dependency | Where { $_.id -eq "Invoke-Build" }).version
        Assert ((([xml](Get-Content (Join-Path $SolutionFullPath "Application\packages.config"))).packages.package | Where { $_.id -eq "Invoke-Build" }).version -eq $InvokeBuildVersion) "Incorrect version of Invoke-Build installed into project 'Application'"
        Assert ((([xml](Get-Content (Join-Path $SolutionFullPath "Application.Domain\packages.config"))).packages.package | Where { $_.id -eq "Invoke-Build" }).version -eq $InvokeBuildVersion) "Incorrect version of Invoke-Build installed into project 'Application.Domain'"
    }

    Test-PackageInstallation -Assertion $Assertion
}