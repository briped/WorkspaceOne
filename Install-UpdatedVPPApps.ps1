<#PSScriptInfo
.VERSION
2025.02.21.0

.GUID
4f5617a2-8c47-4968-b424-61ae0a1d1eb9

.AUTHOR
Brian Schmidt Pedersen

.COMPANYNAME
N/A

.COPYRIGHT
(c) Brian Schmidt Pedersen. All rights reserved.

.LICENSEURI
https://raw.githubusercontent.com/briped/WorkSpaceOne/main/LICENSE

.PROJECTURI
https://github.com/briped/WorkspaceOne

.RELEASENOTES
2024.10.25.0
+ Initial version

2024.10.29.0
+ Added logging
* Minor fixes

2025.02.21.0
* Refactoring. Moving environment specific code to external files/scripts. (untested)
#>
<#
.SYNOPSIS
Force update/install updated apps.

.DESCRIPTION
Will go through updated VPP apps (using notifications) and forcibly install/update the app on all devices where the app is installed.
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
# dot-source config.
. $(Join-Path -Path $PSScriptRoot -ChildPath '.config.ps1')
# dot-source shared code.
. $(Join-Path -Path $PSScriptRoot -ChildPath 'shared.ps1')
WriteLog -Message "Started $($ThisScript.Name)"
Import-Module -Force -Name $Config.Manifest
# Start the stopwatch to measure runtime.
$Stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

# Iterate through all organisations defined in the config.
foreach ($Api in $Config.API) {
    if ($VerbosePreference -ne 'SilentlyContinue' -or $Visual) {
        Write-Host "Accessing API for " -NoNewline -ForegroundColor Cyan
        Write-Host $Api.LocationGroupId -NoNewline -ForegroundColor Yellow
        Write-Host "." -ForegroundColor Cyan
    }
    # Authenticate to the current organisation API.
    $Attributes = $Api.Attributes
    New-Ws1ApiConfig @Attributes

    # Get the latest VPP App Auto Update notifications.
    $Notifications = Get-Ws1Notification -Status Active -PageSize 1000 | 
        Where-Object { $_.CategoryValue -eq 'VPP App Auto Update' }
    if ($VerbosePreference -ne 'SilentlyContinue' -or $Visual) {
        Write-Host "Fetched " -NoNewline -ForegroundColor Cyan
        Write-Host $Notifications.Count -NoNewline -ForegroundColor Yellow
        Write-Host " VPP App Auto Update notifications." -ForegroundColor Cyan
    }
    if ($Notifications.Count -gt 0) {
        $LogMessage = "Fetched $($Notifications.Count) VPP App Auto Update notifications from $($Api.LocationGroupId)."
        WriteLog -Message $LogMessage
    }
    $Retry = @()
    # Iterate through all VPP App Auto Update notifications.
    foreach ($Notification in $Notifications) {
        # Get the notificationdetails.
        $NotificationTime = Get-Date -Date $Notification.GlobalizedCreatedOn
        $NotificationData = $Notification.Data | ConvertFrom-Json
        # Check if auto update is enabled for the app.
        if ($NotificationData.IsAutoUpdateEnabled -ne $true) {
            $LogMessage = "Auto Update is not Enabled for the app '$($NotificationData.AppName)'. Skipping."
            WriteLog -Message $LogMessage
            Write-Verbose -Message $LogMessage
            continue
        }

        # Get all devices with the updated app installed.
        $DeviceWithPurchasedApp = Get-Ws1DeviceWithPurchasedApp -Status Installed -LocationGroupId $Api.LocationGroupId -ApplicationId $NotificationData.AppIdentifier -PageSize 100000

        if ($VerbosePreference -ne 'SilentlyContinue' -or $Visual) {
            Write-Host "Updating " -NoNewline -ForegroundColor Cyan
            Write-Host $NotificationData.AppName -NoNewline -ForegroundColor Yellow
            Write-Host " (" -NoNewline -ForegroundColor Cyan
            Write-Host $NotificationData.AppIdentifier -NoNewline -ForegroundColor Yellow
            Write-Host ") on " -NoNewline -ForegroundColor Cyan
            Write-Host $DeviceWithPurchasedApp.Count -NoNewline -ForegroundColor Magenta
            Write-Host " devices." -ForegroundColor Cyan
        }
        $LogMessage = "Updating $($NotificationData.AppName) (ID: $($NotificationData.AppIdentifier)) on $($DeviceWithPurchasedApp.Count) devices."
        WriteLog -Message $LogMessage
        # Loop through each device that already have the app installed and install the updated version.
        foreach ($DeviceId in $DeviceWithPurchasedApp) {
            try {
                $void = Install-Ws1PurchasedApp -DeviceId $DeviceId -ApplicationId $NotificationData.AppIdentifier
            }
            catch {
                $Device = Get-Ws1Device -Id $DeviceId
                $Retry += New-Object -TypeName PSCustomObject -Property @{
                    AppName = $NotificationData.AppName
                    AppId = $NotificationData.AppIdentifier
                    DeviceName = $Device.DeviceFriendlyName
                    DeviceId = $DeviceId
                }
                $LogMessage = "An error occurred trying to update '$($NotificationData.AppName)' with App ID '$($NotificationData.AppIdentifier)' on '$($Device.DeviceFriendlyName)' with Device ID '$($DeviceId)'. Added to retry list."
                Write-Warning -Message $LogMessage
                Write-Warning -Message $_
                WriteLog -Message $LogMessage
                WriteLog -Message $_
            }
        }
        # Clear the notification.
        try {
            $void = Clear-Ws1Notification -Id $Notification.id
        }
        catch {
            $LogMessage = "An error occurred trying to clear the Notification ID '$($Notification.id)'."
            Write-Warning -Message $LogMessage
            Write-Warning -Message $_
            WriteLog -Message $LogMessage
            WriteLog -Message $_
        }
    }
    # Retry failed installations.
    if ($Retry.Count -gt 0) {
        if ($VerbosePreference -ne 'SilentlyContinue' -or $Visual) {
            Write-Host "Retrying " -NoNewline -ForegroundColor Cyan
            Write-Host $Retry.Count -NoNewline -ForegroundColor Yellow
            Write-Host " failed installations." -ForegroundColor Cyan
        }
        $LogMessage = "Retrying $($Retry.Count) failed installations in $($Api.LocationGroupId)."
        WriteLog -Message $LogMessage
        foreach ($r in $Retry) {
            try {
                $void = Install-Ws1PurchasedApp -DeviceId $r.DeviceId -ApplicationId $AppId
            }
            catch {
                $LogMessage = "Installation retry for '$($NotificationData.AppName)' with App ID '$($NotificationData.AppIdentifier)' on '$($Device.DeviceFriendlyName)' with Device ID '$($DeviceId)' failed again."
                Write-Warning -Message $LogMessage
                Write-Warning -Message $_
                WriteLog -Message $LogMessage
                WriteLog -Message $_
            }
        }
    }
}

$Runtime = $Stopwatch.Elapsed.ToString()
$Stopwatch.Stop()
$LogMessage = "Finished $($ThisScript.Name). Runtime: $($Runtime)."
WriteLog -Message $LogMessage
Write-Verbose -Message $LogMessage