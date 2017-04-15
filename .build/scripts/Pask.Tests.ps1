$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
$Sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace "\.Tests\.", "."
. "$Here\$Sut" -BuildProperties (Get-BuildProperties) -Files (Get-Files)

Describe "Set-BuildProperty" {
    BeforeAll {
        Mock Refresh-BuildProperties { }
    }

    Context "Set a build property with name null" {
        It "should error" {
            { Set-BuildProperty $null -Value "the value" } | Should Throw
        }

        It "does not refresh all the build properties" {
            Assert-MockCalled Refresh-BuildProperties -Exactly 0
        }
    }

    Context "Set a build property with static value and default value" {
        It "should error" {
            { Set-BuildProperty ([System.IO.Path]::GetRandomFileName()) -Value "the value" -Default "the default value" } | Should Throw
        }

        It "does not refresh all the build properties" {
            Assert-MockCalled Refresh-BuildProperties -Exactly 0
        }
    }

    Context "Set a new build property with value of session which does not exist" {
        It "should error" {
            { Set-BuildProperty ([System.IO.Path]::GetRandomFileName()) } | Should Throw
        }

        It "does not refresh all the build properties" {
            Assert-MockCalled Refresh-BuildProperties -Exactly 0
        }
    }

    Context "Set a new build property with static value" {
        BeforeAll {
            # Arrange
            $PropertyName = [System.IO.Path]::GetRandomFileName()

            # Act
            Set-BuildProperty $PropertyName -Value "the value"
        }

        It "a local variable should have the static value" {
            Get-Variable -Name $PropertyName -ValueOnly | Should Be "the value"
        }

        It "does not refresh all the build properties" {
            Assert-MockCalled Refresh-BuildProperties -Exactly 0
        }

        AfterAll {
            # Cleanup
            Remove-BuildProperty -Name $PropertyName
        }
    }

    Context "Set a new build property with static empty array value" {
        BeforeAll {
            # Arrange
            $PropertyName = [System.IO.Path]::GetRandomFileName()

            # Act
            Set-BuildProperty $PropertyName -Value @()
        }

        It "a local variable should have the static value of empty array" {
            Get-Variable -Name $PropertyName -ValueOnly | Should BeLike @()
        }

        It "does not refresh all the build properties" {
            Assert-MockCalled Refresh-BuildProperties -Exactly 0
        }

        AfterAll {
            # Cleanup
            Remove-BuildProperty -Name $PropertyName
        }
    }

    Context "Set a new build property with static value and refresh all the build properties" {
        BeforeAll {
            # Arrange
            $PropertyName = [System.IO.Path]::GetRandomFileName()

            # Act
            Set-BuildProperty $PropertyName -Value "the value" -Refresh
        }

        It "a local variable should have the static value" {
            Get-Variable -Name $PropertyName -ValueOnly | Should Be "the value"
        }

        It "refreshes all the build properties" {
            Assert-MockCalled Refresh-BuildProperties -Exactly 1
        }

        AfterAll {
            # Cleanup
            Remove-BuildProperty -Name $PropertyName
        }
    }

    Context "Set a new build property with static script block value" {
        BeforeAll {
            # Arrange
            $PropertyName = [System.IO.Path]::GetRandomFileName()
            $PropertyValue = "the value"

            # Act
            Set-BuildProperty $PropertyName -Value { $PropertyValue }
        }

        It "a local variable should have the value of the script block invoked" {
            Get-Variable -Name $PropertyName -ValueOnly | Should Be "the value"
        }

        It "does not refresh all the build properties" {
            Assert-MockCalled Refresh-BuildProperties -Exactly 0
        }

        AfterAll {
            # Cleanup
            Remove-BuildProperty -Name $PropertyName
        }
    }

    Context "Set an existing build property with static value" {
        BeforeAll {
            # Arrange
            $PropertyName = [System.IO.Path]::GetRandomFileName()
            Set-BuildProperty -Name $PropertyName -Value "the value"

            # Act
            Set-BuildProperty $PropertyName -Value "the new value"
        }

        It "a local variable should have the static value" {
            Get-Variable -Name $PropertyName -ValueOnly | Should Be "the new value"
        }

        It "does not refresh all the build properties" {
            Assert-MockCalled Refresh-BuildProperties -Exactly 0
        }

        AfterAll {
            # Cleanup
            Remove-BuildProperty -Name $PropertyName
        }
    }

    Context "Set an existing build property with static script block value" {
        BeforeAll {
            # Arrange
            $PropertyName = [System.IO.Path]::GetRandomFileName()
            Set-BuildProperty $PropertyName -Value "the value"
            $PropertyValue = "the new value"

            # Act
            Set-BuildProperty $PropertyName -Value { $PropertyValue }
        }

        It "a local variable should have the value of the script block invoked" {
            Get-Variable -Name $PropertyName -ValueOnly | Should Be "the new value"
        }

        It "does not refresh all the build properties" {
            Assert-MockCalled Refresh-BuildProperties -Exactly 0
        }

        AfterAll {
            # Cleanup
            Remove-BuildProperty -Name $PropertyName
        }
    }

    Context "Set a new build property with existing value of session" {
        BeforeAll {
            # Arrange
            $PropertyName = [System.IO.Path]::GetRandomFileName()
            [Environment]::SetEnvironmentVariable($PropertyName, "the value", "Process")

            # Act
            Set-BuildProperty $PropertyName
        }

        It "a local variable should have the value of session" {
            Get-Variable -Name $PropertyName -ValueOnly | Should Be "the value"
        }

        It "does not refresh all the build properties" {
            Assert-MockCalled Refresh-BuildProperties -Exactly 0
        }

        AfterAll {
            # Cleanup
            [Environment]::SetEnvironmentVariable($PropertyName, $null, "Process")
            Remove-BuildProperty -Name $PropertyName
        }
    }

    Context "Set an existing build property with existing value of session" {
        BeforeAll {
            # Arrange
            $PropertyName = [System.IO.Path]::GetRandomFileName()
            Set-Variable -Name $PropertyName -Value "the value" -Scope Script

            # Act
            Set-BuildProperty $PropertyName
        }

        It "a local variable should have the value of session" {
            Get-Variable -Name $PropertyName -ValueOnly | Should Be "the value"
        }

        It "does not refresh all the build properties" {
            Assert-MockCalled Refresh-BuildProperties -Exactly 0
        }

        AfterAll {
            # Cleanup
            Remove-BuildProperty -Name $PropertyName
        }
    }

    Context "Set a new build property with existing value of session specifying a default" {
        BeforeAll {
            # Arrange
            $PropertyName = [System.IO.Path]::GetRandomFileName()
            [Environment]::SetEnvironmentVariable($PropertyName, "the value", "Process")

            # Act
            Set-BuildProperty $PropertyName -Default "the default value"
        }

        It "a local variable should have the value of session" {
            Get-Variable -Name $PropertyName -ValueOnly | Should Be "the value"
        }

        It "does not refresh all the build properties" {
            Assert-MockCalled Refresh-BuildProperties -Exactly 0
        }

        AfterAll {
            # Cleanup
            [Environment]::SetEnvironmentVariable($PropertyName, $null, "Process")
            Remove-BuildProperty -Name $PropertyName
        }
    }

    Context "Set an existing build property with existing value of session specifying a default" {
        BeforeAll {
            # Arrange
            $PropertyName = [System.IO.Path]::GetRandomFileName()
            Set-Variable -Name $PropertyName -Value "the value" -Scope Script

            # Act
            Set-BuildProperty $PropertyName -Default "the default value"
        }

        It "a local variable should have the value of session" {
            Get-Variable -Name $PropertyName -ValueOnly | Should Be "the value"
        }

        It "does not refresh all the build properties" {
            Assert-MockCalled Refresh-BuildProperties -Exactly 0
        }

        AfterAll {
            # Cleanup
            Remove-BuildProperty -Name $PropertyName
        }
    }

    Context "Set a new build property with default value" {
        BeforeAll {
            # Arrange
            $PropertyName = [System.IO.Path]::GetRandomFileName()

            # Act
            Set-BuildProperty $PropertyName -Default "the default value"
        }

        It "a local variable should have the default value" {
            Get-Variable -Name $PropertyName -ValueOnly | Should Be "the default value"
        }

        It "does not refresh all the build properties" {
            Assert-MockCalled Refresh-BuildProperties -Exactly 0
        }

        AfterAll {
            # Cleanup
            Remove-BuildProperty -Name $PropertyName
        }
    }

    Context "Set a new build property with default value of empty array" {
        BeforeAll {
            # Arrange
            $PropertyName = [System.IO.Path]::GetRandomFileName()

            # Act
            Set-BuildProperty $PropertyName -Default @()
        }

        It "a local variable should have the default value of empty array" {
            Get-Variable -Name $PropertyName -ValueOnly | Should BeLike @()
        }

        It "does not refresh all the build properties" {
            Assert-MockCalled Refresh-BuildProperties -Exactly 0
        }

        AfterAll {
            # Cleanup
            Remove-BuildProperty -Name $PropertyName
        }
    }

    Context "Set a new build property with default script block value" {
        BeforeAll {
            # Arrange
            $PropertyName = [System.IO.Path]::GetRandomFileName()
            $PropertyValue = "the default value"

            # Act
            Set-BuildProperty $PropertyName -Default { $PropertyValue }
        }

        It "a local variable should have the value of the script block invoked" {
            Get-Variable -Name $PropertyName -ValueOnly | Should Be "the default value"
        }

        It "does not refresh all the build properties" {
            Assert-MockCalled Refresh-BuildProperties -Exactly 0
        }

        AfterAll {
            # Cleanup
            Remove-BuildProperty -Name $PropertyName
        }
    }

    Context "Set an exisitng build property with default value" {
        BeforeAll {
            # Arrange
            $PropertyName = [System.IO.Path]::GetRandomFileName()
            Set-BuildProperty $PropertyName -Default "the value"

            # Act
            Set-BuildProperty $PropertyName -Default "the default value"
        }

        It "a local variable should have the existing property value" {
            Get-Variable -Name $PropertyName -ValueOnly | Should Be "the value"
        }

        It "does not refresh all the build properties" {
            Assert-MockCalled Refresh-BuildProperties -Exactly 0
        }

        AfterAll {
            # Cleanup
            Remove-BuildProperty -Name $PropertyName
        }
    }
}

Describe "Set-Property" {
    It "should be alias of Set-BuildProperty" {
        Get-Alias | Where { $_.Name -eq "Set-Property" } | Select -First 1 | Select -ExpandProperty Definition | Should Be "Set-BuildProperty"
    }
}

Describe "Get-BuildProperties" {
    BeforeAll {
        # Arrange
        $PropertyName = [System.IO.Path]::GetRandomFileName()
        Set-BuildProperty -Name $PropertyName -Value "the value"
        $ScriptBlockPropertyName = [System.IO.Path]::GetRandomFileName()
        $ScriptBlockPropertyValue = "the script block value"
        Set-BuildProperty -Name $ScriptBlockPropertyName -Value { $ScriptBlockPropertyValue }
    }

    It "gets a property previously set" {
        $(Get-BuildProperties).$PropertyName | Should Be "the value"
    }

    It "gets a property previously set with script block" {
        $(Get-BuildProperties).$ScriptBlockPropertyName | Should Be "the script block value"
    }

    AfterAll {
        # Cleanup
        Remove-BuildProperty -Name $PropertyName, $ScriptBlockPropertyName
    }
}

