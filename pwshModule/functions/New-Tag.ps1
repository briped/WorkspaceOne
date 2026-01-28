function New-Tag {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]
        $Name
        ,
        [Parameter(Mandatory = $true)]
        [int]
        $OrganizationGroupId
        ,
        [Parameter()]
        [string]
        $Avatar
        ,
        [Parameter()]
        [int]
        $Type
    )
    $Uri = "$($Config.ApiUrl)/mdm/tags/addtag"

    $Payload = @{
        TagName = $Name
        LocationGroupId = $OrganizationGroupId
    }
    if ($Avatar) { $Payload.TagAvatar = $Avatar }
    if ($Type) { $Payload.TagType = $Type }

    $Attributes = @{
        Uri = $Uri
        Method = "POST"
        Body = $Payload | ConvertTo-Json -Compress
        Version = 1
    }
    Write-Verbose -Message "$($MyInvocation.MyCommand.Name): Invoke-ApiRequest $($Attributes | ConvertTo-Json -Compress)"
    Invoke-ApiRequest @Attributes
    <#
    .SYNOPSIS
    Add a new tag.

    .DESCRIPTION
    Add a tag based on the details provided.

    .PARAMETER Name
    Name of the tag to be created.

    .PARAMETER OrganizationGroupId
    Organization group identifier where the tag should be created.

    .PARAMETER Avatar
    No clue what this is used for.

    .PARAMETER Type
    No clue what this is used for.

    .INPUTS
    .OUTPUTS
    System.Object. Returns an object containing the property "Value" of type System.Int64.

    .EXAMPLE
    New-Tag -Name "My Tag" -OranizationGroupId = 123

    .NOTES
    #>
}