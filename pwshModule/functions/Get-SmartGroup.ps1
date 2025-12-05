function Get-SmartGroup {
    [CmdletBinding(DefaultParameterSetName = 'Devices')]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [int]
        $Id
        ,
        [Parameter(Position = 1, ParameterSetName = 'Apps')]
        [switch]
        $Apps
        ,
        [Parameter(Position = 1, ParameterSetName = 'Devices')]
        [switch]
        $Devices
        ,
        [Parameter(ParameterSetName = 'Devices')]
        [datetime]
        $SeenAfter
        ,
        [Parameter(ParameterSetName = 'Devices')]
        [datetime]
        $SeenBefore
    )
    Write-Verbose -Message $PSCmdlet.ParameterSetName
    $Uri = "$($Script:Config.ApiUrl)/mdm/smartgroups/$($Id)"
    if ($Apps) { $Uri += '/apps' }
    if ($Devices) {
        $Uri += '/devices'
        if ($SeenAfter -or $SeenBefore) {
            $Data = @{}
            if ($SeenAfter) { $Data.seensince = $SeenAfter.ToString('yyyy-MM-ddTHH:mm:ss.fff') }
            if ($SeenBefore) { $Data.seentill = $SeenBefore.ToString('yyyy-MM-ddTHH:mm:ss.fff') }
            $Query = @()
            foreach ($k in $Data.Keys) {
                $Query += "$($k)=$([uri]::EscapeDataString($Data[$k]))"
            }
            if ($Query.Count -gt 0) { $Uri = "$($Uri)?$($Query -join '&')" }
        }
    }
    $Attributes = @{
        Uri = $Uri
        Method = 'GET'
        Version = 1
    }
    Write-Verbose -Message "$($MyInvocation.MyCommand.Name): Invoke-ApiRequest $($Attributes | ConvertTo-Json -Compress)"
    $Response = Invoke-ApiRequest @Attributes
    if ($Devices) {
        $Response.Devices
    }
    else {
        $Response
    }
    <#
    .SYNOPSIS
    Retrieves the Smart Group Details.

    .DESCRIPTION
    Retrieves all the Smart Group details like ( Name, Id, RootLocationGroup, Devices Assigned,list of Users/User Groups etc.) from the Smart Group Identifier.

    .PARAMETER Id
    The SmartGroup Identifier.

    .PARAMETER Apps
    Get List of Apps assigned to the Smart Group based on Smart Group Identifier.

    .PARAMETER Devices
    Retrieves the list of all devices with their respective details (such as DeviceId, Model, OS Version, Platform and Ownership) which belongs to a specific SmartGroup based on Smart Group Identifier.

    .PARAMETER SeenAfter
    Filters the devices in the smart group seen after the SeenAfter datetime.

    .PARAMETER SeenBefore
    Filters the devices in the smart group seen before the SeenBefore datetime.

    .NOTES
    .EXAMPLE
    #>
}