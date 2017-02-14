<img src="https://raw.githubusercontent.com/lsgroi/Pask/master/Pask.png" align="right"/>

# Pask
Task-oriented PowerShell build automation for .NET based on a set of conventions.
It leverages [Invoke-Build](https://github.com/nightroman/Invoke-Build) and it consists of a set of predefined tasks and the ability to create custom ones.

[![Build status](https://ci.appveyor.com/api/projects/status/dnd8oe7sct40a39d?svg=true)](https://ci.appveyor.com/project/LucaSgroi/Pask)
[![NuGet version](https://img.shields.io/nuget/v/pask.svg)](https://www.nuget.org/packages/Pask)

## Getting Started
Pask is shipped as NuGet package and it should be installed via NuGet Package Manager in Visual Studio 2015.  
To run a build, open a PowerShell session and execute the build runner:
```
PS C:\Path_to_your_solution> .\Pask.ps1
```
Check out the [getting started guide](https://github.com/lsgroi/Pask/wiki/Getting-Started).

## What is Pask?
Pask is a modular task-oriented PowerShell build tool for .NET which relies on [Invoke-Build](https://github.com/nightroman/Invoke-Build) DSL (domain specific language). It provides a set of predefined tasks and the ability to easily create custom ones.  
On very simple projects, building and testing the software can be accomplished using the capabilities of your IDE (Integrated Development Environment).
However, this is really only appropriate for the most trivial of tasks.
Soon enough any project would demand more control and so it is vital to script building, testing and packaging activities.  
Pask can target any .NET solution following some basic convention patterns and it can be used at any stage of a Deployment Pipeline.

## Why Pask?
Primarily to make the build process a first class citizen and treat it exactly as the code which is building.
Pask introduces a set of conventions and predefined tasks which reduce the overhead of setting up a build pipeline for new projects.
It allows to catch failed builds earlier by running the same process on a CI server as well as on a development machine.
Pask is designed to be extended to reduce the amount of boilerplate code in your build scripts by creating extensions with single responsibilities.

## Resources
- [Invoke-Build](https://github.com/nightroman/Invoke-Build/wiki)
: Wiki, script tutorials and examples
- [Project Wiki](https://github.com/lsgroi/Pask/wiki)
: Detailed documentation of conventions and patterns
- The project was inspired by [PowerTasks](https://github.com/shaynevanasperen/PowerTasks) and [psakify](https://github.com/SeatwaveOpenSource/psakify)

Pask is Copyright &copy; 2016 Luca Sgroi under the [Apache License](LICENSE.txt).
