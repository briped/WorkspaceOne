function Get-VppSyncAssetsStatus {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true
                ,  ValueFromPipeline = $true
                ,  ValueFromPipelineByPropertyName = $true
                ,  ValueFromRemainingArguments = $false
                ,  Position = 0)]
        [Alias('LocationGroupId', 'OrganizationGroupId')]
        [int]
        $Id
    )
    $Attributes = @{
        Uri = "$($Config.ApiUrl)/mam/apps/purchased/GetVppSyncAssetsStatus/$($Id)"
        Method = 'GET'
        Version = 1
    }
    Write-Verbose -Message ($Attributes | ConvertTo-Json -Compress)
    Invoke-ApiRequest @Attributes
    <#
    .SYNOPSIS
    Get the status and details for the VPP Sync Assets job at the given organization group.

    .DESCRIPTION
    Vpp sync assets job will take time to sync applications on the apple server to the airwatch console. This will get the current status of the job.

    .PARAMETER Id
    Organization Group Id, aka. Location Group Id aka. the organization group identifier

    .NOTES
    /apps/purchased/GetVppSyncAssetsStatus/{locationGroupId}
    .EXAMPLE
    #>
}