Describe "Get-Properties" {
    It "should be alias of Get-BuildProperties" {
        Get-Alias | Where { $_.Name -eq "Get-Properties" } | Select -First 1 | Select -ExpandProperty Definition | Should Be "Get-BuildProperties"
    }
}

Describe "Refresh-BuildProperties" {
    BeforeAll {
        # Arrange
        $PropertyName = [System.IO.Path]::GetRandomFileName()
        $PropertyValue = "the value"
        Set-BuildProperty -Name $PropertyName -Value { $PropertyValue }

        # Act
        $PropertyValue = "the new value"
        Refresh-BuildProperties
    }

    It "refreshes a build property with script block value" {
        Get-Variable -Name $PropertyName -ValueOnly | Should Be "the new value"
    }

    AfterAll {
        # Cleanup
        Remove-BuildProperty -Name $PropertyName
    }
}

Describe "Refresh-Properties" {
    It "should be alias of Get-BuildProperties" {
        Get-Alias | Where { $_.Name -eq "Refresh-Properties" } | Select -First 1 | Select -ExpandProperty Definition | Should Be "Refresh-BuildProperties"
    }
}

Describe "Pask-Cache" {
    BeforeAll {
        # Arrange
        $Key = [System.IO.Path]::GetRandomFileName()

        # Act
        Pask-Cache $Key -Value "cache-value"
    }

    AfterAll {
        # Cleanup
        Remove-PaskCache $Key
    }

    Context "Get all cache entries" {
        BeforeAll {
            # Arrange
            $Key2 = [System.IO.Path]::GetRandomFileName()
            Pask-Cache $Key2 -Value "another-cache-value"

            # Act
            $Cache = Pask-Cache
        }

        It "gets known cache entries" {
            $Cache.$Key | Should Be "cache-value"
            $Cache.$Key2 | Should Be "another-cache-value"
        }
    }

    Context "Get a cache entry" {
        It "gets the cache value" {
            Pask-Cache $Key | Should Be "cache-value"
        }
    }

    Context "Set an existing cache entry" {
        BeforeAll {
            Pask-Cache $Key -Value "new-cache-value"
        }

        It "overrides the cache value" {
            Pask-Cache $Key | Should Be "new-cache-value"
        }
    }
}

Describe "New-Directory" {    
    Context "Non existent directory" {
        BeforeAll {
            # Arrange
            $Path = Join-Path $TestDrive "dir"

            # Act
            $Result = New-Directory "$Path"
        }

        It "the directory is created" {
            $Path | Should Exist
        }

        It "the directory is returned" {
            $Result.FullName | Should Be $Path
        }
    }

    Context "Non existent directory from pipeline" {
        BeforeAll {
            # Arrange
            $Path = Join-Path $TestDrive "dir"

            # Act
            $Result = $Path | New-Directory
        }

        It "the directory is created" {
            $Path | Should Exist
        }

        It "the directory is returned" {
            $Result.FullName | Should Be $Path
        }
    }

    Context "Exisiting directory" {
        BeforeAll {
            # Arrange
            $Path = Join-Path $TestDrive "dir"
            New-Item -Path "$Path" -ItemType Directory
        
            # Act
            $Result = New-Directory "$Path"
        }

        It "the directory is created" {
            $Path | Should Exist
        }

        It "the directory is returned" {
            $Result.FullName | Should Be $Path
        }
    }

    Context "Exisiting directory from pipeline" {
        BeforeAll {
            # Arrange
            $Path = Join-Path $TestDrive "dir"
            New-Item -Path "$Path" -ItemType Directory
        
            # Act
            $Result = $Path | New-Directory
        }

        It "the directory is created" {
            $Path | Should Exist
        }

        It "the directory is returned" {
            $Result.FullName | Should Be $Path
        }
    }

    Context "Three non existing directories from pipeline" {
        BeforeAll {
            # Arrange
            $Path1 = Join-Path $TestDrive "dir1"
            $Path2 = Join-Path $TestDrive "dir2"
            $Path3 = Join-Path $TestDrive "dir3"

            # Act
            $Result = $Path1, $Path2, $Path3 | New-Directory
        }

        It "the first directory is created" {
            $Path1 | Should Exist
        }

        It "the first directory is returned" {
            $Result[0].FullName | Should Be $Path1
        }

        It "the second directory is created" {
            $Path2 | Should Exist
        }

        It "the second directory is returned" {
            $Result[1].FullName | Should Be $Path2
        }

        It "the third directory is created" {
            $Path3 | Should Exist
        }

        It "the third directory is returned" {
            $Result[2].FullName | Should Be $Path3
        }
    }

    Context "Three exisitng directories from pipeline" {
        BeforeAll {
            # Arrange
            $Path1 = Join-Path $TestDrive "dir1"
            $Path2 = Join-Path $TestDrive "dir2"
            $Path3 = Join-Path $TestDrive "dir3"
            New-Item -Path "$Path1" -ItemType Directory
            New-Item -Path "$Path2" -ItemType Directory
            New-Item -Path "$Path3" -ItemType Directory

            # Act
            $Result = $Path1, $Path2, $Path3 | New-Directory
        }

        It "the first directory is created" {
            $Path1 | Should Exist
        }

        It "the first directory is returned" {
            $Result[0].FullName | Should Be $Path1
        }

        It "the second directory is created" {
            $Path2 | Should Exist
        }

        It "the second directory is returned" {
            $Result[1].FullName | Should Be $Path2
        }

        It "the third directory is created" {
            $Path3 | Should Exist
        }

        It "the third directory is returned" {
            $Result[2].FullName | Should Be $Path3
        }
    }
}

Describe "Remove-ItemSilently" {
    Context "Remove existing item from pipeline" {
        BeforeAll {
            # Arrange
            $Item = Join-Path $TestDrive "item"
            New-Item -Path "$Item" -ItemType Directory

            # Act
            $Item | Remove-ItemSilently
        }

        It "the item is removed" {
            $Item | Should Not Exist
        }
    }

    Context "Remove three existing items from pipeline" {
        BeforeAll {
            # Arrange
            $Item1 = Join-Path $TestDrive "item1"
            $Item2 = Join-Path $TestDrive "item2"
            $Item3 = Join-Path $TestDrive "item3"
            New-Item -Path "$Item1" -ItemType Directory
            New-Item -Path "$Item2" -ItemType Directory
            New-Item -Path "$Item3" -ItemType Directory

            # Act
            $Item1, $Item2, $Item3 | Remove-ItemSilently
        }

        It "the first item is removed" {
            $Item1 | Should Not Exist
        }

        It "the second item is removed" {
            $Item2 | Should Not Exist
        }

        It "the third item is removed" {
            $Item3 | Should Not Exist
        }
    }

    Context "Remove directory recursively" {
        BeforeAll {
            # Arrange
            $Item = Join-Path $TestDrive "item\sub1\sub2"
            New-Item -Path $Item -ItemType Directory
            New-Item -Path (Join-Path $TestDrive "item\sub1\file1.txt") -ItemType File
            New-Item -Path (Join-Path $TestDrive "item\sub1\sub2\file2.txt") -ItemType File

            # Act
            Remove-ItemSilently $Item
        }

        It "the item is removed" {
            $Item| Should Not Exist
        }
    }

    Context "Remove item with wildcard" {
        BeforeAll {
            # Arrange
            New-Item -Path (Join-Path $TestDrive "solution") -ItemType Directory
            New-Item -Path (Join-Path $TestDrive "solution\bin") -ItemType Directory
            New-Item -Path (Join-Path $TestDrive "solution\project\bin") -ItemType Directory
            New-Item -Path (Join-Path $TestDrive "solution\project\bin\project.dll") -ItemType File

            # Act
            Remove-ItemSilently (Join-Path $TestDrive "**\bin")
        }

        It "the item is removed in the sub directory" {
            Join-Path $TestDrive "solution\bin" | Should Not Exist
        }

        It "the item is removed recursively" {
            Join-Path $TestDrive "solution\project\bin" | Should Not Exist
        }
    }

    Context "Remove all content of directory" {
        BeforeAll {
            # Arrange
            New-Item -Path (Join-Path $TestDrive "solution") -ItemType Directory
            New-Item -Path (Join-Path $TestDrive "solution\file.dll") -ItemType File
            New-Item -Path (Join-Path $TestDrive "solution\bin") -ItemType Directory
            New-Item -Path (Join-Path $TestDrive "solution\project\bin") -ItemType Directory
            New-Item -Path (Join-Path $TestDrive "solution\project\bin\project.dll") -ItemType File

            # Act
            Remove-ItemSilently (Join-Path $TestDrive "solution\*")
        }

        It "content of the directory is removed" {
            Join-Path $TestDrive "solution\*" | Should Not Exist
        }
    }

    Context "Remove non existent item" {
        BeforeAll {
            # Arrange
            $Item = Join-Path $TestDrive "fake-item"
        
            # Act
            Remove-ItemSilently $Item
        }

        It "the item does not exist" {
            $Item | Should Not Exist
        }
    }
}

Describe "Get-NuGetExe" {
    $PaskFullPath = (Join-Path $TestDrive "solution directory")
    
    It "gets the NuGet executable" {
        Get-NuGetExe | Should Be (Join-Path $TestDrive "solution directory\.nuget\NuGet.exe")
    }
}

Describe "Initialize-NuGetExe" {
    BeforeAll {
        # Arrange
        $PaskFullPath = (Join-Path $TestDrive "solution directory")
        $NuGet = (Join-Path $PaskFullPath ".nuget\NuGet.exe")
        Mock Get-NuGetExe { return $NuGet }
        Mock New-Object {
            $Result = [PSCustomObject] @{}
            Add-Member -InputObject $Result -MemberType ScriptMethod DownloadFile {
                param([string]$address, [string]$filename)
                    if ($address -eq "https://dist.nuget.org/win-x86-commandline/latest/nuget.exe") {
                        New-Item -Path $NuGet -ItemType File | Out-Null
                    }
                }
                return $Result
            } -ParameterFilter {$TypeName -and ($TypeName -ilike 'System.Net.WebClient') }
    }

    Context "NuGet executable already exists" {
        BeforeAll {
            # Arrange
            New-Item -Path (Join-Path $PaskFullPath ".nuget") -ItemType Directory
            New-Item -Path $NuGet -ItemType File

            # Act
            Initialize-NuGetExe
        }

        It "does not download the NuGet executable" {
            Assert-MockCalled New-Object -Exactly 0
        }
    }

    Context "NuGet directory does not exist" {
        BeforeAll {
            # Act
            Initialize-NuGetExe
        }

        It "creates the NuGet folder and downloads the NuGet executable" {
            $NuGet | Should Exist
        }
    }

    Context "NuGet directory exists but NuGet executable does not exist" {
        BeforeAll {
            # Arrange
            New-Item -Path (Join-Path $PaskFullPath ".nuget") -ItemType Directory

            # Act
            Initialize-NuGetExe
        }

        It "downloads the NuGet executable" {
            $NuGet | Should Exist
        }
    }
}

