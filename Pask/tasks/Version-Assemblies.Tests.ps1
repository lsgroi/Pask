$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
Import-Script Pask.Tests.Infrastructure

Describe "Version-Assemblies" {
    BeforeAll {
        # Arrange
        $TestSolutionFullPath = Join-Path $Here "Version-Assemblies"
        Install-Pask -SolutionFullPath $TestSolutionFullPath
    }

    Context "Version assemblies of a class library" {
        BeforeAll {
            # Arrange
            Remove-ItemSilently (Join-Path $TestSolutionFullPath "ClassLibrary\Properties")
            New-Directory (Join-Path $TestSolutionFullPath "ClassLibrary\Properties") | Out-Null
            Remove-ItemSilently (Join-Path $TestSolutionFullPath "Tests\ClassLibrary.UnitTests\Properties")
            New-Directory (Join-Path $TestSolutionFullPath "Tests\ClassLibrary.UnitTests\Properties")

            $ClassLibraryAssemblyInfo = @"
using System.Reflection;
using System.Runtime.InteropServices;

[assembly: AssemblyTitle("ClassLibrary")]
[assembly: ComVisible(false)]
[assembly: Guid("80a05c69-b481-4053-8cd0-bccf76d02ae5")]
[assembly: AssemblyVersion("1.0.0.0")]
[assembly: AssemblyFileVersion("1.0.0.0")]
[assembly: AssemblyInformationalVersion("1.0.0.0")]
"@
            $ClassLibraryUnitTestsAssemblyInfo = @"
using System.Reflection;
using System.Runtime.InteropServices;

[assembly: AssemblyTitle("ClassLibrary.UnitTests")]
[assembly: ComVisible(false)]
[assembly: Guid("7f0dc8f8-04c3-46de-b2a6-326682345fbd")]
[assembly: AssemblyVersion("1.0.0.0")]
[assembly: AssemblyFileVersion("1.0.0.0")]
[assembly: AssemblyInformationalVersion("1.0.0.0")]
"@
            Set-Content -Path (Join-Path $TestSolutionFullPath "ClassLibrary\Properties\AssemblyInfo.cs") -Value $ClassLibraryAssemblyInfo
            Set-Content -Path (Join-Path $TestSolutionFullPath "Tests\ClassLibrary.UnitTests\Properties\AssemblyInfo.cs") -Value $ClassLibraryUnitTestsAssemblyInfo

            $StubVersion = New-Object PSObject -Property @{
                Major = 3;
                Minor = 2;
                Patch = 1;
                PreReleaseLabel = "";
                Build = 1;
                Revision = 0;
                SemVer = "3.2.1";
                AssemblySemVer = "3.2.1.0";
                InformationalVersion = "3.2.1"
            }

            Invoke-Pask $TestSolutionFullPath -Task Clean, Version-Assemblies, Build -Version ($StubVersion) -ExcludeAssemblyInfo @("Tests\ClassLibrary.IntegrationTests\Properties\AssemblyInfo.cs")
        }

        It "versions the default project assembly" {
            $File = Join-Path $TestSolutionFullPath "ClassLibrary\bin\Debug\ClassLibrary.dll"
            (Get-Item -Path $File | Select -ExpandProperty VersionInfo).FileVersion | Should Be "3.2.1.0"
        }

        It "versions the other projects assemblies" {
            $File = Join-Path $TestSolutionFullPath "Tests\ClassLibrary.UnitTests\bin\Debug\ClassLibrary.UnitTests.dll"
            (Get-Item -Path $File | Select -ExpandProperty VersionInfo).FileVersion | Should Be "3.2.1.0"
        }

        It "does not version excluded assemblies" {
            $File = Join-Path $TestSolutionFullPath "Tests\ClassLibrary.IntegrationTests\bin\Debug\ClassLibrary.IntegrationTests.dll"
            (Get-Item -Path $File | Select -ExpandProperty VersionInfo).FileVersion | Should Be "2.0.0.0"
        }
    }
}