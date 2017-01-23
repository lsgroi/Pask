Set-Property Version -Default (Get-Version)

# Push-Local task
Set-Property LocalNuGetFeed -Default "C:\LocalNuGetFeed"

# MSBuild tasks
Set-Property BuildProjectOnly -Default $false
Set-Property Configuration -Default "Debug"
Set-Property MSBuildVersion -Default "14.0"
Set-Property Platform -Default ""
Set-Property WebApplicationOutputPath -Default "obj/WebOut"
