$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
Import-Script Pask.Tests.Infrastructure

Describe "Parallel" {
    BeforeAll {
        # Arrange
        $TestSolutionFullPath = Join-Path $Here "Parallel"
        Install-Pask -SolutionFullPath $TestSolutionFullPath
    }

    Context "Invoke two tasks simultaneously" {
        It "has no errors" {
            Invoke-Pask $TestSolutionFullPath -Task Test-Parallel -InputProperty1 "value of InputProperty1" -InputBoolProperty1 $true
        }
    }

    Context "Build two projects simultaneously" {
        BeforeAll {
            # Act
            Invoke-Pask $TestSolutionFullPath -Task Build-Projects
        }

        It "builds the first project" {
            Join-Path $TestSolutionFullPath "ClassLibrary\bin\Debug\ClassLibrary.dll" | Should Exist
        }

        It "builds the second project" {
            Join-Path $TestSolutionFullPath "ClassLibrary.Tests\bin\Debug\ClassLibrary.Tests.dll" | Should Exist
        }
    }
}