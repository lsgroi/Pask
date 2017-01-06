$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
$Sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace "\.Tests\.", "."
. "$Here\$Sut"

Describe "Get-SolutionTestProjects" {
    Context "Solution with two test projects and a solution folder" {
        BeforeAll {
            # Arrange sample solution
            $SolutionFullPath = $TestDrive
            $SolutionFullName = Join-Path $SolutionFullPath "Solution.sln"
            $SolutionValue = @"
Project("{F5034706-568F-408A-B7B3-4D38C6DB8A32}") = "PowerShellProject", "PowerShell\ScriptsProject.pssproj", "{6CAFC0C6-A428-4D30-A9F9-700E829FEA51}"
EndProject
Project("{FAE04EC0-301F-11D3-BF4B-00C04F79EFBC}") = "Project", "Project\Project.csproj", "{550A4A44-22C6-41CE-A5F0-30E406E56C6F}"
EndProject
Project("{FAE04EC0-301F-11D3-BF4B-00C04F79EFBC}") = "Project.UnitTests", "Tests\Unit\Project.UnitTests.csproj", "{0AE93B78-69BE-4235-9AC5-2E45A36244F1}"
EndProject
Project("{2150E333-8FDC-42A3-9474-1A3956D46DE8}") = "Project.IntegrationTests", "Tests\Integration\Project.IntegrationTests.csproj", "{0AE93B78-69BE-4235-9AC5-2E45A36244F1}"
EndProject
Project("{2150E333-8FDC-42A3-9474-1A3956D46DE8}") = "SolutionFolder", "SolutionFolderDirectory", "{10EA066F-9BD3-45DF-A2D7-71BE7397A4DB}"
EndProject
"@
            Set-Content -Path $SolutionFullName -Value $SolutionValue
            $TestNamePattern = "Tests$"

            # Act
            $Result = Get-SolutionTestProjects
        }

        It "gets two projects" {    
            $Result.Count | Should Be 2
        }

        It "gets the first test project name" {
            $Result[0].Name | Should Be "Project.UnitTests"
        }

        It "gets the first test project file" {
            $Result[0].File | Should Be "Project.UnitTests.csproj"
        }

        It "gets the first test project directory" {
            $Result[0].Directory | Should Be (Join-Path $SolutionFullPath "Tests\Unit")
        }

        It "gets the first test project type" {
            $Result[0].Type | Should Be "UnitTests"
        }

        It "gets the second test project name" {
            $Result[1].Name | Should Be "Project.IntegrationTests"
        }

        It "gets the second test project file" {
            $Result[1].File | Should Be "Project.IntegrationTests.csproj"
        }

        It "gets the second test project directory" {
            $Result[1].Directory | Should Be (Join-Path $SolutionFullPath "Tests\Integration")
        }

        It "gets the second test project type" {
            $Result[1].Type | Should Be "IntegrationTests"
        }
    }
}