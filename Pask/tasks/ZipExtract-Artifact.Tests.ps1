$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
Import-Script Pask.Tests.Infrastructure

Describe "ZipExtract-Artifact" {
    BeforeAll {
        # Arrange
        $TestSolutionFullPath = Join-Path $Here "ZipExtract-Artifact"
        Install-Pask -SolutionFullPath $TestSolutionFullPath
    }

    Context "Zip and extract an artifact" {
        BeforeAll {
            # Act
            Invoke-Pask $TestSolutionFullPath -Task Clean, Build, New-Artifact, Zip-Artifact, Extract-Artifact
        }

        It "creates the zip artifact" {
            Join-Path $TestSolutionFullPath ".build\output\ClassLibrary.*.zip" | Should Exist
        }

        It "extracts the artifact's assembly" {
            Join-Path $TestSolutionFullPath ".build\output\ClassLibrary\ClassLibrary.dll" | Should Exist
        }

        It "extracts the artifact's content" {
            Join-Path $TestSolutionFullPath ".build\output\ClassLibrary\TextFile1.txt" | Should Exist
            Join-Path $TestSolutionFullPath ".build\output\ClassLibrary\Content\TextFile2.txt" | Should Exist
        }
    }

    Context "Extract an artifact with custom name" {
        BeforeAll {
            # Arrange
            Invoke-Pask $TestSolutionFullPath -Task Clean, Build, New-Artifact, Zip-Artifact
            Remove-PaskItem (Join-Path $TestSolutionFullPath ".build\output\ClassLibrary")
            $ZipArtifact = Get-ChildItem -Path (Join-Path $TestSolutionFullPath ".build\output\ClassLibrary.*.zip")
            Rename-Item -Path $ZipArtifact.FullName -NewName ($ZipArtifact.Name -replace "ClassLibrary", "NewClassLibrary")
            
            # Act
            Invoke-Pask $TestSolutionFullPath -Task Extract-Artifact -ArtifactName "NewClassLibrary"
        }

        It "extracts the artifact's assembly" {
            Join-Path $TestSolutionFullPath ".build\output\NewClassLibrary\ClassLibrary.dll" | Should Exist
        }

        It "extracts the artifact's content" {
            Join-Path $TestSolutionFullPath ".build\output\NewClassLibrary\TextFile1.txt" | Should Exist
            Join-Path $TestSolutionFullPath ".build\output\NewClassLibrary\Content\TextFile2.txt" | Should Exist
        }
    }

    Context "Zip an artifact and extract filtered files" {
        BeforeAll {
            # Act
            Invoke-Pask $TestSolutionFullPath -Task Clean, Build, New-Artifact, Zip-Artifact, Extract-Artifact -FileNameToExtract @("TextFile2.txt")
        }

        It "creates the zip artifact" {
            Join-Path $TestSolutionFullPath ".build\output\ClassLibrary.*.zip" | Should Exist
        }

        It "extracts the filtered files" {
            Join-Path $TestSolutionFullPath ".build\output\ClassLibrary\Content\TextFile2.txt" | Should Exist
        }

        It "does not extract the other files" {
            Join-Path $TestSolutionFullPath ".build\output\ClassLibrary\ClassLibrary.dll" | Should Not Exist
            Join-Path $TestSolutionFullPath ".build\output\ClassLibrary\TextFile1.txt" | Should Not Exist
        }
    }
}