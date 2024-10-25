<#
.SYNOPSIS
Retrieves information about the specified organization group.

.DESCRIPTION
Retrieves organization group by ID. If Organization group is not found, it will throw 404 error.

.PARAMETER Id
The OrganizationGroup Identifier.

.PARAMETER Uuid
Identifier for an organization group on which operation is to be executed.

.PARAMETER Children
Lists the Organization Group specified by the ID and all of its child Organization Groups. Users, administrators, and devices in the OG specified by the ID are broken down and listed underneath the Organization Group they are enrolled or created at.

.NOTES
.EXAMPLE
#>
function Get-OrganizationGroup {
    [CmdletBinding(DefaultParameterSetName = 'ID')]
    param(
        [Parameter(Mandatory = $true
                ,  ParameterSetName = 'ID')]
        [string]
        $Id
        ,
        [Parameter(Mandatory = $true
                ,  ParameterSetName = 'UUID')]
        [string]
        $Uuid
        ,
        [Parameter()]
        [switch]
        $Children
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
    $Uri = "$($Script:Config.ApiUrl)/system/groups/$($Identifier)"
    if ($Children) { $Uri += '/children' }
    $Splattributes = @{
        Uri = $Uri
        Method = 'GET'
        Version = $ApiVersion
    }
    Write-Verbose -Message "$($MyInvocation.MyCommand.Name): Invoke-ApiRequest $($Splattributes)"
    $Response = Invoke-ApiRequest @Splattributes
    $Response.LocationGroups
}