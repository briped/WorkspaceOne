$Manifest = [System.IO.FileInfo](Join-Path -Path $PSScriptRoot -ChildPath 'WorkspaceOneShell.psd1')
Import-Module -Force -Name $Manifest

$ConfigFile = "$($Env:USERPROFILE)\.ws1config_$($Env:USERNAME)@$($Env:COMPUTERNAME).xml"
$Config = if (Test-Path -PathType Leaf -Path $ConfigFile) { Get-Ws1ApiConfig -Verbose -Path $ConfigFile } else { Get-Ws1ApiConfig }
$Script:Headers = Get-Ws1ApiHeader -Url $Config.ApiUrl -Key $Config.ApiCredential -Credential $Config.Ws1Credential


<# MAM (Mobile Application Management) REST API V1+V2
GET
/mam/apps/purchased/{applicationId/ApplicationUuid}

V2/UUID doesn't work when calling from PowerShell.
Param block for when V2 works:
[CmdletBinding(DefaultParameterSetName = 'ID')]
param(
    # Application ID.
    [Parameter(Mandatory = $true
                ,ParameterSetName = 'ID')]
    [Alias('AppId'
            ,'ApplicationId')]
    [int]
    $Id
    ,
    # Application UUID.
    [Parameter(Mandatory = $true
                ,ParameterSetName = 'UUID')]
    [Alias('ApplicationUuid'
            ,'AppUuid')]
    [string]
    $Uuid
)


Taken from the API helper, where it works.
curl -X GET --header 'Accept: application/json' --header 'Authorization: Basic REDACTED' --header 'aw-tenant-code: REDACTED' 'https://REDACTED/API/mam/apps/purchased/205c6b8c-6a9e-41c5-b492-6f2c0af3fec5'

Converted to PowerShell and tested manually
$Splattributes = @{
    Method = 'GET'
    Headers = @{
        'Accept' = 'application/json'
        'Authorization' = 'Basic REDACTED'
        'aw-tenant-code' = 'REDACTED'
    }
    Uri = 'https://REDACTED/API/mam/apps/purchased/205c6b8c-6a9e-41c5-b492-6f2c0af3fec5'
}
Invoke-WebRequest @Splattributes

Gives the following error:
Server Error in '/Api/Mam' Application.
The resource cannot be found.
Description: HTTP 404. The resource you are looking for (or one of its dependencies) could 
            have been removed, had its name changed, or is temporarily unavailable. 
            Please review the following URL and make sure that it is spelled correctly.
Requested URL: /API/mam/apps/purchased/205c6b8c-6a9e-41c5-b492-6f2c0af3fec5
#>
<# $AppUpdates = $Notifications | Where-Object { $_.Title -eq 'App Updated' }
$Now = Get-Date
foreach ($App in $AppUpdates) {
    $NotificationTime = Get-Date -Date $App.GlobalizedCreatedOn
    if ($NotificationTime.AddDays(2) -lt $Now) { continue }
    $AppData = $App.Data | ConvertFrom-Json
    $Properties = [ordered]@{
        Id   = $AppData.AppIdentifier
        Name = $AppData.AppName
    }
    New-Object -TypeName PSCustomObject -Property $Properties
}
#>
<# Update categories from AppStore
foreach ($App in $Apps) {
    # Skip the app if it doesn't have an application URL.
    if ($App.ApplicationUrl -notmatch "apps\.apple\.com/(?<Country>[^/]+)/.*/id(?<Id>\d+)(/|$)") { continue }
    # Skip the app if already have categories specified.
    if ($App.psobject.Members.Name -contains 'Categories') { continue }

    # Request app details.
    $Splattributes = @{
        Method = 'GET'
        ContentType = 'application/json'
        Uri = "https://itunes.apple.com/lookup?id=$($Matches.Id)&country=$($Matches.Country)"
    }
    try {
        $Response = Invoke-RestMethod @Splat
        #$WebResponse = Invoke-WebRequest -UseBasicParsing -Uri $Splat.Uri
    }
    catch {
        Write-Warning -Message "Getting details for '$($App.ApplicationName)' ($($App.BundleId)) failed. Skipping."
        continue
    }
    # Create an array with the categories.
    $Categories = @()
    foreach ($g in $Response.results.genres) {
        $Categories += @{ Name = $g }
    }

    # Prepare the JSON payload to update app categories.
    $Body = @{ CategoryList = @{ Category = $Categories } }

    # Update the app details.
    $Splattributes = @{
        Method = 'PUT'
        ContentType = 'application/json'
        Headers = $Headers
        Uri = "$($Config.ApiUrl)/mam/apps/purchased/$($App.Id.Value)"
        Body = $Body | ConvertTo-Json -Compress -Depth 5
    }
    Write-Verbose -Message "Updating '$($App.ApplicationName)' ($($App.Id.Value): $($App.BundleId)) with the categories '$($Categories.Name -join "', '")'." -Verbose
    #Write-Verbose -Message "Calling REST: '$($Splat.Uri)' with body '$($Splat.Body)'." -Verbose
    $Response = Invoke-RestMethod @Splat
}
#>
<# Snippets
$Splattributes = @{
    Method = 'GET'
    ContentType = 'application/json'
    Headers = $Headers
    Uri = "$($Config.ApiUrl)/mdm/devices/search?organization_group_uuid=$($OrganizationGroupUuid)"
}

$Splattributes = @{
    Method = 'GET'
    ContentType = 'application/json'
    Headers = $Headers
    Uri = "$($Config.ApiUrl)/system/groups/search?organization_group_uuid=$($OrganizationGroupUuid)"
}

$Splattributes = @{
    Method = 'GET'
    ContentType = 'application/json'
    Headers = $Headers
    Uri = "$($Config.ApiUrl)/system/groups/devicecounts"
}

$Splattributes = @{
    Method = 'GET'
    ContentType = 'application/json'
    Headers = $Headers
    Uri = "$($Config.ApiUrl)/system/groups/$($OrganizationGroupUuid)"
}
#>