$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
Import-Script Pask.Tests.Infrastructure

Describe "Clean" {
    BeforeAll {
        # Arrange
        $TestSolutionFullPath = Join-Path $Here "Clean"
        Install-Pask -SolutionFullPath $TestSolutionFullPath
    }

    Context "Clean the solution" {
        BeforeAll {
            # Arrange
            # Create dummy files that the Clean task should clear
            New-Directory -Path (Join-Path "$TestSolutionFullPath" ".build\output") | Out-Null
            Set-Content -Path (Join-Path "$TestSolutionFullPath" ".build\output\test.txt") -Value "" -Force
            New-Directory -Path (Join-Path "$TestSolutionFullPath" "ClassLibrary\bin") | Out-Null
            New-Directory -Path (Join-Path "$TestSolutionFullPath" "ClassLibrary\obj") | Out-Null
            Set-Content -Path (Join-Path "$TestSolutionFullPath" "ClassLibrary\bin\test.txt") -Value "" -Force
            Set-Content -Path (Join-Path "$TestSolutionFullPath" "ClassLibrary\obj\test.txt") -Value "" -Force

            # Act
            Invoke-Pask $TestSolutionFullPath -Task Clean
        }

        It "should clean the build output directory" {
            Test-Path (Join-Path $TestSolutionFullPath ".build\output\*") | Should Be $false
        }

        It "should clean the bin directory" {
            Test-Path (Join-Path $TestSolutionFullPath "ClassLibrary\bin") | Should Be $false
        }

        It "should clean the obj directory" {
            Test-Path (Join-Path $TestSolutionFullPath "ClassLibrary\obj") | Should Be $false
        }
    }
}