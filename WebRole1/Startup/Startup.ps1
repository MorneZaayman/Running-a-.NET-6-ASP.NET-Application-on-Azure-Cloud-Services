# This script must be run with Admistrator privileges in order for .NET 6 to be able to be installed properly

# Following modifies the Write-Verbose behavior to turn the messages on globally for this session
$VerbosePreference = "Continue"
$nl = "`r`n"

Write-Verbose "========== Check cwd and Environment Vars ==========$nl"
Write-Verbose "Current working directory = $(Get-Location)$nl"
Write-Verbose "IsEmulated = $Env:IsEmulated $nl" 

[Boolean]$IsEmulated = [System.Convert]::ToBoolean("$Env:IsEmulated")

# Load the Cloud Service assembly
[Reflection.Assembly]::LoadWithPartialName("Microsoft.WindowsAzure.ServiceRuntime")

## Custom temp path that has a 500 MB limit instead of 100 MB
$tempPath = [Microsoft.WindowsAzure.ServiceRuntime.RoleEnvironment]::GetLocalResource("CustomTempPath").RootPath.TrimEnd('\\')
[Environment]::SetEnvironmentVariable("TEMP", $tempPath, "Machine")
[Environment]::SetEnvironmentVariable("TEMP", $tempPath, "User")


###

Write-Verbose "========== .NET 6 Windows Hosting Installation ==========$nl" 

# This is not reliable as all .NET 1 Core and > have this .exe and Cloud Services appear to ship with it in some OS Versions.
# Commented out for now, but we need a way to check that .NET 6 itself (not another .NET Core 1+ Framework) is installed.
#if (Test-Path "$Env:ProgramFiles\dotnet\dotnet.exe")
#{
#    Write-Verbose ".NET 6 Installed $nl" 
#}
#else
if (!$isEmulated) # skip install on emulator
{
    Write-Verbose ".NET 6 not Installed$nl"

    Write-Verbose "Downloading .NET 6 Installer$nl" 

    $tempPath = [Microsoft.WindowsAzure.ServiceRuntime.RoleEnvironment]::GetLocalResource("CustomTempPath").RootPath.TrimEnd('\\')

	
	# Install the Microsoft Visual C++ 2017 Redistributable first
	$tempFile = New-Item ($tempPath + "\vcredist.exe")
    Invoke-WebRequest -Uri https://aka.ms/vs/16/release/vc_redist.x64.exe -OutFile $tempFile

    $proc = (Start-Process $tempFile -PassThru "/quiet /install /log C:\Logs\vcredist.x64.log")
    $proc | Wait-Process
	

	# Get and install the hosting module
	$tempFile = New-Item ($tempPath + "\netcore-sh.exe")
    Invoke-WebRequest -Uri https://download.visualstudio.microsoft.com/download/pr/c5971600-d95e-46b4-b99f-c75dad919237/25469268adf8be3d438355793ecb11da/dotnet-hosting-6.0.0-win.exe -OutFile $tempFile

	$proc = (Start-Process $tempFile -PassThru "/quiet /install /log C:\Logs\dotnet_install.log")
	$proc | Wait-Process
}