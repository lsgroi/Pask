$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
Import-Script Pask.Tests.Infrastructure

Describe "Default" {
    BeforeAll {
        # Arrange
        $TestSolutionFullPath = Join-Path $Here "Default"
        Install-Pask -SolutionFullPath $TestSolutionFullPath
        Exec { Robocopy (Join-Path "$ProjectFullPath" "init\.build") (Join-Path "$TestSolutionFullPath" ".build") "build.ps1" /256 /XO /NP /NFL /NDL /NJH /NJS } (0..7)
    }

    Context "Invoke the default task" {
        # Act
        Invoke-Pask $TestSolutionFullPath

        It "builds the default project" {
            Join-Path $TestSolutionFullPath "ClassLibrary\bin\Debug\ClassLibrary.dll" | Should Exist
        }

        It "uses the default platform" {
            [reflection.assemblyname]::GetAssemblyName((Join-Path $TestSolutionFullPath "ClassLibrary\bin\Debug\ClassLibrary.dll")).ProcessorArchitecture | Should Be "MSIL"
        }

        It "builds other projects" {
            Join-Path $TestSolutionFullPath "ClassLibrary.Tests\bin\Debug\ClassLibrary.Tests.dll" | Should Exist
        }
    }
}