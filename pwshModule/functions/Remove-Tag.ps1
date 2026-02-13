function Remove-Tag {
    [CmdletBinding(SupportsShouldProcess = $true
                ,  ConfirmImpact = 'High')]
    param(
        [Parameter(Mandatory = $true)]
        [int]
        $Id
        ,
        [Parameter()]
        [switch]
        $Force
    )
    $Uri = "$($Config.ApiUrl)/mdm/tags/$($Id)"
    if ($Force -and !$Confirm) {
        $ConfirmPreference = 'None'
    }

    $Attributes = @{
        Uri = $Uri
        Method = 'DELETE'
        Version = 1
    }

    if ($PSCmdlet.ShouldProcess($Id)) {
        Write-Verbose -Message "$($MyInvocation.MyCommand.Name): Invoke-ApiRequest $($Attributes | ConvertTo-Json -Compress)"
        Invoke-ApiRequest @Attributes
    }
    <#
    .SYNOPSIS
    Delete a tag.

    .DESCRIPTION
    Delete a tag based on tag identifier.

    .PARAMETER Id
    Unique identifier for the tag.

    .EXAMPLE
    Remove-Tag -Id 123

    .PARAMETER Force
    Override confirmation prompts

    .NOTES
        .TODO
        .CHANGES
        2026-02-13
        + Force parameter
    #>
}