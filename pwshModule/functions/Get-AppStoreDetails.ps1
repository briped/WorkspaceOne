function Get-AppStoreDetails {
    [CmdletBinding(DefaultParameterSetName = 'URL')]
    param(
        [Parameter(Mandatory = $true
                ,  ParameterSetName = 'URL')]
        [uri]
        $Uri
        ,
        [Parameter(Mandatory = $true
                ,  ParameterSetName = 'ID')]
        [int]
        $Id
        ,
        [Parameter(Mandatory = $true
                ,  ParameterSetName = 'ID')]
        [string]
        $Country
    )
    switch ($PSCmdlet.ParameterSetName) {
        'ID' {
            $TwoLetterISORegionNames = TwoLetterISORegionNames
            if ($CountryCode -notin $TwoLetterISORegionNames) {
                throw "Invalid Country Code. Valid codes are: $($TwoLetterISORegionNames -join ', ')"
            }
            $Country = $Country.ToLower()
            break
        }
        'URL' {
            if ($Uri -notmatch "apps\.apple\.com/(?<Country>[^/]+)/.*/id(?<Id>\d+)(/|$)") {
                throw "The '$($Uri)' is not a valid Apple AppStore URL."
            }
            $Country = $Matches.Country.Towlower()
            $Id = $Matches.Id
            break
        }
    }
    Write-Verbose -Message "App URL: $($Uri)"
    $Splattributes = @{
        Method = 'GET'
        ContentType = 'application/json'
        Uri = "https://itunes.apple.com/lookup?id=$($Matches.Id)&country=$($Matches.Country)"
    }
    $Response = Invoke-RestMethod @Splattributes
    $Response.results
    <#
    .SYNOPSIS
    Get app details from Apple App Store.

    .DESCRIPTION
    Gets details about the specified app from the Apple App Store.

    .PARAMETER Uri
    The webaddress to the app in the Apple public App Store. F.ex.: 'https://apps.apple.com/us/app/angry-birds-2/id880047117'

    .PARAMETER Id
    The Id of the app on the Apple public App Store. F.ex.: 880047117

    .PARAMETER Country
    The two-letter country code of the desired Apple public App Store. F.ex.: US

    .EXAMPLE
    Get-AppStoreDetails -Uri 'https://apps.apple.com/us/app/angry-birds-2/id880047117'

    .EXAMPLE
    Get-AppStoreDetails -Country 'us' -Id 880047117
    #>
}
function TwoLetterISORegionNames {
    $CultureTypes = [System.Globalization.CultureTypes]::SpecificCultures
    $CultureInfo = [System.Globalization.CultureInfo]::GetCultures($CultureTypes)
    $TwoLetterISORegionNames = @()
    foreach ($Culture in $CultureInfo) {
        $RegionInfo = [System.Globalization.RegionInfo]::new($Culture.Name)
        if ($RegionInfo.TwoLetterISORegionName -match '^[a-z]{2}$') {
            $TwoLetterISORegionNames += $RegionInfo.TwoLetterISORegionName
        }
    }
    $TwoLetterISORegionNames | Sort-Object -Unique
    <#
    .SYNOPSIS
    Helper function that returns all valid two-letter ISO region names.

    .DESCRIPTION
    Helper function that returns all valid two-letter ISO region names.

    .EXAMPLE
    TwoLetterISORegionNames
    #>
}
Register-ArgumentCompleter -CommandName 'Get-AppStoreDetails' -ParameterName 'Country' -ScriptBlock {
    param($CommandName,$ParameterName,$WordToComplete,$CommandAST,$BoundParameters)
    TwoLetterISORegionNames | Where-Object {
        $_ -like "$($WordToComplete)*" | 
            ForEach-Object { [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_) }
    }
}