Describe "Get-PackagesDir" {
    BeforeAll {
        # Arrange
        $PaskFullPath = (Join-Path $TestDrive "solution directory")
        New-Item -Path (Join-Path $PaskFullPath ".nuget") -ItemType Directory
        $NuGet = (Join-Path $PaskFullPath ".nuget\NuGet.exe")
        Mock Get-NuGetExe { return $NuGet }
        Mock Pask-Cache { }
    }

    Context "NuGet executable does not exist" {
        BeforeAll {
            # Act
            $Result = Get-PackagesDir
        }

        It "gets the default packages directory" {
            $Result | Should Be (Join-Path $TestDrive "solution directory\packages")
        }

        It "caches the packages directory" {
            Assert-MockCalled Pask-Cache 1  -ParameterFilter { $key -eq "Get-PackagesDir" -and $value -eq (Join-Path $TestDrive "solution directory\packages") }
        }
    }

    Context "RepositoryPath not defined in NuGet.config" {
        BeforeAll {
            # Arrange
            Set-Content -Path $NuGet -Value "" -Force
            Mock Invoke-Command { return "WARNING: Key 'repositoryPath' not found." }

            # Act
            $Result = Get-PackagesDir
        }

        It "gets the default packages directory" {
            $Result | Should Be (Join-Path $TestDrive "solution directory\packages")
        }

        It "caches the packages directory" {
            Assert-MockCalled Pask-Cache 1  -ParameterFilter { $key -eq "Get-PackagesDir" -and $value -eq (Join-Path $TestDrive "solution directory\packages") }
        }
    }

    Context "RepositoryPath defined in NuGet.config" {
        BeforeAll {
            # Arrange
            Set-Content -Path $NuGet -Value "" -Force
            $repositoryPath = (Join-Path $TestDrive "custom packages directory")
            Mock Invoke-Command { return $repositoryPath }

            # Act
            $Result = Get-PackagesDir
        }

        It "gets the custom packages directory" {
            $Result | Should Be $repositoryPath
        }

        It "caches the packages directory" {
            Assert-MockCalled Pask-Cache 1  -ParameterFilter { $key -eq "Get-PackagesDir" -and $value -eq $repositoryPath }
        }
    }

    Context "From the cache" {
        BeforeAll {
            # Arrange
            Mock Pask-Cache { return "packages_dir" } -ParameterFilter { $key -eq "Get-PackagesDir" }

            # Act
            $Result = Get-PackagesDir
        }

        It "gets the cached packages directory" {
            $Result | Should Be "packages_dir"
        }

        It "does not cache the packages directory" {
            Assert-MockCalled Pask-Cache 0  -ParameterFilter { $key -eq "Get-PackagesDir" -and $value -eq "packages_dir" }
        }
    }
}

Describe "Get-ProjectFullName" {
    BeforeAll {
        Mock Get-SolutionProjects { 
                    $Result = @()
                    $Result += New-Object PSObject -Property @{ Name = "Project1"; File = "Project1.csproj"; Directory = (Join-Path $TestDrive "Project1") }
                    $Result += New-Object PSObject -Property @{ Name = "Project2"; File = "Project2.csproj"; Directory = (Join-Path $TestDrive "Project2") }
                    $Result += New-Object PSObject -Property @{ Name = "Project3"; File = "Project3.csproj"; Directory = (Join-Path $TestDrive "Project3") } 
                    return $Result
                }
    }

    Context "The project does not exist" {
        It "returns null" {
            Get-ProjectFullName -Name "Project0" | Should Be $null
        }
    }

    Context "The project exists" {
        BeforeAll {
            # Arrange
            $ProjectName = "Project2"
            New-Item -ItemType Directory -Path (Join-Path $TestDrive $ProjectName)
            $FullName = Join-Path (Join-Path $TestDrive $ProjectName) ($ProjectName + ".csproj")
            Set-Content -Path $FullName -Value "" -Force
        }

        It "returns the project full name" {
            Get-ProjectFullName | Should Be $FullName
        }
    }
}

Describe "Get-SolutionProjects" {
    Context "Solution with three projects and a solution folder" {
        BeforeAll {
            # Arrange
            $SolutionFullPath = $TestDrive
            $SolutionFullName = Join-Path $SolutionFullPath "Solution.sln"
            $SolutionValue = @"
Project("{F5034706-568F-408A-B7B3-4D38C6DB8A32}") = "PowerShellProject", "PowerShell\ScriptsProject.pssproj", "{6CAFC0C6-A428-4D30-A9F9-700E829FEA51}"
EndProject
Project("{FAE04EC0-301F-11D3-BF4B-00C04F79EFBC}") = "Project", "Project\Project.csproj", "{550A4A44-22C6-41CE-A5F0-30E406E56C6F}"
EndProject
Project("{FAE04EC0-301F-11D3-BF4B-00C04F79EFBC}") = "ProjectUnitTests", "Tests\Unit\ProjectUnitTests.csproj", "{0AE93B78-69BE-4235-9AC5-2E45A36244F1}"
EndProject
Project("{2150E333-8FDC-42A3-9474-1A3956D46DE8}") = "SolutionFolder", "SolutionFolderDirectory", "{10EA066F-9BD3-45DF-A2D7-71BE7397A4DB}"
EndProject
"@
            Set-Content -Path $SolutionFullName -Value $SolutionValue
        
            # Act
            $Result = Get-SolutionProjects
        }

        It "gets three projects" {
            $Result.Count | Should Be 3
        }

        It "gets the first project name" {
            $Result[0].Name | Should Be "PowerShellProject"
        }

        It "gets the first project file" {
            $Result[0].File | Should Be "ScriptsProject.pssproj"
        }

        It "gets the first project directory" {
            $Result[0].Directory | Should Be (Join-Path $SolutionFullPath "PowerShell")
        }

        It "gets the second project name" {
            $Result[1].Name | Should Be "Project"
        }

        It "gets the second project file" {
            $Result[1].File | Should Be "Project.csproj"
        }

        It "gets the second project directory" {
            $Result[1].Directory | Should Be (Join-Path $SolutionFullPath "Project")
        }

        It "gets the third project name" {
            $Result[2].Name | Should Be "ProjectUnitTests"
        }

        It "gets the third project file" {
            $Result[2].File | Should Be "ProjectUnitTests.csproj"
        }

        It "gets the third project directory" {
            $Result[2].Directory | Should Be (Join-Path $SolutionFullPath "Tests\Unit")
        }
    }
}

Describe "Get-SolutionPackages" {
    Context "Solution has three projects and one package with two versions" {
        BeforeAll {
            # Arrange three sample projects
            Mock Get-SolutionProjects { 
                $Result = @()
                $Result += New-Object PSObject -Property @{ Directory = (Join-Path $TestDrive "Project1") }
                $Result += New-Object PSObject -Property @{ Directory = (Join-Path $TestDrive "Project2") }
                $Result += New-Object PSObject -Property @{ Directory = (Join-Path $TestDrive "Project3") } 
                return $Result
            }

            $Project1Packages = @"
<?xml version="1.0" encoding="utf-8"?>
<packages>
  <package id="AutoMapper" version="3.3.0" targetFramework="net46" />
</packages>
"@
            New-Item -Path (Join-Path $TestDrive "Project1") -ItemType Directory
            Set-Content -Path (Join-Path $TestDrive "Project1\packages.config") -Value $Project1Packages -Force

            $Project2Packages = @"
<?xml version="1.0" encoding="utf-8"?>
<packages>
  <package id="AutoMapper" version="3.3.1" targetFramework="net46" />
</packages>
"@
            New-Item -Path (Join-Path $TestDrive "Project2") -ItemType Directory
            Set-Content -Path (Join-Path $TestDrive "Project2\packages.config") -Value $Project2Packages -Force

            $Project3Packages = @"
<?xml version="1.0" encoding="utf-8"?>
<packages>
  <package id="AutoMapper" version="3.3.1" targetFramework="net46" />
</packages>
"@
            New-Item -Path (Join-Path $TestDrive "Project3") -ItemType Directory
            Set-Content -Path (Join-Path $TestDrive "Project3\packages.config") -Value $Project3Packages -Force

            # Act
            $Result = Get-SolutionPackages
        }

        It "gets two packages" {
            $Result.Count | Should Be 2
        }

        It "the two packages should have the same id" {
            $Result[0].id | Should Be $Result[1].id
        }

        It "gets the first version of the package" {
            $Result[0].version | Should Be "3.3.0"
        }

        It "gets the second version of the package" {
            $Result[1].version | Should Be "3.3.1"
        }
    }

    Context "Solution has one project with three packages of which two development dependencies" {
        BeforeAll {
            # Arrange three sample projects
            Mock Get-SolutionProjects { 
                $Result = @()
                $Result += New-Object PSObject -Property @{ Directory = (Join-Path $TestDrive "Project") }
                return $Result
            }

            $Project1Packages = @"
<?xml version="1.0" encoding="utf-8"?>
<packages>
  <package id="AutoMapper" version="3.3.0" targetFramework="net46" />
  <package id="Pester" version="2.0.0" developmentDependency="true" />
  <package id="7-Zip.CommandLine" version="8.3.0" developmentDependency="true" />
</packages>
"@
            New-Item -Path (Join-Path $TestDrive "Project") -ItemType Directory
            Set-Content -Path (Join-Path $TestDrive "Project\packages.config") -Value $Project1Packages -Force

            # Act
            $Result = Get-SolutionPackages
        }

        It "gets three packages" {
            $Result.Count | Should Be 3
        }

        It "two packages should be development dependencies" {
            ($Result | Where { $_.developmentDependency -eq $true }).Count | Should Be 2
        }

        It "one package should not be a development dependency" {
            $Result | Where { $_.id -eq "AutoMapper" } | Select -ExpandProperty developmentDependency | Should BeNullOrEmpty
        }
    }
}

Describe "Get-PackageDir" {
    Context "Empty package name" {
        It "should error" {
            { Get-PackageDir ([string]::Empty) } | Should Throw
        }
    }

    Context "Non existent package" {
        # Arrange
        Mock Get-SolutionPackages {
            $Result = @()
            $Result += New-Object PSObject -Property @{ id = "bar"; version = "1.0.0" }
            return $Result
        }

        It "should error" {
            { Get-PackageDir "foo" } | Should Throw
        }
    }

    Context "Solution without packages" {
        # Arrange
        Mock Get-SolutionPackages { return @() }

        It "should error" {
            { Get-PackageDir "foo" } | Should Throw
        }
    }

    Context "Package with multiple versions" {
        # Arrange
        Mock Get-SolutionPackages {
            $Result = @()
            $Result += New-Object PSObject -Property @{ id = "foo"; version = "1.0.0" }
            $Result += New-Object PSObject -Property @{ id = "foo"; version = "1.1.0" }
            return $Result
        }

        It "should error" {
            { Get-PackageDir "foo" } | Should Throw
        }
    }

    Context "Unique existent package from pipeline" {
        BeforeAll {
            # Arrange
            Mock Get-SolutionPackages {
                $Result = @()
                $Result += New-Object PSObject -Property @{ id = "bar"; version = "1.0.0" }
                $Result += New-Object PSObject -Property @{ id = "foo"; version = "1.1.0" }
                $Result += New-Object PSObject -Property @{ id = "foobar"; version = "2.1.0" }
                return $Result
            }
            Mock Get-PackagesDir { return "C:\packages directory" }
        }

        It "gets the package directory" {
            "foo" | Get-PackageDir | Should Be "C:\packages directory\foo.1.1.0"
        }
    }
}

