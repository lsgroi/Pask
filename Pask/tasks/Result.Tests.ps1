$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
Import-Script Pask.Tests.Infrastructure

Describe "Result" {
    BeforeAll {
        # Arrange
        $TestSolutionFullPath = Join-Path $Here "Result"
        Install-Pask -SolutionFullPath $TestSolutionFullPath
        $TargetPaskFullName = Join-Path $TestSolutionFullPath "Pask.ps1"
    }

    Context "Output build information to a new variable" {
        BeforeAll {
            # Act
            $Result = PowerShell -Command { 
                param($TargetPaskFullName) 
                & "$TargetPaskFullName" -Task .  -Result NewVariable
                return $NewVariable 
            } -args @($TargetPaskFullName)
        }

        It "the new variable contains the build informations" {
            $Result.Tasks | Where { $_.Name -eq "EmptyTask" } | Measure | Select -ExpandProperty Count | should Be 1
        }
    }

    Context "Output build information to a an existing variable" {
        BeforeAll {
            # Act
            $Result = PowerShell -Command { 
                param($TargetPaskFullName) 
                $ExistingVariable = @{}
                & "$TargetPaskFullName" -Task .  -Result $ExistingVariable
                return $ExistingVariable 
            } -args @($TargetPaskFullName)
        }

        It "the existing variable contains the build informations" {
            $Result.Value.Tasks | Where { $_.Name -eq "EmptyTask" } | Measure | Select -ExpandProperty Count | should Be 1
        }
    }
}