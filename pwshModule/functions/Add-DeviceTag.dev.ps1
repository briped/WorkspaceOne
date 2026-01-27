function Add-DeviceTag {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]
        $DeviceUUID
        ,
        [Parameter(Mandatory = $true)]
        [string]
        $tagUUID
    )
    Write-Error -Message "This function is not completed yet." -ErrorAction Stop

    $Uri = "$($Config.ApiUrl)/mdm/devices/${DeviceUUID}/tags/${TagUUID}"

    $Attributes = @{
        Uri = $Uri
        Method = 'POST'
        Version = 1
    }
    Write-Verbose -Message ($Attributes | ConvertTo-Json -Compress)
    Invoke-ApiRequest @Attributes

    <#
    .SYNOPSIS

    .DESCRIPTION

    .NOTES

    #>
}