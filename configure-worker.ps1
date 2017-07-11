[CmdletBinding()]
Param(
  [switch] $SkipEngineUpgrade,
  [string] $DockerVersion = "17.06.0-ce",
  [string] $DTRFQDN,
  [string] $HubUsername,
  [string] $HubPassword,
  [string] $UcpVersion
)

#Variables
$Date = Get-Date -Format "yyyy-MM-dd HHmmss"
$DockerDataPath = "C:\ProgramData\Docker"

function Disable-RealTimeMonitoring () {
    Set-MpPreference -DisableRealtimeMonitoring $true
}

function Install-Container () {
    # add Windows Container image
    Install-Module -Name DockerMsftProvider -Repository PSGallery -Force
    Install-Package -Name docker -ProviderName DockerMsftProvider
    Restart-Computer -Force
    docker pull microsoft/windowsservercore
}


function Install-LatestDockerEngine () {
    #Get Docker Engine from Master Builds
    Invoke-WebRequest -Uri "https://download.docker.com/win/static/test/x86_64/docker-17.06.0-ce.zip" -OutFile "docker.zip"

    Stop-Service docker
    Remove-Item -Force -Recurse $env:ProgramFiles\docker
    Expand-Archive -Path "docker.zip" -DestinationPath $env:ProgramFiles -Force
    Remove-Item docker.zip

    Start-Service docker
}

function Disable-Firewall () {
    #Disable firewall (temporary)
    Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False

    #Ensure public profile is disabled (solves public profile not persisting issue)
    $data = netsh advfirewall show publicprofile
    $data = $data[3]
    if ($data -Match "ON"){
        Set-NetFirewallProfile -Profile Public -Enabled False
    }
}

function Set-DtrHostnameEnvironmentVariable() {
    $DTRFQDN | Out-File (Join-Path $DockerDataPath "dtr_fqdn")
}

function Get-UcpImages() {
    docker login -p $HubPassword -u $HubUsername
    docker pull dockerorcadev/ucp-dsinfo-win:$UcpVersion
    docker pull dockerorcadev/ucp-agent-win:$UcpVersion

    Add-Content setup.ps1 $(docker run --rm dockerorcadev/ucp-agent-win:$UcpVersion windows-script --image-version dev:)
    & .\setup.ps1
    Remove-Item -Force setup.ps1
}

#Start Script
$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

try
{
    Start-Transcript -path "C:\ProgramData\Docker\configure-worker $Date.log" -append

    Write-Host "Disabling Real Time Monitoring"
    Disable-RealTimeMonitoring
    
    if (-not ($SkipEngineUpgrade.IsPresent)) {
        Write-Host "Installing Windows Container"
	Install-Container
        Write-Host "Upgrading Docker Engine"
        Install-LatestDockerEngine
    }

    Write-Host "Getting UCP Images"
    Get-UcpImages

    Write-Host "Disabling Firewall"
    Disable-Firewall

    Write-Host "Set DTR FQDN Environment Variable"
    Set-DtrHostnameEnvironmentVariable

    Stop-Transcript
}
catch
{
    Write-Error $_
}