Describe "Import-File" {
    BeforeAll {
        # Arrange
        $BuildFullPath = Join-Path $TestDrive ".build"
        New-Item $BuildFullPath -ItemType Directory
    }

    Context "Import non existent task" {
        BeforeAll {
            # Arrange
            Mock Get-SolutionProjects { return @() }
            Mock Get-SolutionPackages { return @() }
        }

        It "should error" {
            { Import-File Task-NonExistent "tasks" } | Should Throw
        }
    }

    Context "Import non existent script safely" {
        BeforeAll {
            # Arrange
            Mock Get-SolutionProjects { return @() }
            Mock Get-SolutionPackages { return @() }
        }

        It "should not error" {
            { Import-File Script.NonExistent "scripts" -Safe } | Should Not Throw
        }
    }

    Context "Script defined in the solution's build directory" {
        BeforeAll {
            # Arrange
            $script:ImportedScript = ""
            $ScriptFullName = Join-Path $BuildFullPath "scripts\ScriptFrom.Solution.ps1"
            New-Item -Path (Join-Path $BuildFullPath "scripts") -ItemType Directory
            Set-Content -Path $ScriptFullName -Value '$script:ImportedScript = "ScriptFromSolution"' -Force
            Mock Get-SolutionProjects { return @() }
            Mock Get-SolutionPackages { return @() }

            # Act
            Import-File ScriptFrom.Solution "scripts"
        }

        It "imports the script" {
            $script:ImportedScript | Should Be "ScriptFromSolution"
        }

        AfterAll {
            # Cleanup
            Remove-Variable ImportedScript -Scope Script
            Remove-File $ScriptFullName
        }
    }

    Context "Task defined in a Pask project" {
        BeforeAll {
            # Arrange
            $script:ImportedTask = ""
            $PaskProjectName = "Pask.Project"
            $PaskProjectFullPath = Join-Path $TestDrive $PaskProjectName
            Mock Get-SolutionProjects { 
                $Result = @()
                $Result += New-Object PSObject -Property @{ Name = $PaskProjectName; Directory = $PaskProjectFullPath }
                return $Result
            }
            $TaskFullName = Join-Path $PaskProjectFullPath "tasks\TaskFrom-PaskProject.ps1"
            New-Item -Path (Join-Path $PaskProjectFullPath "tasks") -ItemType Directory
            Set-Content -Path $TaskFullName -Value '$script:ImportedTask = "TaskFromPaskProject"' -Force
            Mock Get-SolutionPackages { return @() }

            # Act
            Import-File TaskFrom-PaskProject "tasks"
        }

        It "imports the task" {
            $script:ImportedTask | Should Be "TaskFromPaskProject"
        }

        AfterAll {
            # Cleanup
            Remove-Variable ImportedTask -Scope Script
            Remove-File $TaskFullName
        }
    }

    Context "Script defined in a Pask package" {
        BeforeAll {
            # Arrange
            $script:ImportedScript = ""
            $PaskPackageName = "Pask.Package"
            Mock Get-SolutionPackages {
                $Result = @()
                $Result += New-Object PSObject -Property @{ id = $PaskPackageName; version = "1.0.0" }
                return $Result
            }
            $PackageFullPath = (Join-Path $TestDrive "packages\$PaskPackageName.1.0.0")
            $ScriptFullName = Join-Path $PackageFullPath "scripts\ScriptFrom.PaskPackage.ps1"
            New-Item -Path (Join-Path $PackageFullPath "scripts") -ItemType Directory
            Set-Content -Path $ScriptFullName -Value '$script:ImportedScript = "ScriptFromPaskPackage"' -Force
            Mock Get-PackageDir { return $PackageFullPath } -ParameterFilter { $PackageId -eq $PaskPackageName }
            Mock Get-SolutionProjects { return @() }

            # Act
            Import-File ScriptFrom.PaskPackage "scripts"
        }

        It "imports the script" {
            $script:ImportedScript | Should Be "ScriptFromPaskPackage"
        }

        AfterAll {
            # Cleanup
            Remove-Variable ImportedScript -Scope Script
            Remove-File $ScriptFullName
        }
    }

    Context "Task imported multiple times" {
        BeforeAll {
            # Arrange
            $script:ImportedTaskCount = 0
            $PaskPackageName = "Pask.Package"
            Mock Get-SolutionPackages {
                $Result = @()
                $Result += New-Object PSObject -Property @{ id = $PaskPackageName; version = "1.0.0" }
                return $Result
            }
            $PackageFullPath = (Join-Path $TestDrive "packages\$PaskPackageName.1.0.0")
            $TaskFullName = Join-Path $PackageFullPath "tasks\TaskFrom-PaskPackage.ps1"
            New-Item -Path (Join-Path $PackageFullPath "tasks") -ItemType Directory
            Set-Content -Path $TaskFullName -Value '$script:ImportedTaskCount += 1' -Force
            Mock Get-PackageDir { return $PackageFullPath } -ParameterFilter { $PackageId -eq $PaskPackageName }
            Mock Get-SolutionProjects { return @() }

            # Act
            Import-File TaskFrom-PaskPackage, TaskFrom-PaskPackage "tasks"
            Import-File TaskFrom-PaskPackage "tasks"
        }

        It "imports the task once" {
            $script:ImportedTaskCount | Should Be 1
        }

        AfterAll {
            # Cleanup
            Remove-Variable ImportedTaskCount -Scope Script
            Remove-File $TaskFullName
        }
    }

    Context "Script defined in a Pask package and overridden in the build directory" {
        BeforeAll {
            # Arrange
            $script:ImportedScript = ""
            $script:ImportedScriptCount = 0
            # Stub build directory
            $ScriptFullName = Join-Path $BuildFullPath "scripts\Script.Override.ps1"
            New-Item -Path (Join-Path $BuildFullPath "scripts") -ItemType Directory
            Set-Content -Path $ScriptFullName -Value '$script:ImportedScript = "ScriptFromSolution"; $script:ImportedScriptCount += 1' -Force
            # Stub Pask package
            $PaskPackageName = "Pask.Package"
            Mock Get-SolutionPackages {
                $Result = @()
                $Result += New-Object PSObject -Property @{ id = $PaskPackageName; version = "1.0.0" }
                return $Result
            }
            $PackageFullPath = (Join-Path $TestDrive "packages\$PaskPackageName.1.0.0")
            $PackageScriptFullName = Join-Path $PackageFullPath "scripts\Script.Override.ps1"
            New-Item -Path (Join-Path $PackageFullPath "scripts") -ItemType Directory
            Set-Content -Path $PackageScriptFullName -Value '$script:ImportedScript = "ScriptFromPaskPackage"; $script:ImportedScriptCount += 1' -Force
            Mock Get-PackageDir { return $PackageFullPath } -ParameterFilter { $PackageId -eq $PaskPackageName }
            # No solution projects
            Mock Get-SolutionProjects { return @() }

            # Act
            Import-File Script.Override "scripts"
        }

        It "the script in the build directory overrides the script in the Pask package" {
            $script:ImportedScript | Should Be "ScriptFromSolution"
        }

        It "imports both scripts from the package and build directory" {
            $script:ImportedScriptCount | Should Be 2
        }

        AfterAll {
            # Cleanup
            Remove-Variable ImportedScript, ImportedScriptCount -Scope Script
            Remove-File $ScriptFullName, $PackageScriptFullName
        }
    }

    Context "Task defined in a Pask project and overridden in the build directory" {
        BeforeAll {
            # Arrange
            $script:ImportedTask = ""
            $script:ImportedTaskCount = 0
            # Stub build directory
            $TaskFullName = Join-Path $BuildFullPath "tasks\Task-Override.ps1"
            New-Item -Path (Join-Path $BuildFullPath "tasks") -ItemType Directory
            Set-Content -Path $TaskFullName -Value '$script:ImportedTask = "TaskFromSolution"; $script:ImportedTaskCount += 1' -Force
            # Stub Pask project
            $PaskProjectName = "Pask.Project"
            $PaskProjectFullPath = Join-Path $TestDrive $PaskProjectName
            Mock Get-SolutionProjects { 
                $Result = @()
                $Result += New-Object PSObject -Property @{ Name = $PaskProjectName; Directory = $PaskProjectFullPath }
                return $Result
            }
            $PaskProjectTaskFullName = Join-Path $PaskProjectFullPath "tasks\Task-Override.ps1"
            New-Item -Path (Join-Path $PaskProjectFullPath "tasks") -ItemType Directory
            Set-Content -Path $PaskProjectTaskFullName -Value '$script:ImportedTask = "TaskFromPaskProject"; $script:ImportedTaskCount += 1' -Force
            # No solution projects
            Mock Get-SolutionPackages { return @() }

            # Act
            Import-File Task-Override "tasks"
        }

        It "uses the task in the build directory" {
            $script:ImportedTask | Should Be "TaskFromSolution"
        }

        It "imports both tasks from the project and the build directory" {
            $script:ImportedTaskCount | Should Be 2
        }

        AfterAll {
            # Cleanup
            Remove-Variable ImportedTask, ImportedTaskCount -Scope Script
            Remove-File $TaskFullName, $PaskProjectTaskFullName
        }
    }

    Context "Script defined in a Pask package and overridden in a Pask project" {
        BeforeAll {
            # Arrange
            $script:ImportedScript = ""
            $script:ImportedScriptCount = 0
            # Stub Pask project
            $PaskProjectName = "Pask.Project"
            $PaskProjectFullPath = Join-Path $TestDrive $PaskProjectName
            Mock Get-SolutionProjects { 
                $Result = @()
                $Result += New-Object PSObject -Property @{ Name = $PaskProjectName; Directory = $PaskProjectFullPath }
                return $Result
            }
            $ProjectScriptFullName = Join-Path $PaskProjectFullPath "scripts\Script.Override.ps1"
            New-Item -Path (Join-Path $PaskProjectFullPath "scripts") -ItemType Directory
            Set-Content -Path $ProjectScriptFullName -Value '$script:ImportedScript = "ScriptFromPaskProject"; $script:ImportedScriptCount += 1' -Force
            # Stub Pask package
            $PaskPackageName = "Pask.Package"
            Mock Get-SolutionPackages {
                $Result = @()
                $Result += New-Object PSObject -Property @{ id = $PaskPackageName; version = "1.0.0" }
                return $Result
            }
            $PackageFullPath = (Join-Path $TestDrive "packages\$PaskPackageName.1.0.0")
            $PackageScriptFullName = Join-Path $PackageFullPath "scripts\Script.Override.ps1"
            New-Item -Path (Join-Path $PackageFullPath "scripts") -ItemType Directory
            Set-Content -Path $PackageScriptFullName -Value '$script:ImportedScript = "ScriptFromPaskPackage"; $script:ImportedScriptCount += 1' -Force
            Mock Get-PackageDir { return $PackageFullPath } -ParameterFilter { $PackageId -eq $PaskPackageName }

            # Act
            Import-File Script.Override "scripts"
        }

        It "the script in the Pask project overrides the script in the Pask package" {
            $script:ImportedScript | Should Be "ScriptFromPaskProject"
        }

        It "imports both scripts from package and project" {
            $script:ImportedScriptCount | Should Be 2
        }

        AfterAll {
            # Cleanup
            Remove-Variable ImportedScript, ImportedScriptCount -Scope Script
            Remove-File $ProjectScriptFullName, $PackageScriptFullName
        }
    }

    Context "Import all of six tasks defined in the solution's build directory, Pask project and package" {
        BeforeAll {
            # Arrange
            $script:ImportedFirstTask = ""
            $script:ImportedSecondTask = ""
            $script:ImportedThirdTask = ""
            $script:ImportedFourthTask = ""
            $script:ImportedFifthTask = ""
            $script:ImportedSixthTask = ""
            # Build directory
            New-Item -Path (Join-Path $BuildFullPath "tasks") -ItemType Directory
            $FirstTaskFullName = Join-Path $BuildFullPath "tasks\TaskFrom-SolutionFirst.ps1"
            Set-Content -Path $FirstTaskFullName -Value '$script:ImportedFirstTask = "FirstTaskFromSolution"' -Force
            $SecondTaskFullName = Join-Path $BuildFullPath "tasks\TaskFrom-SolutionSecond.ps1"
            Set-Content -Path $SecondTaskFullName -Value '$script:ImportedSecondTask = "SecondTaskFromSolution"' -Force
            # Stub Pask project
            $PaskProjectName = "Pask.Project"
            $PaskProjectFullPath = Join-Path $TestDrive $PaskProjectName
            Mock Get-SolutionProjects { 
                $Result = @()
                $Result += New-Object PSObject -Property @{ Name = $PaskProjectName; Directory = $PaskProjectFullPath }
                return $Result
            }
            New-Item -Path (Join-Path $PaskProjectFullPath "tasks") -ItemType Directory
            $PaskProjectFirstTaskFullName = Join-Path $PaskProjectFullPath "tasks\FirstTaskFrom-Project.ps1"
            Set-Content -Path $PaskProjectFirstTaskFullName -Value '$script:ImportedThirdTask = "FirstTaskFromPaskProject"' -Force
            $PaskProjectSecondTaskFullName = Join-Path $PaskProjectFullPath "tasks\SecondTaskFrom-Project.ps1"
            Set-Content -Path $PaskProjectSecondTaskFullName -Value '$script:ImportedFourthTask = "SecondTaskFromPaskProject"' -Force
            # Stub Pask package
            $PaskPackageName = "Pask.Package"
            Mock Get-SolutionPackages {
                $Result = @()
                $Result += New-Object PSObject -Property @{ id = $PaskPackageName; version = "1.0.0" }
                return $Result
            }
            $PackageFullPath = (Join-Path $TestDrive "packages\$PaskPackageName.1.0.0")
            New-Item -Path (Join-Path $PackageFullPath "tasks") -ItemType Directory
            $PaskPackageFirstTaskFullName = Join-Path $PackageFullPath "tasks\FirstTaskFrom-Package.ps1"
            Set-Content -Path $PaskPackageFirstTaskFullName -Value '$script:ImportedFifthTask = "FirstTaskFromPaskPackage"' -Force
            $PaskPackageSecondTaskFullName = Join-Path $PackageFullPath "tasks\SecondTaskFrom-Package.ps1"
            Set-Content -Path $PaskPackageSecondTaskFullName -Value '$script:ImportedSixthTask = "SecondTaskFromPaskPackage"' -Force
            Mock Get-PackageDir { return $PackageFullPath } -ParameterFilter { $PackageId -eq $PaskPackageName }

            # Act
            Import-File * "tasks"
        }

        It "imports the first task" {
            $script:ImportedFirstTask | Should Be "FirstTaskFromSolution"
        }

        It "imports the second task" {
            $script:ImportedSecondTask | Should Be "SecondTaskFromSolution"
        }

        It "imports the third task" {
            $script:ImportedThirdTask | Should Be "FirstTaskFromPaskProject"
        }

        It "imports the fourth task" {
            $script:ImportedFourthTask | Should Be "SecondTaskFromPaskProject"
        }

        It "imports the fifth task" {
            $script:ImportedFifthTask | Should Be "FirstTaskFromPaskPackage"
        }

        It "imports the sixth task" {
            $script:ImportedSixthTask | Should Be "SecondTaskFromPaskPackage"
        }

        AfterAll {
            # Cleanup
            Remove-Variable ImportedFirstTask, ImportedSecondTask, ImportedThirdTask, ImportedFourthTask, ImportedFifthTask, ImportedSixthTask -Scope Script
            Remove-File $FirstTaskFullName, $SecondTaskFullName, $PaskProjectFirstTaskFullName, $PaskProjectSecondTaskFullName, $PaskPackageFirstTaskFullName, $PaskPackageSecondTaskFullName
        }
    }

    Context "Import a script explicitly from a Pask project" {
        BeforeAll {
            # Arrange
            $script:ImportedScript = ""
            $script:ImportedScriptCount = 0
            # Stub build output directory
            $ScriptFullName = Join-Path $BuildFullPath "scripts\CustomScript.ps1"
            New-Item -Path (Join-Path $BuildFullPath "scripts") -ItemType Directory
            Set-Content -Path $ScriptFullName -Value '$script:ImportedScript = "ScriptFromSolution; $script:ImportedScriptCount += 1"' -Force
            # Stub Pask project
            $PaskProjectName = "Pask.Project"
            $PaskProjectFullPath = Join-Path $TestDrive $PaskProjectName
            Mock Get-SolutionProjects { 
                $Result = @()
                $Result += New-Object PSObject -Property @{ Name = $PaskProjectName; Directory = $PaskProjectFullPath }
                return $Result
            }
            $ProjectScriptFullName = Join-Path $PaskProjectFullPath "scripts\CustomScript.ps1"
            New-Item -Path (Join-Path $PaskProjectFullPath "scripts") -ItemType Directory
            Set-Content -Path $ProjectScriptFullName -Value '$script:ImportedScript = "ScriptFromPaskProject"; $script:ImportedScriptCount += 1' -Force
            # Stub Pask package
            $PaskPackageName = "Pask.Package"
            Mock Get-SolutionPackages {
                $Result = @()
                $Result += New-Object PSObject -Property @{ id = $PaskPackageName; version = "1.0.0" }
                return $Result
            }
            $PackageFullPath = (Join-Path $TestDrive "packages\$PaskPackageName.1.0.0")
            $PackageScriptFullName = Join-Path $PackageFullPath "scripts\CustomScript.ps1"
            New-Item -Path (Join-Path $PackageFullPath "scripts") -ItemType Directory
            Set-Content -Path $PackageScriptFullName -Value '$script:ImportedScript = "ScriptFromPaskPackage"; $script:ImportedScriptCount += 1' -Force
            Mock Get-PackageDir { return $PackageFullPath } -ParameterFilter { $PackageId -eq $PaskPackageName }

            # Act
            Import-File CustomScript "scripts" -Project Pask.Project
        }

        It "the script in the Pask project is imported" {
            $script:ImportedScript | Should Be "ScriptFromPaskProject"
        }

        It "imports only the script from the project" {
            $script:ImportedScriptCount | Should Be 1
        }

        AfterAll {
            # Cleanup
            Remove-Variable ImportedScript, ImportedScriptCount -Scope Script
            Remove-File $ScriptFullName, $ProjectScriptFullName, $PackageScriptFullName
        }
    }

    Context "Import a task explicitly from a Pask package" {
        BeforeAll {
            # Arrange
            $script:ImportedTask = ""
            $script:ImportedTaskCount = 0
            # Stub build output directory
            $TaskFullName = Join-Path $BuildFullPath "tasks\Task-Custom.ps1"
            New-Item -Path (Join-Path $BuildFullPath "tasks") -ItemType Directory
            Set-Content -Path $TaskFullName -Value '$script:ImportedTask = "TaskFromSolution; $script:ImportedTaskCount += 1"' -Force
            # Stub Pask project
            $PaskProjectName = "Pask.Project"
            $PaskProjectFullPath = Join-Path $TestDrive $PaskProjectName
            Mock Get-SolutionProjects { 
                $Result = @()
                $Result += New-Object PSObject -Property @{ Name = $PaskProjectName; Directory = $PaskProjectFullPath }
                return $Result
            }
            $ProjectTaskFullName = Join-Path $PaskProjectFullPath "tasks\Task-Custom.ps1"
            New-Item -Path (Join-Path $PaskProjectFullPath "tasks") -ItemType Directory
            Set-Content -Path $ProjectTaskFullName -Value '$script:ImportedTask = "TaskFromPaskProject"; $script:ImportedTaskCount += 1' -Force
            # Stub Pask package
            $PaskPackageName = "Pask.Package"
            Mock Get-SolutionPackages {
                $Result = @()
                $Result += New-Object PSObject -Property @{ id = $PaskPackageName; version = "1.0.0" }
                return $Result
            }
            $PackageFullPath = (Join-Path $TestDrive "packages\$PaskPackageName.1.0.0")
            $PackageTaskFullName = Join-Path $PackageFullPath "tasks\Task-Custom.ps1"
            New-Item -Path (Join-Path $PackageFullPath "tasks") -ItemType Directory
            Set-Content -Path $PackageTaskFullName -Value '$script:ImportedTask = "TaskFromPaskPackage"; $script:ImportedTaskCount += 1' -Force
            Mock Get-PackageDir { return $PackageFullPath } -ParameterFilter { $PackageId -eq $PaskPackageName }

            # Act
            Import-File Task-Custom "tasks" -Package Pask.Package
        }

        It "the task in the Pask package is imported" {
            $script:ImportedTask | Should Be "TaskFromPaskPackage"
        }

        It "imports only the task from the package" {
            $script:ImportedTaskCount | Should Be 1
        }

        AfterAll {
            # Cleanup
            Remove-Variable ImportedTask, ImportedTaskCount -Scope Script
            Remove-File $TaskFullName, $ProjectTaskFullName, $PackageTaskFullName
        }
    }

    Context "Import a script explicitly from a Pask project and package" {
        BeforeAll {
            # Arrange
            $script:ImportedScript = ""
            $script:ImportedScriptCount = 0
            # Stub build output directory
            $ScriptFullName = Join-Path $BuildFullPath "scripts\CustomScript.ps1"
            New-Item -Path (Join-Path $BuildFullPath "scripts") -ItemType Directory
            Set-Content -Path $ScriptFullName -Value '$script:ImportedScript = "ScriptFromSolution; $script:ImportedScriptCount += 1"' -Force
            # Stub Pask project
            $PaskProjectName = "Pask.Project"
            $PaskProjectFullPath = Join-Path $TestDrive $PaskProjectName
            Mock Get-SolutionProjects { 
                $Result = @()
                $Result += New-Object PSObject -Property @{ Name = $PaskProjectName; Directory = $PaskProjectFullPath }
                return $Result
            }
            $ProjectScriptFullName = Join-Path $PaskProjectFullPath "scripts\CustomScript.ps1"
            New-Item -Path (Join-Path $PaskProjectFullPath "scripts") -ItemType Directory
            Set-Content -Path $ProjectScriptFullName -Value '$script:ImportedScript = "ScriptFromPaskProject"; $script:ImportedScriptCount += 1' -Force
            # Stub Pask package
            $PaskPackageName = "Pask.Package"
            Mock Get-SolutionPackages {
                $Result = @()
                $Result += New-Object PSObject -Property @{ id = $PaskPackageName; version = "1.0.0" }
                return $Result
            }
            $PackageFullPath = (Join-Path $TestDrive "packages\$PaskPackageName.1.0.0")
            $PackageScriptFullName = Join-Path $PackageFullPath "scripts\CustomScript.ps1"
            New-Item -Path (Join-Path $PackageFullPath "scripts") -ItemType Directory
            Set-Content -Path $PackageScriptFullName -Value '$script:ImportedScript = "ScriptFromPaskPackage"; $script:ImportedScriptCount += 1' -Force
            Mock Get-PackageDir { return $PackageFullPath } -ParameterFilter { $PackageId -eq $PaskPackageName }

            # Act
            Import-File CustomScript "scripts" -Project Pask.Project -Package Pask.Package
        }

        It "the script in the Pask project overrides the script in the Pask package" {
            $script:ImportedScript | Should Be "ScriptFromPaskProject"
        }

        It "imports both the scripst from the project and package" {
            $script:ImportedScriptCount | Should Be 2
        }

        AfterAll {
            # Cleanup
            Remove-Variable ImportedScript, ImportedScriptCount -Scope Script
            Remove-File $ScriptFullName, $ProjectScriptFullName, $PackageScriptFullName
        }
    }
}

