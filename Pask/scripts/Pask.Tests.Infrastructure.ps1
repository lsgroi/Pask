<#
.SYNOPSIS 
   Installs a NuGet package found in $BuildOutputFullPath with a custom version

.PARAMETER Name <string> = Pask
   The package name

.PARAMETER Version <string> = 0.1.0
   The package version

.PARAMETER InstallDir <string> = (Get-PackagesDir)
   The directory in which the package should be installed

.OUTPUTS
   None
#>
function script:Install-NuGetPackage {
    param(
        [string]$Name = "Pask",
        [string]$Version = "0.1.0",
        [string]$InstallDir = (Get-PackagesDir)
    )

    $PackageBaseName = "$Name.$Version"
    $PackageFullPath = Join-Path $InstallDir $PackageBaseName
    $PackageFullName = Join-Path $PackageFullPath "$PackageBaseName.nupkg"
    $ArtifactFullPath = (Get-ChildItem -Path (Join-Path $BuildOutputFullPath "*") -File -Include "$Name*.nupkg" | Select-Object -Last 1).FullName

    Remove-ItemSilently "$PackageFullPath"
    New-Directory -Path "$PackageFullPath" | Out-Null
    Copy-Item "$ArtifactFullPath" "$PackageFullName" -Force | Out-Null
    $7za = Join-Path (Get-PackageDir "7-Zip.CommandLine") "tools\7za.exe"
    Exec { & "$7za" x "$PackageFullName" -aoa "-o$PackageFullPath" | Out-Null }
}

<#
.SYNOPSIS 
   Creates a solution in Visual Studio 2015
   It consists of a ConsoleApplication and a ClassLibrary

.PARAMETER DTE <object>

.PARAMETER Path <string>
   The directory in which the solution shall be created

.PARAMETER Name <string>
   The solution name

.EXAMPLE
   $DTE = New-Object -ComObject "VisualStudio.DTE.14.0"
   New-Solution ([ref]$DTE) "C:\Temp\SolutionDir" "MyTempSolution"

.OUTPUTS
   None
#>
function script:New-Solution {
    param([ref]$DTE, [string]$Path, [string]$Name)

    Register-MessageFilter

    if(-not(Test-Path $Path)) {
        New-Directory $Path | Out-Null
    }

    # Create a NuGet.config defining the local NuGet feed
    $NuGetConfig = "<?xml version=""1.0"" encoding=""utf-8""?><configuration><packageSources><add key=""Local"" value=""$LocalNuGetFeed"" /></packageSources></configuration>"
    Set-Content -Path (Join-Path $Path "NuGet.config") -Value $NuGetConfig -Force

    "Creating solution in $Path"
    $DTE.Value.Solution.Create($Path, $Name)
    $WebApplicationProjectTemplate = $DTE.Value.Solution.GetProjectTemplate("Microsoft.CSharp.ConsoleApplication", "CSharp")
    $DTE.Value.Solution.AddFromTemplate($WebApplicationProjectTemplate, "$(Join-Path $Path $Name)", $Name, $false)
    $ClassLibraryTemplate = $DTE.Value.Solution.GetProjectTemplate("Microsoft.CSharp.ClassLibrary", "CSharp")
    $DTE.Value.Solution.AddFromTemplate($ClassLibraryTemplate, "$(Join-Path $Path "$Name.Core")", "$Name.Core", $false)
    $SolutionFullName = Join-Path $Path "$Name.sln"
    $DTE.Value.Solution.SaveAs($SolutionFullName)
    $DTE.Value.Solution.Open($SolutionFullName)
    try {
        $DTE.Value.MainWindow | % { $_.GetType().InvokeMember("Visible", [System.Reflection.BindingFlags]::SetProperty, $null, $_, $true) }
        $DTE.Value.MainWindow | % { $_.GetType().InvokeMember("SetFocus", [System.Reflection.BindingFlags]::InvokeMethod, $null, $_, $null) }
    } catch {
        $DTE.Value.MainWindow.Visible = $true
        $DTE.Value.MainWindow.SetFocus()
    }
}

<#
.SYNOPSIS 
   Register a COM Message Filter

.OUTPUTS
   None
#>
function script:Register-MessageFilter {
    $source = @"
namespace EnvDteUtils{ 
 
    using System; 
    using System.Runtime.InteropServices; 
    public class MessageFilter : IOleMessageFilter
    {
        //
        // Class containing the IOleMessageFilter
        // thread error-handling functions.
        // Start the filter.
        public static void Register()
        {
            IOleMessageFilter newFilter = new MessageFilter(); 
            IOleMessageFilter oldFilter = null; 
            CoRegisterMessageFilter(newFilter, out oldFilter);
        }
        // Done with the filter, close it.
        public static void Revoke()
        {
            IOleMessageFilter oldFilter = null; 
            CoRegisterMessageFilter(null, out oldFilter);
        }
        //
        // IOleMessageFilter functions.
        // Handle incoming thread requests.
        int IOleMessageFilter.HandleInComingCall(int dwCallType, 
          System.IntPtr hTaskCaller, int dwTickCount, System.IntPtr 
          lpInterfaceInfo) 
        {
            //Return the flag SERVERCALL_ISHANDLED.
            return 0;
        }
        // Thread call was rejected, so try again.
        int IOleMessageFilter.RetryRejectedCall(System.IntPtr 
          hTaskCallee, int dwTickCount, int dwRejectType)
        {
            if (dwRejectType == 2)
            // flag = SERVERCALL_RETRYLATER.
            {
                // Retry the thread call immediately if return >=0 & 
                // <100.
                return 99;
            }
            // Too busy; cancel call.
            return -1;
        }
        int IOleMessageFilter.MessagePending(System.IntPtr hTaskCallee, 
          int dwTickCount, int dwPendingType)
        {
            //Return the flag PENDINGMSG_WAITDEFPROCESS.
            return 2; 
        }
        // Implement the IOleMessageFilter interface.
        [DllImport("Ole32.dll")]
        private static extern int 
          CoRegisterMessageFilter(IOleMessageFilter newFilter, out 
          IOleMessageFilter oldFilter);
    }
    [ComImport(), Guid("00000016-0000-0000-C000-000000000046"), 
    InterfaceTypeAttribute(ComInterfaceType.InterfaceIsIUnknown)]
    interface IOleMessageFilter 
    {
        [PreserveSig]
        int HandleInComingCall( 
            int dwCallType, 
            IntPtr hTaskCaller, 
            int dwTickCount, 
            IntPtr lpInterfaceInfo);
        [PreserveSig]
        int RetryRejectedCall( 
            IntPtr hTaskCallee, 
            int dwTickCount,
            int dwRejectType);
        [PreserveSig]
        int MessagePending( 
            IntPtr hTaskCallee, 
            int dwTickCount,
            int dwPendingType);
    }
}
"@
    Add-Type -TypeDefinition $source
    [EnvDTEUtils.MessageFilter]::Register()
}