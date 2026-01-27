function Find-Profile {
    [CmdletBinding()]
    param(
        [Parameter()]
        [Alias('Start', 'PageStart')]
        [int]
        $Page
        ,
        [Parameter()]
        [Alias('Limit')]
        [int]
        $PageSize
        ,
        [Parameter()]
        [string]
        $OrderBy
        ,
        [Parameter()]
        [Alias('Sort')]
        [ValidateSet('ASC', 'DESC')]
        [string]
        $SortOrder
    )
    $Uri = "$($Config.ApiUrl)/mdm/profiles/search"
    $Attributes = @{
        Uri = $Uri
        Method = 'POST'
        Version = 3
        Body = '{}'
    }
    Write-Verbose -Message "$($MyInvocation.MyCommand.Name): Invoke-ApiRequest $($Attributes | ConvertTo-Json -Compress)"
    $Response = Invoke-ApiRequest @Attributes
    $Response
    <#
    .SYNOPSIS

    .DESCRIPTION

    .PARAMETER Page

    .PARAMETER PageSize

    .NOTES

    .EXAMPLE
    #>
}