Describe "Import-Task" {
    BeforeAll {
        # Arrange
        Mock Import-File {}
    }

    Context "Import a single task" {
        BeforeAll {
            # Act
            Import-Task SingleTask
        }

        It "imports one file" {
            Assert-MockCalled Import-File -ParameterFilter { $File -eq "SingleTask" -and $Path -eq "tasks" }
        }
    }

    Context "Import two tasks from a project" {
        BeforeAll {
            # Act
            Import-Task Task-1, Task-2 -Project Pask-CustomProject
        }

        It "imports two files" {
            Assert-MockCalled Import-File -ParameterFilter { $File.Count -eq 2 -and $File[0] -eq "Task-1" -and $File[1] -eq "Task-2" -and $Path -eq "tasks" -and $Project -eq "Pask-CustomProject" }
        }
    }

    Context "Import two tasks from a package" {
        BeforeAll {
            # Act
            Import-Task Task-1, Task-2 -Package Pask-CustomPackage
        }

        It "imports two files" {
            Assert-MockCalled Import-File -ParameterFilter { $File.Count -eq 2 -and $File[0] -eq "Task-1" -and $File[1] -eq "Task-2" -and $Path -eq "tasks" -and $Package -eq "Pask-CustomPackage" }
        }
    }

    Context "Import a task from both a project and package" {
        BeforeAll {
            # Act
            Import-Task Task-Custom -Project Pask-CustomProject -Package Pask-CustomPackage
        }

        It "imports two files" {
            Assert-MockCalled Import-File -ParameterFilter { $File -eq "Task-Custom" -and $Path -eq "tasks" -and $Project -eq "Pask-CustomProject" -and $Package -eq "Pask-CustomPackage" }
        }
    }

    Context "Import a task from a project with invalid name" {
        It "should error" {
            { Import-Task Task-Custom -Project InvalidProject } | Should Throw 
        }
    }

    Context "Import a task from a package with invalid name" {
        It "should error" {
            { Import-Task Task-Custom -Package InvalidPackage } | Should Throw 
        }
    }
}

