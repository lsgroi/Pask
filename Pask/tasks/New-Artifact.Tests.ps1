$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
Import-Script Pask.Tests.Infrastructure

Describe "New-Artifact" {
    BeforeAll {
        # Arrange
        $TestSolutionFullPath = Join-Path $Here "New-Artifact"
        Install-Pask -SolutionFullPath $TestSolutionFullPath
    }

    Context "Create a new artifact when the artifact directory does not exist" {
        # Arrange
        Invoke-Pask $TestSolutionFullPath -Task Clean
        New-Item -Path (Join-Path $TestSolutionFullPath "ClassLibrary\bin\CustomConfiguration\ClassLibrary.dll") -ItemType File -Force | Out-Null

        # Act
        Invoke-Pask $TestSolutionFullPath -Task New-Artifact -BuildConfiguration CustomConfiguration

        It "creates the artifact" {
            Join-Path $TestSolutionFullPath ".build\output\ClassLibrary\ClassLibrary.dll" | Should Exist
        }
    }

    Context "Create a new artifact when the artifact directory already exist" {
        # Arrange
        Invoke-Pask $TestSolutionFullPath -Task Clean
        New-Item -Path (Join-Path $TestSolutionFullPath "ClassLibrary\bin\CustomConfiguration\ClassLibrary.dll") -ItemType File -Force | Out-Null
        New-Item -Path (Join-Path $TestSolutionFullPath ".build\output\ClassLibrary") -ItemType Directory -Force | Out-Null

        # Act
        Invoke-Pask $TestSolutionFullPath -Task New-Artifact -BuildConfiguration CustomConfiguration

        It "creates the artifact" {
            Join-Path $TestSolutionFullPath ".build\output\ClassLibrary\ClassLibrary.dll" | Should Exist
        }
    }

    Context "Create a new artifact and remove PDB files" {
        # Arrange
        Invoke-Pask $TestSolutionFullPath -Task Clean
        New-Item -Path (Join-Path $TestSolutionFullPath "ClassLibrary\bin\Debug\ClassLibrary.dll") -ItemType File -Force | Out-Null
        New-Item -Path (Join-Path $TestSolutionFullPath "ClassLibrary\bin\Debug\ClassLibrary.pdb") -ItemType File -Force | Out-Null
        New-Item -Path (Join-Path $TestSolutionFullPath "ClassLibrary\bin\Debug\bin\Library.pdb") -ItemType File -Force | Out-Null

        # Act
        Invoke-Pask $TestSolutionFullPath -Task New-Artifact -RemoveArtifactPDB $true

        It "creates the artifact" {
            Join-Path $TestSolutionFullPath ".build\output\ClassLibrary\ClassLibrary.dll" | Should Exist
        }

        It "removes the PDB files" {
            Join-Path $TestSolutionFullPath ".build\output\ClassLibrary\ClassLibrary.pdb" | Should Not Exist
            Join-Path $TestSolutionFullPath ".build\output\ClassLibrary\bin\Library.pdb" | Should Not Exist
        }
    }
}