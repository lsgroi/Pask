Import-Task Clean
Import-Script Properties.MSBuild -Package Pask

# Synopsis: Default task
Task . Clean

# Synopsis: Test two tasks running simultaneously
Task Test-Parallel {
    Tasks -Task ParallelTask1, ParallelTask2 -InputProperty2 "value of InputProperty2" -InputBoolProperty2 $true -Result ParallelResult

    # Assert that the ParallelTask1 had no errors
    Equals ($BuildResult.Tasks | Where { $_.Name -eq "ParallelTask1" } | Select -ExpandProperty Error) $null

    # Assert that the ParallelTask2 had no errors
    Equals ($BuildResult.Tasks | Where { $_.Name -eq "ParallelTask2" } | Select -ExpandProperty Error) $null
}

# Synopsis: Test task to run simultaneously
Task ParallelTask1 {
    Equals $InputProperty1 "value of InputProperty1"
    Equals $InputBoolProperty2 $true
}

# Synopsis: Test task to run simultaneously
Task ParallelTask2 {
    Equals $InputProperty2 "value of InputProperty2"
    Equals $InputBoolProperty1 $true
}

# Synopsis: Build the projects simultaneously
Task Build-Projects Clean, {
    Jobs -Task Build-ClassLibrary, Build-ClassLibraryTests -Result BuildResult
}

# Synopsis: Build ClassLibrary project only
Task Build-ClassLibrary {
    Use $MSBuildVersion MSBuild
    $Project = Join-Path $SolutionFullPath "ClassLibrary\ClassLibrary.csproj"
    "Building '$Project'`r`n"
    Exec { MSBuild "$Project" /t:Build /Verbosity:quiet }
}

# Synopsis: Build ClassLibrary.Tests project only
Task Build-ClassLibraryTests {
    Use $MSBuildVersion MSBuild
    $Project = Join-Path $SolutionFullPath "ClassLibrary.Tests\ClassLibrary.Tests.csproj"
    "Building '$Project'`r`n"
    Exec { MSBuild "$Project" /t:Build /Verbosity:quiet }
}