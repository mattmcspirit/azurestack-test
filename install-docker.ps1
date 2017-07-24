[CmdletBinding()]
Param(
  [switch] $SkipEngineUpgrade,
  [string] $DockerVersion = "17.06.0-ce",
  [string] $DTRFQDN,
  [string] $UcpVersion
)

#Variables
$Date = Get-Date -Format "yyyy-MM-dd HHmmss"
$DockerDataPath = "C:\ProgramData\Docker"

function Disable-RealTimeMonitoring () {
    Set-MpPreference -DisableRealtimeMonitoring $true
}

function Create-RunOnce () {
# Create a Run-Once that will trigger the second configuration script

}

function Install-Container () {
    # Install the OneGet PowerShell module and Use OneGet to install the latest version of Docker.
    Install-Module -Name DockerMsftProvider -Repository PSGallery -Force
    Install-Package -Name docker -ProviderName DockerMsftProvider
    Write-Host "Restarting Computer in 10 seconds"
    Start-Sleep -Seconds 10
    Restart-Computer -Force
}

#Start Script
$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

try
{
    Start-Transcript -path "C:\ProgramData\Docker\install-docker $Date.log" -append

    Write-Host "Disabling Real Time Monitoring"
    Disable-RealTimeMonitoring
    
    Write-Host "Creating RunOnce Registry Entry to Continue after Reboot"
    Disable-RealTimeMonitoring
    
    if (-not ($SkipEngineUpgrade.IsPresent)) {
        Write-Host "Installing Windows Container then rebooting"
	      Install-Container
    }
    Stop-Transcript
}
catch
{
    Write-Error $_
}
