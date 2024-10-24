function Get-AppStoreDetails {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]
        $Uri
    )
    Write-Verbose -Message "App URL: $($Uri)"
    if ($Uri -notmatch "apps\.apple\.com/(?<Country>[^/]+)/.*/id(?<Id>\d+)(/|$)") {
        throw "The '$($Uri)' is not a valid Apple AppStore URL."
    }
    $Splattributes = @{
        Method = 'GET'
        ContentType = 'application/json'
        Uri = "https://itunes.apple.com/lookup?id=$($Matches.Id)&country=$($Matches.Country)"
    }
    $Response = Invoke-RestMethod @Splattributes
    $Response.results
}
