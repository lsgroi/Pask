Import-Task Restore-NuGetPackages, Clean, Build, Version-BuildServer, Version-Assemblies

# Synopsis: Default task
Task . Restore-NuGetPackages, Clean, Build

# Synopsis: Release task
Task Release Version-BuildServer, Restore-NuGetPackages, Clean, Version-Assemblies, Build