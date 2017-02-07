$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
Import-Script Pask.Tests.Infrastructure

Describe "ZipExtract-Artifact" {
    BeforeAll {
        # Arrange
        $TestSolutionFullPath = Join-Path $Here "ZipExtract-Artifact"
        Install-Pask -SolutionFullPath $TestSolutionFullPath
        Invoke-Pask $TestSolutionFullPath -Task Clean, Build, New-Artifact, Zip-Artifact
    }

    It "creates the zip artifact" {
        Join-Path $TestSolutionFullPath ".build\output\ClassLibrary.*.zip" | Should Exist
    }

    Context "Zip and extract an artifact" {
        # Act
        Remove-ItemSilently (Join-Path $TestSolutionFullPath ".build\output\ClassLibrary")
        Invoke-Pask $TestSolutionFullPath -Task Extract-Artifact

        It "extracts the artifact's assembly" {
            Join-Path $TestSolutionFullPath ".build\output\ClassLibrary\ClassLibrary.dll" | Should Exist
        }

        It "extracts the artifact's content" {
            Join-Path $TestSolutionFullPath ".build\output\ClassLibrary\TextFile1.txt" | Should Exist
            Join-Path $TestSolutionFullPath ".build\output\ClassLibrary\Content\TextFile2.txt" | Should Exist
        }
    }

    Context "Zip an artifact and extract filtered files" {
        # Act
        Remove-ItemSilently (Join-Path $TestSolutionFullPath ".build\output\ClassLibrary")
        Invoke-Pask $TestSolutionFullPath -Task Extract-Artifact -FileNameToExtract @("TextFile2.txt")

        It "extracts the filtered files" {
            Join-Path $TestSolutionFullPath ".build\output\ClassLibrary\Content\TextFile2.txt" | Should Exist
        }

        It "does not extract the other files" {
            Join-Path $TestSolutionFullPath ".build\output\ClassLibrary\ClassLibrary.dll" | Should Not Exist
            Join-Path $TestSolutionFullPath ".build\output\ClassLibrary\TextFile1.txt" | Should Not Exist
        }
    }
}