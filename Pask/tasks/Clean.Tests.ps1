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
            Join-Path $TestSolutionFullPath ".build\output\*" | should Not Exist
        }

        It "should clean the bin directory" {
            Join-Path $TestSolutionFullPath "ClassLibrary\bin" | Should Not Exist
        }

        It "should clean the obj directory" {
            Join-Path $TestSolutionFullPath "ClassLibrary\obj" | Should Not Exist
        }
    }
}