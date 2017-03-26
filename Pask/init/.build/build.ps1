Import-Task Version-BuildServer, Version-Assemblies, Restore-NuGetPackages, Clean, Build

# Synopsis: Default task
Task . Restore-NuGetPackages, Clean, Build

# Synopsis: Release task
Task Release Version-BuildServer, Restore-NuGetPackages, Clean, Version-Assemblies, Build