Describe "Import-Script" {
    BeforeAll {
        # Arrange
        Mock Import-File {}
    }

    Context "Import a single script" {
        BeforeAll {
            # Act
            Import-Script SingleScript
        }

        It "imports one file" {
            Assert-MockCalled Import-File -ParameterFilter { $File -eq "SingleScript" -and $Path -eq "scripts" -and $Safe -eq $false }
        }
    }

    Context "Import a script safetly" {
        BeforeAll {
            # Act
            Import-Script CustomScript -Safe
        }

        It "imports one file" {
            Assert-MockCalled Import-File -ParameterFilter { $File -eq "CustomScript" -and $Path -eq "scripts" -and $Safe -eq $true }
        }
    }

    Context "Import two scripts from a project" {
        BeforeAll {
            # Act
            Import-Script Script1, Script2 -Project Pask-CustomProject
        }

        It "imports two files" {
            Assert-MockCalled Import-File -ParameterFilter { $File.Count -eq 2 -and $File[0] -eq "Script1" -and $File[1] -eq "Script2" -and $Path -eq "scripts" -and $Project -eq "Pask-CustomProject" -and $Safe -eq $false }
        }
    }

    Context "Import two scripts from a package" {
        BeforeAll {
            # Act
            Import-Script Script1, Script2 -Package Pask-CustomPackage
        }

        It "imports two files" {
            Assert-MockCalled Import-File -ParameterFilter { $File.Count -eq 2 -and $File[0] -eq "Script1" -and $File[1] -eq "Script2" -and $Path -eq "scripts" -and $Package -eq "Pask-CustomPackage" -and $Safe -eq $false }
        }
    }

    Context "Import a script from both a project and package" {
        BeforeAll {
            # Act
            Import-Script CustomScript -Project Pask-CustomProject -Package Pask-CustomPackage
        }

        It "imports two files" {
            Assert-MockCalled Import-File -ParameterFilter { $File -eq "CustomScript" -and $Path -eq "scripts" -and $Project -eq "Pask-CustomProject" -and $Package -eq "Pask-CustomPackage" -and $Safe -eq $false }
        }
    }

    Context "Import a script from a project with invalid name" {
        It "should error" {
            { Import-Script CustomScript -Project InvalidProject } | Should Throw 
        }
    }

    Context "Import a script from a package with invalid name" {
        It "should error" {
            { Import-Script CustomScript -Package InvalidPackage } | Should Throw 
        }
    }
}

Describe "Import-Properties" {
    BeforeAll {
        $PropertiesPath = "scripts\Properties.ps1"
    }

    Context "Import only the current solution properties" {
        BeforeAll {
            # Arrange
            $script:Property = 0
            $BuildFullPath = Join-Path $TestDrive ".build"
            New-Item -Path (Join-Path $BuildFullPath "scripts") -ItemType Directory
            $PropertiesFullPath = Join-Path $BuildFullPath $PropertiesPath
            Set-Content -Path $PropertiesFullPath -Value '$script:Property += 1; $LocalProperty = $true' -Force
            Mock Get-SolutionProjects { return @() }
            Mock Get-SolutionPackages { return @() }

            # Act
            Import-Properties
        }

        It "imports the solution properties" {
            $Property | Should Be 1
        }

        It "does not import local solution properties" {
            $LocalProperty | Should Be $null
        }

        It "should never import the solution properties again" {
            Import-Properties
            $Property | Should Be 1
        }

        AfterAll {
            # Cleanup
            Remove-Variable Property -Scope Script
            Remove-File $PropertiesFullPath
        }
    }

    Context "Import non existent Pask project properties" {
        BeforeAll {
            # Arrange
            $script:Property = 0
            $PaskProjectName = "Pask.Project"
            $PaskProjectFullPath = Join-Path $TestDrive $PaskProjectName
            Mock Get-SolutionProjects { 
                $Result = @()
                $Result += New-Object PSObject -Property @{ Name = $PaskProjectName; Directory = $PaskProjectFullPath }
                return $Result
            }
            New-Item -Path (Join-Path $PaskProjectFullPath "scripts") -ItemType Directory
            $PropertiesFullPath = Join-Path $PaskProjectFullPath $PropertiesPath
            Set-Content -Path $PropertiesFullPath -Value '$script:Property += 1; $LocalProperty = $true' -Force
            Mock Get-SolutionPackages { return @() }

            # Act
            Import-Properties -Project Pask.Project.NonExistent
        }

        It "does not import the project properties" {
            $Property | Should Be 0
        }

        It "does not import local project properties" {
            $LocalProperty | Should Be $null
        }
    }

    Context "Import non existent Pask package properties" {
        BeforeAll {
            # Arrange
            $script:Property = 0
            $PaskPackageName = "Pask.Package"
            Mock Get-SolutionPackages {
                $Result = @()
                $Result += New-Object PSObject -Property @{ id = $PaskPackageName; version = "1.0.0" }
                return $Result
            }
            $PaskPackageFullPath = (Join-Path $TestDrive "packages\$PaskPackageName.1.0.0")
            New-Item -Path (Join-Path $PaskPackageFullPath "scripts") -ItemType Directory
            $PropertiesFullPath = Join-Path $PaskPackageFullPath $PropertiesPath
            Set-Content -Path $PropertiesFullPath -Value '$script:Property += 1; $LocalProperty = $true' -Force
            Mock Get-PackageDir { return $PaskPackageFullPath } -ParameterFilter { $PackageId -eq $PaskPackageName }
            Mock Get-SolutionProjects { return @() }

            # Act
            Import-Properties -Package Pask.Package.NonExistent
        }

        It "does not import the package properties" {
            $Property | Should Be 0
        }

        It "does not import local package properties" {
            $LocalProperty | Should Be $null
        }
    }

    Context "Import Pask project properties" {
        BeforeAll {
            # Arrange
            $script:Property = 0
            $PaskProjectName = "Pask.Project"
            $PaskProjectFullPath = Join-Path $TestDrive $PaskProjectName
            Mock Get-SolutionProjects { 
                $Result = @()
                $Result += New-Object PSObject -Property @{ Name = $PaskProjectName; Directory = $PaskProjectFullPath }
                return $Result
            }
            New-Item -Path (Join-Path $PaskProjectFullPath "scripts") -ItemType Directory
            $PropertiesFullPath = Join-Path $PaskProjectFullPath $PropertiesPath
            Set-Content -Path $PropertiesFullPath -Value '$script:Property += 1; $LocalProperty = $true' -Force
            Mock Get-SolutionPackages { return @() }

            # Act
            Import-Properties -Project Pask.Project
        }

        It "imports the project properties" {
            $Property | Should Be 1
        }

        It "does not import local project properties" {
            $LocalProperty | Should Be $null
        }

        It "should never import the package properties again" {
            Import-Properties -Project Pask.Project
            $Property | Should Be 1
        }

        AfterAll {
            # Cleanup
            Remove-Variable Property -Scope Script
            Remove-File $PropertiesFullPath
        }
    }

    Context "Import Pask package properties" {
        BeforeAll {
            # Arrange
            $script:Property = 0
            $PaskPackageName = "Pask.Package"
            Mock Get-SolutionPackages {
                $Result = @()
                $Result += New-Object PSObject -Property @{ id = $PaskPackageName; version = "1.0.0" }
                return $Result
            }
            $PaskPackageFullPath = (Join-Path $TestDrive "packages\$PaskPackageName.1.0.0")
            New-Item -Path (Join-Path $PaskPackageFullPath "scripts") -ItemType Directory
            $PropertiesFullPath = Join-Path $PaskPackageFullPath $PropertiesPath
            Set-Content -Path $PropertiesFullPath -Value '$script:Property =+ 1; $LocalProperty = $true' -Force
            Mock Get-PackageDir { return $PaskPackageFullPath } -ParameterFilter { $PackageId -eq $PaskPackageName }
            Mock Get-SolutionProjects { return @() }

            # Act
            Import-Properties -Package Pask.Package
        }

        It "imports the package properties" {
            $Property | Should Be 1
        }

        It "does not import local package properties" {
            $LocalProperty | Should Be $null
        }

        It "should never import the package properties again" {
            Import-Properties -Package Pask.Project
            $Property | Should Be 1
        }

        AfterAll {
            # Cleanup
            Remove-Variable Property -Scope Script
            Remove-File $PropertiesFullPath
        }
    }

    Context "Import all properties" {
        BeforeAll {
            # Arrange
            $script:PaskProjectProperty = ""
            $script:PaskPackageProperty = ""
            $script:SolutionProperty = ""
            # Solution property
            $BuildFullPath = Join-Path $TestDrive ".build"
            New-Item -Path (Join-Path $BuildFullPath "scripts") -ItemType Directory
            $SolutionPropertiesFullPath = Join-Path $BuildFullPath $PropertiesPath
            Set-Content -Path $SolutionPropertiesFullPath -Value '$script:SolutionProperty += "imported"' -Force
            # Stub project
            $PaskProjectName = "Pask.Project"
            $PaskProjectFullPath = Join-Path $TestDrive $PaskProjectName
            Mock Get-SolutionProjects { 
                $Result = @()
                $Result += New-Object PSObject -Property @{ Name = $PaskProjectName; Directory = $PaskProjectFullPath }
                return $Result
            }
            New-Item -Path (Join-Path $PaskProjectFullPath "scripts") -ItemType Directory
            $ProjectPropertiesFullPath = Join-Path $PaskProjectFullPath $PropertiesPath
            Set-Content -Path $ProjectPropertiesFullPath -Value '$script:PaskProjectProperty = "imported"' -Force
            # Stub package
            $PaskPackageName = "Pask.Package"
            Mock Get-SolutionPackages {
                $Result = @()
                $Result += New-Object PSObject -Property @{ id = $PaskPackageName; version = "1.0.0" }
                return $Result
            }
            $PaskPackageFullPath = (Join-Path $TestDrive "packages\$PaskPackageName.1.0.0")
            New-Item -Path (Join-Path $PaskPackageFullPath "scripts") -ItemType Directory
            $PackagePropertiesFullPath = Join-Path $PaskPackageFullPath $PropertiesPath
            Set-Content -Path $PackagePropertiesFullPath -Value '$script:PaskPackageProperty = "imported"' -Force
            Mock Get-PackageDir { return $PaskPackageFullPath } -ParameterFilter { $PackageId -eq $PaskPackageName }

            # Act
            Import-Properties -All
        }

        It "imports the solution properties" {
            $script:SolutionProperty | Should Be "imported"
        }

        It "imports the project properties" {
            $script:PaskProjectProperty | Should Be "imported"
        }

        It "imports the package properties" {
            $script:PaskPackageProperty | Should Be "imported"
        }

        AfterAll {
            # Cleanup
            Remove-Variable SolutionProperty, PaskProjectProperty, PaskPackageProperty -Scope Script
            Remove-File $SolutionPropertiesFullPath, $ProjectPropertiesFullPath, $PackagePropertiesFullPath
        }
    }

    Context "Import all undefined properties" {
        BeforeAll {
            $BuildFullPath = Join-Path $TestDrive ".build"
        }

        It "should not error" {
            { Import-Properties -All } | Should Not Throw
        }
    }

    Context "Import non-Pask project properties" {
        It "should error" {
            { Import-Properties -Project NuGet.Project } | Should Throw
        }
    }

    Context "Import non-Pask package properties" {
        It "should error" {
            { Import-Properties -Package NuGet.Package } | Should Throw
        }
    }
}

