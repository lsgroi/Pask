$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
$Sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace "\.Tests\.", "."
. "$Here\$Sut"

Describe "Get-MSBuildProjectFile" {
    BeforeAll {
        $ProjectFullName = "project_file"
        $SolutionFullName = "solution_file"
    }

    Context "Default" {
        BeforeAll {
            $BuildProjectOnly = ""
        }

        It "gets the solution file" {
            Get-MSBuildProjectFile | Should Be "solution_file"
        }
    }
    
    Context "Build project only" {
        BeforeAll {
            $BuildProjectOnly = $true
        }

        It "gets the project file" {
            Get-MSBuildProjectFile | Should Be "project_file"
        }
    }

    Context "Do not build project only" {
        BeforeAll {
            $BuildProjectOnly = $false
        }

        It "gets the solution file" {
            Get-MSBuildProjectFile | Should Be "solution_file"
        }
    }
}

Describe "Get-MSBuildPlatformProperty" {
    Context "With build platform" {
        BeforeAll {
            $BuildPlatform = "x86"
        }

        It "gets the platform property" {
            Get-MSBuildPlatformProperty | Should Be "/p:Platform=""x86"""
        }
    }

    Context "Without build platform" {
        BeforeAll {
            $BuildPlatform = ""
        }

        It "gets empty value" {
            Get-MSBuildPlatformProperty | Should BeNullOrEmpty
        }
    }
}