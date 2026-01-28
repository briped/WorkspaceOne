function Remove-DeviceV2 {
    [CmdletBinding(SupportsShouldProcess = $true
                ,  ConfirmImpact = 'High'
                ,  DefaultParameterSetName = 'DeviceID')]
    param(
        [Parameter(Mandatory = $true
                ,  ParameterSetName = 'DeviceID')]
        [Alias('ID')]
        [int[]]
        $DeviceID
        ,
        [Parameter(Mandatory = $true
                ,  ParameterSetName = 'UDID')]
        [Alias('UniqueDeviceID')]
        [string[]]
        $UDID
        ,
        [Parameter(Mandatory = $true
                ,  ParameterSetName = 'SerialNumber')]
        [Alias('SN', 'Serial')]
        [string[]]
        $SerialNumber
        ,
        [Parameter(Mandatory = $true
                ,  ParameterSetName = 'ImeiNumber')]
        [Alias('IMEI')]
        [string[]]
        $ImeiNumber
        ,
        [Parameter(Mandatory = $true
                ,  ParameterSetName = 'EasId')]
        [Alias('ActiveSyncID')]
        [string[]]
        $EasId
        ,
        [Parameter(Mandatory = $true
                ,  ParameterSetName = 'MacAddress')]
        [Alias('HardwareAddress')]
        [string[]]
        $MacAddress
        ,
        [Parameter()]
        [switch]
        $Force
    )
    if ($Force -and !$Confirm) {
        $ConfirmPreference = 'None'
    }
    $Identifier = Get-Variable -Name $PSCmdlet.ParameterSetName
    if ($Identifier.Value.Count -eq 1) {
        if ($Identifier.Name -eq 'DeviceID') {
            $Attributes = @{
                Uri = "$($Config.ApiUrl)/mdm/devices/$($Identifier.Value)"
                Method = 'DELETE'
                Version = 1
            }
        }
        else {
            $Attributes = @{
                Uri = "$($Config.ApiUrl)/mdm/devices?SearchBy=$($Identifier.Name)&Id=$($Identifier.Value)"
                Method = 'DELETE'
                Version = 1
            }
        }
    }
    else {
        $Payload = @{
            BulkValues = @{
                Value = $Identifier.Value
            }
        }
        $Attributes = @{
            Uri = "$($Config.ApiUrl)/mdm/devices/bulk?SearchBy=$($Identifier.Name)"
            Method = 'POST'
            Body = $Payload
            Version = 1
        }
    }
    if ($PSCmdlet.ShouldProcess("$($Identifier.Name): $($Identifier.Value[0..5] -join ', ') (Total: $($Identifier.Value.Count))")) {
        Write-Verbose -Message "$($MyInvocation.MyCommand.Name): Invoke-ApiRequest $($Attributes | ConvertTo-Json -Compress)"
        Invoke-ApiRequest @Attributes
    }
    <#
    .SYNOPSIS
    Delete device by device identifier.

    .DESCRIPTION
    Delete device by device identifier.
    
    .PARAMETER DeviceId
    [int[]] Alias: ID
    The Device ID.
    Will use the API call for single device deletion, of only 1 ID is supplied.

    .PARAMETER UDID
    [string[]] Alias: UniqueDeviceID

    .PARAMETER SerialNumber
    [string[]] Alias: SN, Serial

    .PARAMETER ImeiNumber
    [string[]] Alias: IMEI

    .PARAMETER EasId
    [string[]] Alias: ActiveSyncID

    .PARAMETER MacAddress
    [string[]] Alias: HardwareAddress

    .PARAMETER Force
    [switch]

    .NOTES
    .EXAMPLE
    #>
}
