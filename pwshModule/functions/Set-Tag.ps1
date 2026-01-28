function Set-Tag {
    [CmdletBinding(SupportsShouldProcess = $true
                ,  ConfirmImpact = 'High')]
    param(
        [Parameter(Mandatory = $true)]
        [int]
        $Id
        ,
        [Parameter()]
        [string]
        $Name
        ,
        [Parameter()]
        [string]
        $Avatar
        ,
        [Parameter()]
        [int]
        $Type
        ,
        [Parameter()]
        [int]
        $OrganizationGroupId
    )
    $Uri = "$($Config.ApiUrl)/mdm/tags/$($Id)/update"

    $Payload = @{
        TagName = $Name
        TagAvatar = $Avatar
        TagType = $Type
        LocationGroupId = $OrganizationGroupId
    }
    $Payload = @{}
    $Payload.TagName = $Name
    $Payload.LocationGroupId = $OrganizationGroupId
    if ($Avatar) { $Payload.TagAvatar = $Avatar }
    if ($Type) { $Payload.TagType = $Type }

    $Attributes = @{
        Uri = $Uri
        Method = 'POST'
        Body = $Payload | ConvertTo-Json -Compress
        Version = 1
    }

    if ($PSCmdlet.ShouldProcess($Id)) {
        Write-Verbose -Message "$($MyInvocation.MyCommand.Name): Invoke-ApiRequest $($Attributes | ConvertTo-Json -Compress)"
        Invoke-ApiRequest @Attributes
    }
    <#
    .SYNOPSIS
    Updates a tag name, tag type or tag avatar.

    .DESCRIPTION
    Updates a tag based on the tag identifier and tag details. This API can be used to update the tag name, tag type and tag avatar.

    .PARAMETER Id
    Unique identifier for the tag.

    .PARAMETER Name
    Name of the tag

    .PARAMETER Avatar
    No clue what this is used for.

    .PARAMETER Type
    No clue what this is used for.

    .PARAMETER OrganizationGroupId
    Organization group identifier

    .EXAMPLE
    .NOTES
    #>
}