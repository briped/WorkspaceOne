<#
.SYNOPSIS
Force update/install updated apps.

.DESCRIPTION
Will go through all purchased apps and check the details against the Apple App Store, and if version is different, forcibly install/update the app on all devices where the app is installed.
This is mainly meant as a workaround for the autoupdate not currently working in WS1.

.NOTES
TODO
.EXAMPLE
TODO
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [switch]$Visual
)
# dot-source shared code.
. $(Join-Path -Path $PSScriptRoot -ChildPath 'shared.ps1')
WriteLog -Message "Started $($ThisScript.Name)"
# Start the stopwatch to measure runtime.
$Stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

# Find all assigned VPP Apps that needs to be autoupdated.
$Apps = Find-Ws1PurchasedApp -Assigned | 
	Where-Object { $_.IsAutoUpdateEnabled -eq $true }
if ($VerbosePreference -ne 'SilentlyContinue' -or $Visual) {
	Write-Host "Checking " -NoNewline -ForegroundColor Cyan
	Write-Host $Apps.Count -NoNewline -ForegroundColor Yellow
	Write-Host " apps." -ForegroundColor Cyan
}
if ($Apps.Count -gt 0) {
	$LogMessage = "Checking $($Apps.Count) apps."
	WriteLog -Message $LogMessage
}
$Retry = @()
# Iterate through apps.
foreach ($App in $Apps) {
	try {
		$AppStoreDetails = Get-Ws1AppStoreDetails -Uri $App.ApplicationUrl
	}
	catch {}
	break
	# Get all devices with the updated app installed.
	$DeviceWithPurchasedApp = Get-Ws1DeviceWithPurchasedApp -Status Installed -ApplicationId $App.Id.Value -PageSize 100000

	if ($VerbosePreference -ne 'SilentlyContinue' -or $Visual) {
		Write-Host "Updating " -NoNewline -ForegroundColor Cyan
		Write-Host $App.ApplicationName -NoNewline -ForegroundColor Yellow
		Write-Host " (" -NoNewline -ForegroundColor Cyan
		Write-Host $App.BundleId -NoNewline -ForegroundColor Yellow
		Write-Host ") (ID: " -NoNewline -ForegroundColor Cyan
		Write-Host $App.Id.Value -NoNewline -ForegroundColor Yellow
		Write-Host ") on " -NoNewline -ForegroundColor Cyan
		Write-Host $DeviceWithPurchasedApp.Count -NoNewline -ForegroundColor Magenta
		Write-Host " devices." -ForegroundColor Cyan
	}
	$LogMessage = "Updating $($App.ApplicationName) ($($App.ApplicationName)) ($($App.Id.Value)) on $($DeviceWithPurchasedApp.Count) devices."
	WriteLog -Message $LogMessage
	# Loop through each device that already have the app installed and install the updated version.
	foreach ($DeviceId in $DeviceWithPurchasedApp) {
		try {
			$void = Install-Ws1PurchasedApp -DeviceId $DeviceId -ApplicationId $App.Id.Value
		}
		catch {
			$Device = Get-Ws1Device -Id $DeviceId
			$Retry += New-Object -TypeName PSCustomObject -Property @{
				AppName = $App.ApplicationName
				AppId = $App.Id.Value
				DeviceName = $Device.DeviceFriendlyName
				DeviceId = $DeviceId
			}
			$LogMessage = "An error occurred trying to update '$($App.ApplicationName)' with App ID '$($App.Id.Value)' on '$($Device.DeviceFriendlyName)' with Device ID '$($DeviceId)'. Added to retry list."
			Write-Warning -Message $LogMessage
			Write-Warning -Message $_
			WriteLog -Message $LogMessage
			WriteLog -Message $_
		}
	}
}
# Retry failed installations.
if ($Retry.Count -gt 0) {
	if ($VerbosePreference -ne 'SilentlyContinue' -or $Visual) {
		Write-Host "Retrying " -NoNewline -ForegroundColor Cyan
		Write-Host $Retry.Count -NoNewline -ForegroundColor Yellow
		Write-Host " failed installations." -ForegroundColor Cyan
	}
	$LogMessage = "Retrying $($Retry.Count) failed installations."
	WriteLog -Message $LogMessage
	foreach ($r in $Retry) {
		try {
			$void = Install-Ws1PurchasedApp -DeviceId $r.DeviceId -ApplicationId $AppId
		}
		catch {
			$LogMessage = "Installation retry for '$($App.ApplicationName)' with App ID '$($App.Id.Value)' on '$($Device.DeviceFriendlyName)' with Device ID '$($DeviceId)' failed again."
			Write-Warning -Message $LogMessage
			Write-Warning -Message $_
			WriteLog -Message $LogMessage
			WriteLog -Message $_
		}
	}
}

$Runtime = $Stopwatch.Elapsed.ToString()
$Stopwatch.Stop()
$LogMessage = "Finished $($ThisScript.Name). Runtime: $($Runtime)."
WriteLog -Message $LogMessage
Write-Verbose -Message $LogMessage