Describe "Get-Files" {
    Context "By base name" {
        BeforeAll {
            # Arrange
            $File1 = Join-Path $TestDrive "file.ps1"
            Set-Content -Path $File1 -Value "" -Force
            New-Item (Join-Path $TestDrive "scripts") -ItemType Directory
            $File2 = Join-Path $TestDrive (Join-Path "scripts" "file.ps1")
            Set-Content -Path $File2 -Value "" -Force
            Add-File $File1, $File2
        }
        
        It "gets all the files matching the base name" {
            (Get-Files "file").Count | Should Be 2
        }

        AfterAll {
            # Cleanup
            Remove-File $File1, $File2
        }
    }

    Context "By full name" {
        BeforeAll {
            # Arrange
            $File1 = Join-Path $TestDrive "file.ps1"
            Set-Content -Path $File1 -Value "" -Force
            New-Item (Join-Path $TestDrive "scripts") -ItemType Directory
            $File2 = Join-Path $TestDrive (Join-Path "scripts" "file.ps1")
            Set-Content -Path $File2 -Value "" -Force
            Add-File $File1, $File2
        }
        
        It "gets the file matching the full name" {
            Get-Files $File1 | Should Be $File1
        }

        AfterAll {
            # Cleanup
            Remove-File $File1, $File2
        }
    }

    Context "All files" {
        BeforeAll {
            # Arrange
            $ExistingFilesCount = (Get-Files).Count
            $File1 = Join-Path $TestDrive "file.ps1"
            Set-Content -Path $File1 -Value "" -Force
            New-Item (Join-Path $TestDrive "scripts") -ItemType Directory
            $File2 = Join-Path $TestDrive (Join-Path "scripts" "file.ps1")
            Set-Content -Path $File2 -Value "" -Force
            Add-File $File1, $File2
        }
        
        It "gets all the files" {
            (Get-Files).Count | Should Be ($ExistingFilesCount + 2)
        }

        AfterAll {
            # Cleanup
            Remove-File $File1, $File2
        }
    }
}

Describe "Set-Project" {
    BeforeAll {
        # Arrange
        $OriginalProjectName = $ProjectName
        $OriginalProjectFullPath = $ProjectFullPath
        $OriginalProjectFullName = $ProjectFullName
        $OriginalArtifactName = $ArtifactName
        $OriginalArtifactFullPath = $ArtifactFullPath
        $BuildOutputFullPath = Join-Path $TestDrive "output"
        Mock Get-SolutionProjects { 
                $Result = @()
                $Result += New-Object PSObject -Property @{ Name = "Project1"; Directory = (Join-Path $TestDrive "Project1") }
                $Result += New-Object PSObject -Property @{ Name = "Project2"; Directory = (Join-Path $TestDrive "Project2") }
                $Result += New-Object PSObject -Property @{ Name = "Project3"; Directory = (Join-Path $TestDrive "Project3") } 
                return $Result
            }
        Mock Refresh-BuildProperties { }
        Mock Write-BuildMessage { }
    }

    Context "Project explicitly specified" {
        BeforeAll {
            # Arrange
            Mock Get-ProjectFullName { return (Join-Path $TestDrive "Project1/Project1.csproj") }
            Set-BuildProperty -Name ArtifactName -Value $null

            # Act
            Set-Project -Name Foo
        }

        It "should use the first project name" {
            $ProjectName | Should Be "Project1"
        }

        It "should use the first project full path" {
            $ProjectFullPath | Should Be (Join-Path $TestDrive "Project1")
        }

        It "should use the first project full name" {
            $ProjectFullName | Should Be (Join-Path $TestDrive "Project1/Project1.csproj")
        }

        It "should define the artifact name" {
            $ArtifactName | Should Be "Project1"
        }

        It "should define the artifact full path" {
            $ArtifactFullPath | Should Be (Join-Path (Join-Path $TestDrive "output") "Project1")
        }

        It "should refresh the properties" {
            Assert-MockCalled Refresh-BuildProperties -Exactly 1
        }
    }

    Context "Project explicitly specified but not found" {
        BeforeAll {
            # Arrange
            Mock Get-ProjectFullName { return (Join-Path $TestDrive "Project2/Project2.csproj") }
            Set-BuildProperty -Name ArtifactName -Value $null

            # Act
            Set-Project -Name Project2
        }

        It "should use the given project name" {
            $ProjectName | Should Be "Project2"
        }

        It "should use the given project full path" {
            $ProjectFullPath | Should Be (Join-Path $TestDrive "Project2")
        }

        It "should use the given project full name" {
            $ProjectFullName | Should Be (Join-Path $TestDrive "Project2/Project2.csproj")
        }

        It "should define the artifact name" {
            $ArtifactName | Should Be "Project2"
        }

        It "should define the artifact full path" {
            $ArtifactFullPath | Should Be (Join-Path (Join-Path $TestDrive "output") "Project2")
        }

        It "should refresh the properties" {
            Assert-MockCalled Refresh-BuildProperties -Exactly 1
        }
    }

    Context "Custom artifact name" {
        BeforeAll {
            # Arrange
            Mock Get-ProjectFullName { return (Join-Path $TestDrive "Project1/Project1.csproj") }
            Set-BuildProperty -Name ArtifactName -Value $null
            $ArtifactName = "OtherProject"

            # Act
            Set-Project -Name Foo
        }

        It "should define the artifact name" {
            $ArtifactName | Should Be "OtherProject"
        }

        It "should define the artifact full path" {
            $ArtifactFullPath | Should Be (Join-Path (Join-Path $TestDrive "output") "OtherProject")
        }
    }

    AfterAll {
        # Cleanup
        Set-BuildProperty -Name ProjectName -Value $OriginalProjectName
        Set-BuildProperty -Name ProjectFullPath -Value $OriginalProjectFullPath
        Set-BuildProperty -Name ProjectFullName -Value $OriginalProjectFullName
        Set-BuildProperty -Name ArtifactName -Value $OriginalArtifactName
        Set-BuildProperty -Name ArtifactFullPath -Value $OriginalArtifactFullPath
    }
}

Describe "Remove-PdbFiles" {
    Context "Remove PDB files from existing path" {
        BeforeAll {
            # Arrange
            Set-Content -Path (Join-Path $TestDrive "foo.pdb") -Value "" -Force
            New-Item -Path (Join-Path $TestDrive "foo") -ItemType Directory
            Set-Content -Path (Join-Path $TestDrive "foo\bar.pdb") -Value "" -Force
            New-Item -Path (Join-Path $TestDrive "foo\bar") -ItemType Directory
            Set-Content -Path (Join-Path $TestDrive "foo\bar\foobar.pdb") -Value "" -Force

            # Act
            Remove-PdbFiles $TestDrive
        }

        It "removes PDB files in the root path" {
            Join-Path $TestDrive "foo.pdb" | Should Not Exist
        }

        It "removes PDB files in a sub-directory" {
            Join-Path $TestDrive "foo\bar.pdb" | Should Not Exist
        }

        It "removes PDB files in a sub-sub-directory" {
            Join-Path $TestDrive "foo\bar\foobar.pdb" | Should Not Exist
        }
    }

    Context "Remove PDB files from non existing path" {
        It "should error" {
            { Remove-PdbFiles (Join-Path $TestDrive "foobar") } | Should Throw 
        }
    }
}

