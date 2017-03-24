Pask - Modular build automation for .NET
https://github.com/lsgroi/Pask/wiki


Version 0.15.0
-------------------------------------------------------------------------------------
- Modify local NuGet feed
- Improve functions New-Directory and Remove-ItemSilently to take an array of items
  and take parameters from pipeline

Version 0.14.0
-------------------------------------------------------------------------------------
- Explicitly ignore NuGet.exe so the latest version is always used

Version 0.13.0
-------------------------------------------------------------------------------------
- Expose the ability to test a package installation

Version 0.12.0
-------------------------------------------------------------------------------------
- Automatically add scripts and tasks to solution during installation

Version 0.11.0
-------------------------------------------------------------------------------------
- Full support for custom solution name and path
- Improvements to package installation

Version 0.10.0
-------------------------------------------------------------------------------------
- Create tasks directory during package installation
- Project template now installs automatically the latest version of Pask
- Solve a bug for which build wasn't running outside for non git repository

Version 0.9.0
-------------------------------------------------------------------------------------
- Move task specific properties close to task definitions

Version 0.8.0
-------------------------------------------------------------------------------------
- It is now possible to import a task/script from a specific project/package only

Version 0.7.0
-------------------------------------------------------------------------------------
- Add Version-Assemblies task

Version 0.6.0
-------------------------------------------------------------------------------------
- Add Zip-Artifact and Extract-Artifact tasks

Version 0.5.0
-------------------------------------------------------------------------------------
- Add New-Artifact task

Version 0.4.0
-------------------------------------------------------------------------------------
- Add Build-WebApplication and Build-WebDeployPackage task
- Change default task to additionally clean and build the solution

Version 0.3.0
-------------------------------------------------------------------------------------
- Add Build task
- Easily refresh all build properties after setting one
- Update logo