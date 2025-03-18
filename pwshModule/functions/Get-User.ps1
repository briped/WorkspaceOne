function Get-User {
    [CmdletBinding(DefaultParameterSetName = 'ID')]
    param(
        [Parameter(Mandatory = $true, Position = 0, ParameterSetName = 'ID')]
        [int]
        $Id
        ,
        [Parameter(Mandatory = $true, Position = 0, ParameterSetName = 'UUID')]
        [string]
        $Uuid
    )
    switch ($PSCmdlet.ParameterSetName) {
        'ID' {
            $Identifier = $Id
            $ApiVersion = 1
            break
        }
        'UUID' {
            $Identifier = $Uuid
            $ApiVersion = 2
            break
        }
    }
    $Uri = "$($Script:Config.ApiUrl)/system/users/$($Identifier)"
    $Splattributes = @{
        Uri = $Uri
        Method = 'GET'
        Version = $ApiVersion
    }
    Write-Verbose -Message "$($MyInvocation.MyCommand.Name): Invoke-ApiRequest $($Splattributes | ConvertTo-Json -Compress)"
    $Response = Invoke-ApiRequest @Splattributes
    $Response
    <#
    .SYNOPSIS
    Get the enrollment user.

    .DESCRIPTION
    Get the enrollment user information by enrollment user id. The enrollment user information will be present once the call is complete.

    .PARAMETER Id
    The enrollment user id.

    .PARAMETER Uuid
    Identifier of an enrollment user.

    .NOTES
    [ base url: /API/system , api version: 1 ]
    get /users/{id}
    Get the enrollment user.

    Implementation Notes
    Get the enrollment user information by enrollment user id. The enrollment user information will be present once the call is complete. We have introduced v2 for this API, which includes enhancements, and recommend using v2 going forward.

    uuid	
    (required)


    path	string

    .EXAMPLE
    #>
}