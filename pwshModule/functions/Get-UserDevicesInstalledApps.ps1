function Get-UserDevicesInstalledApps {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true
                ,  ValueFromPipeline = $true
                ,  ValueFromPipelineByPropertyName = $true
                ,  ValueFromRemainingArguments = $false
                ,  Position = 0)]
        [string[]]
        $User
    )
    process {
        foreach ($u in $User) {
            foreach ($Device in (Find-Device -User $u)) {
                $Properties = ($Device.psobject.Members | Where-Object { $_.MemberType -eq 'NoteProperty' -and $_.TypeNameOfValue -notmatch 'Object' }).Name
                $Properties += 'Id'
                $DeviceData = [PSCustomObject][ordered]@{}
                $DeviceData = $Device | Select-Object -Property $Properties
                $DeviceData.Id = $Device.Id.Value
                if (!$DeviceData.InstalledApps) { $DeviceData | Add-Member -MemberType NoteProperty -Name 'InstalledApps' -Value $null }
                $DeviceData.InstalledApps = Get-DeviceAppDetails -Uuid $Device.Uuid | Where-Object { $_.installed_status -eq 'Installed' }
                $DeviceData
            }
        }
    }
    <#
    .SYNOPSIS
    Get all devices and apps for specified user(s).

    .DESCRIPTION
    Finds all devices for the given user(s) and adds all installed apps to the object that is returned.

    .PARAMETER User
    One or more usernames to check.

    .NOTES
    .EXAMPLE
    #>
}