Describe "Get-ProjectBuildOutputDir" {
    BeforeAll {
        # Arrange
        Mock Import-Script { } -ParameterFilter { $Script -eq "Properties.MSBuild" -and $Package -eq "Pask" }
        Mock Get-SolutionProjects { 
            $Result = @()
            $Result += New-Object PSObject -Property @{ Name = "Project1"; Directory = (Join-Path $TestDrive "Project1") }
            $Result += New-Object PSObject -Property @{ Name = "Project2"; Directory = (Join-Path $TestDrive "Project2") }
            $Result += New-Object PSObject -Property @{ Name = "Project3"; Directory = (Join-Path $TestDrive "Project3") } 
            return $Result
        }
    }

    Context "Get build output directories for three projects" {
        BeforeAll {
            # Arrange
            $BuildConfiguration = "Release"
            Get-SolutionProjects | ForEach -Process { New-Directory (Join-Path $_.Directory "bin\Release") | Out-Null }

            # Act
            $Result = @("Project1", "Project2", "Project3") | Get-ProjectBuildOutputDir
        }

        It "imports the MSBuild properties" {
            Assert-MockCalled Import-Script
        }

        It "returns three build output directories" {
            $Result.Count | Should Be 3
        }

        It "returns the first project's build output directory" {
            $Result[0] | Should Be (Join-Path $TestDrive "Project1\bin\Release")
        }

        It "returns the second project's build output directory" {
            $Result[1] | Should Be (Join-Path $TestDrive "Project2\bin\Release")
        }

        It "returns the third project's build output directory" {
            $Result[2] | Should Be (Join-Path $TestDrive "Project3\bin\Release")
        }
    }

    Context "The project was built specifying configuration and platform" {
        BeforeAll {
            # Arrange
            $BuildConfiguration = "CustomConfiguration"
            $BuildPlatform = "x86"
            New-Directory (Join-Path $TestDrive "Project2\bin\x86\CustomConfiguration") | Out-Null

            # Act
            $Result = Get-ProjectBuildOutputDir "Project2"
        }

        It "imports the MSBuild properties" {
            Assert-MockCalled Import-Script
        }

        It "returns the project ouptut directory" {
            $Result | Should Be (Join-Path $TestDrive "Project2\bin\x86\CustomConfiguration")
        }
    }

    Context "The project was built specifying configuration" {
        BeforeAll {
            # Arrange
            $BuildConfiguration = "Release"
            New-Directory (Join-Path $TestDrive "Project2\bin\$BuildConfiguration") | Out-Null

            # Act
            $Result = Get-ProjectBuildOutputDir "Project2"
        }

        It "imports the MSBuild properties" {
            Assert-MockCalled Import-Script
        }

        It "returns the project ouptut directory" {
            $Result | Should Be (Join-Path $TestDrive "Project2\bin\Release")
        }
    }

    Context "The project is a web application" {
        BeforeAll {
            # Arrange
            $BuildConfiguration = "Release"
            New-Directory (Join-Path $TestDrive "Project2\bin") | Out-Null

            # Act
            $Result = Get-ProjectBuildOutputDir "Project2"
        }

        It "imports the MSBuild properties" {
            Assert-MockCalled Import-Script
        }

        It "returns the project ouptut directory" {
            $Result | Should Be (Join-Path $TestDrive "Project2\bin")
        }
    }

    Context "The projects does not have build output directory" {
        BeforeAll {
            # Arrange
            New-Directory (Join-Path $TestDrive "Project2") | Out-Null

            # Act
            $Result = Get-ProjectBuildOutputDir "Project2"
        }

        It "imports the MSBuild properties" {
            Assert-MockCalled Import-Script
        }

        It "returns empty result" {
            $Result | Should BeNullOrEmpty
        }
    }

    Context "No projects" {
        BeforeAll {
            # Arrange
            $Projects = @()

            # Act
            $Result = $Projects | Get-ProjectBuildOutputDir
        }

        It "imports the MSBuild properties" {
            Assert-MockCalled Import-Script
        }

        It "returns empty result" {
            $Result.Count | Should Be 0
        }
    }

    Context "Non existent project" {
        It "throws an error" {
            { Get-ProjectBuildOutputDir "NonExistentProject" } | Should Throw
        }
    }
}

Describe "Get-Version" {
    BeforeAll {
        # Arrange
        Mock Get-CommitterDate { return (Get-Date -Year 2016 -Month 08 -Day 05 -Hour 07 -Minute 44 -Second 15) }
    }

    Context "In master" {
        BeforeAll {
            # Arrange
            Mock Get-Branch { return @{Name="master";IsMaster=$true} }
        }

        It "returns the year as major version" {
            (Get-Version).Major | Should Be 2016
        }

        It "returns the month as minor version" {
            (Get-Version).Minor | Should Be 8
        }

        It "returns the day/hour/minute/seconds as patch version" {
            (Get-Version).Patch | Should Be 5074415
        }

        It "returns empty pre-release label" {
            (Get-Version).PreReleaseLabel | Should BeNullOrEmpty
        }

        It "returns the day as build number" {
            (Get-Version).Build | Should Be 5
        }

        It "returns the hour/minute/seconds as revision number" {
            (Get-Version).Revision | Should Be 74415
        }

        It "returns the date as semantic version" {
            (Get-Version).SemVer | Should Be "2016.8.5.74415"
        }

        It "returns the date without seconds as assembly semantic version" {
            (Get-Version).AssemblySemVer | Should Be "2016.8.5.744"
        }

        It "returns the semantic version as informational version" {
            (Get-Version).InformationalVersion | Should Be "2016.8.5.74415"
        }
    }

    Context "In a branch" {
        BeforeAll {
            # Arrange
            Mock Get-Branch { return @{Name="new-feature";IsMaster=$false} }
        }

        It "returns the year as major version" {
            (Get-Version).Major | Should Be 2016
        }

        It "returns the month as minor version" {
            (Get-Version).Minor | Should Be 8
        }

        It "returns the day/hour/minute/seconds as patch version" {
            (Get-Version).Patch | Should Be 5074415
        }

        It "returns the branch name as pre-release label" {
            (Get-Version).PreReleaseLabel | Should Be "new-feature"
        }

        It "returns the day as build number" {
            (Get-Version).Build | Should Be 5
        }

        It "returns the hour/minute/seconds as revision number" {
            (Get-Version).Revision | Should Be 74415
        }

        It "returns the date/branch as semantic version" {
            (Get-Version).SemVer | Should Be "2016.8.5.74415-new-feature"
        }

        It "returns the date without seconds as assembly semantic version" {
            (Get-Version).AssemblySemVer | Should Be "2016.8.5.744"
        }

        It "returns the semantic version as informational version" {
            (Get-Version).InformationalVersion | Should Be "2016.8.5.74415-new-feature"
        }
    }
}

Describe "Get-SemanticVersion" {
    Context "Without pre-release label" {
        BeforeAll {
        # Arrange
            $SemanticVersion = "1.4.2"
            Mock Get-Branch { return @{Name="master";IsMaster=$true} }
        }

        It "returns the major version" {
            (Get-SemanticVersion $SemanticVersion).Major | Should Be 1
        }

        It "returns the minor version" {
            (Get-SemanticVersion $SemanticVersion).Minor | Should Be 4
        }

        It "returns the patch version" {
            (Get-SemanticVersion $SemanticVersion).Patch | Should Be 2
        }

        It "returns empty pre-release label" {
            (Get-SemanticVersion $SemanticVersion).PreReleaseLabel | Should BeNullOrEmpty
        }

        It "returns the patch version as build number" {
            (Get-SemanticVersion $SemanticVersion).Build | Should Be 2
        }

        It "returns 0 as revision number" {
            (Get-SemanticVersion $SemanticVersion).Revision | Should Be 0
        }

        It "returns the semantic version" {
            (Get-SemanticVersion $SemanticVersion).SemVer | Should Be "1.4.2"
        }

        It "returns the assembly semantic version" {
            (Get-SemanticVersion $SemanticVersion).AssemblySemVer | Should Be "1.4.2.0"
        }

        It "returns the semantic version as informational version" {
            (Get-SemanticVersion $SemanticVersion).InformationalVersion | Should Be "1.4.2"
        }
    }

    Context "With pre-release label" {
        BeforeAll {
            # Arrange
            $SemanticVersion = "1.4.2-beta01"
            Mock Get-Branch { return @{Name="master";IsMaster=$true} }
        }

        It "returns the major version" {
            (Get-SemanticVersion $SemanticVersion).Major | Should Be 1
        }

        It "returns the minor version" {
            (Get-SemanticVersion $SemanticVersion).Minor | Should Be 4
        }

        It "returns the patch version" {
            (Get-SemanticVersion $SemanticVersion).Patch | Should Be 2
        }

        It "returns the pre-release label" {
            (Get-SemanticVersion $SemanticVersion).PreReleaseLabel | Should Be "beta01"
        }

        It "returns the patch version as build number" {
            (Get-SemanticVersion $SemanticVersion).Build | Should Be 2
        }

        It "returns 0 as revision number" {
            (Get-SemanticVersion $SemanticVersion).Revision | Should Be 0
        }

        It "returns the semantic version" {
            (Get-SemanticVersion $SemanticVersion).SemVer | Should Be "1.4.2-beta01"
        }

        It "returns the assembly semantic version" {
            (Get-SemanticVersion $SemanticVersion).AssemblySemVer | Should Be "1.4.2.0"
        }

        It "returns the semantic version as informational version" {
            (Get-SemanticVersion $SemanticVersion).InformationalVersion | Should Be "1.4.2-beta01"
        }
    }

    Context "In a branch" {
        BeforeAll {
            # Arrange
            $SemanticVersion = "1.4.2"
            Mock Get-Branch { return @{Name="new-feature";IsMaster=$false} }
            Mock Get-CommitterDate { return [DateTime]::new(2016, 11, 12, 11, 35, 20) }
        }

        It "returns the pre-release label with committer date" {
            (Get-SemanticVersion $SemanticVersion).PreReleaseLabel | Should Be "pre20161112113520"
        }

        It "returns the semantic version with committer date" {
            (Get-SemanticVersion $SemanticVersion).SemVer | Should Be "1.4.2-pre20161112113520"
        }

        It "returns the informational version with committer date" {
            (Get-SemanticVersion $SemanticVersion).InformationalVersion | Should Be "1.4.2-pre20161112113520"
        }
    }
}

Describe "Get-ProjectSemanticVersion" {
    Context "Project does not exist" {
        BeforeAll {
            # Arrange
            Mock Get-SolutionProjects { return @() }
        }

        It "should error" {
            { Get-ProjectSemanticVersion } | Should Throw
        }
    }

    Context "Default project without version file" {
        BeforeAll {
            # Arrange
            $ProjectName = "MyProject"
            Mock Get-SolutionProjects { 
                $Result = @()
                $Result += New-Object PSObject -Property @{ Name = "MyProject"; Directory = $TestDrive }
                return $Result
            }
        }

        It "should error" {
            { Get-ProjectSemanticVersion } | Should Throw
        }
    }

    Context "Version file has spaces and new lines" {
        BeforeAll {
            # Arrange
            $ProjectName = "MyProject"
            Mock Get-SolutionProjects { 
                $Result = @()
                $Result += New-Object PSObject -Property @{ Name = "MyProject"; Directory = $TestDrive }
                return $Result
            }
            $VersionText = @"
        
            1.2.0

"@
            Set-Content -Path (Join-Path $TestDrive "version.txt") -Value $VersionText -Force
            Mock Get-SemanticVersion { return "1.2.0" } -ParameterFilter { $SemanticVersion -and $SemanticVersion -eq "1.2.0" }
        }

        It "returns the version" {
            Get-ProjectSemanticVersion | Should Be "1.2.0"
        }
    }
}