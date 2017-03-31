<#
.SYNOPSIS 
   Gets all test projects in the solution matching a name pattern

.PARAMETER Pattern <string> = $TestNamePattern
   A regular expression pattern

.OUTPUTS <object[]>
   ------------------- EXAMPLE -------------------
   @(
      @{
         Name = 'Project.UnitTests'
         File = 'Project.UnitTests.csproj'
         Directory = 'C:\Solution_Dir\Project_Dir'
         Type = 'UnitTests'
      }
   )
#>
function script:Get-SolutionTestProjects {
    param([string]$Pattern = $TestNamePattern)

    Get-SolutionProjects | Where { $_.Name -match $Pattern } | Select Name, File, Directory, @{ Name = "Type"; Expression = { $_.Name -split '\.' | Select -Last 1 } }
}