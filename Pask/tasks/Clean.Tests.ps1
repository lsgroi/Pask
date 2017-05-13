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
            New-Directory -Path (Join-Path "$TestSolutionFullPath" "bin") | Out-Null
            Set-Content -Path (Join-Path "$TestSolutionFullPath" "bin\ClassLibrary.dll") -Value "" -Force
            New-Directory -Path (Join-Path "$TestSolutionFullPath" ".build\output") | Out-Null
            Set-Content -Path (Join-Path "$TestSolutionFullPath" ".build\output\ClassLibrary.dll") -Value "" -Force
            New-Directory -Path (Join-Path "$TestSolutionFullPath" "ClassLibrary\bin") | Out-Null
            Set-Content -Path (Join-Path "$TestSolutionFullPath" "ClassLibrary\bin\ClassLibrary.dll") -Value "" -Force
            New-Directory -Path (Join-Path "$TestSolutionFullPath" "ClassLibrary\obj") | Out-Null
            Set-Content -Path (Join-Path "$TestSolutionFullPath" "ClassLibrary\obj\ClassLibrary.dll") -Value "" -Force
            New-Directory -Path (Join-Path "$TestSolutionFullPath" "ClassLibrary\node_modules\gulp\bin") | Out-Null
            Set-Content -Path (Join-Path "$TestSolutionFullPath" "ClassLibrary\node_modules\gulp\bin\gulp.cmd") -Value "" -Force

            # Act
            Invoke-Pask $TestSolutionFullPath -Task Clean
        }

        It "should clean the build output directory" {
            Join-Path $TestSolutionFullPath ".build\output\*" | should Not Exist
        }

        It "should clean the project bin directory" {
            Join-Path $TestSolutionFullPath "ClassLibrary\bin" | Should Not Exist
        }

        It "should clean the project obj directory" {
            Join-Path $TestSolutionFullPath "ClassLibrary\obj" | Should Not Exist
        }

        It "should not clean other bin/obj directories" {
            Join-Path $TestSolutionFullPath "bin\ClassLibrary.dll" | Should Exist
            Join-Path $TestSolutionFullPath "ClassLibrary\node_modules\gulp\bin\gulp.cmd" | Should Exist
        }
    }
}