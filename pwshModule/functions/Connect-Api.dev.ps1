function Connect-Api {
    [CmdletBinding(DefaultParameterSetName = 'Basic')]
    param(
        [Parameter(Mandatory = $true)]
        [Alias('ApiUri')]
        [ValidatePattern('^https://')]
        [uri]
        $Uri
        ,
        [Parameter(Mandatory = $true)]
        [Alias('ApiKey')]
        [Security.SecureString]
        $Key
        ,
        [Parameter(Mandatory = $true, ParameterSetName = 'Basic')]
        [pscredential]
        $Credential
        ,
        [Parameter(Mandatory = $true, ParameterSetName = 'Certificate')]
        [System.Security.Cryptography.X509Certificates.X509Certificate2]
        $Certificate
        ,
        [Parameter(Mandatory = $true, ParameterSetName = 'OAuth')]
        [pscredential]
        $OAuthClient
        ,
        [Parameter(Mandatory = $true, ParameterSetName = 'OAuth')]
        [ValidatePattern('^https://')]
        [uri]
        $TokenUrl = 'https://emea.uemauth.vmwservices.com/connect/token'
        ,
        [Parameter()]
        [switch]
        $PassThru
    )
    $ConfigTable = @{}

    while (!$Uri -or ($Uri -as [uri]).Scheme -notmatch 'https?') {
        $Uri = Read-Host -Prompt 'API URL'
    }
    $ConfigTable.ApiUrl = $Uri

    if (!$Key) {
        $Key = Read-Host -AsSecureString -Prompt 'API Key'
    }
    $ConfigTable.ApiKey = $Key
    switch ($PSCmdlet.ParameterSetName) {
        'Basic' {
            if (!$Credential -or $Credential.GetType().Name -ne 'PSCredential') {
                $Credential = Get-Credential -Message 'Admininistrator credentials'
            }
            $ConfigTable.Credential = $Credential
            break
        }
        'Certificate' {
            if (!$Certificate) {
                Write-Error -Message "Authentication method set to Certificate, but no certificate was supplied." -ErrorAction Stop
            }
            $ConfigTable.Certificate = $Certificate
            break
        }
        'OAuth' {
            if (!$OAuthClient -or $OAuthClient.GetType().Name -ne 'PSCredential') {
                $OAuthClient = Get-Credential -Message 'OAuth Client ID and Secret'
            }
            $ConfigTable.OAuthCredential = $OAuthClient
            if (!$TokenUrl -or ($TokenUrl -as [uri]).Scheme -notmatch 'https?') {
                $TokenUrl = Read-Host -Prompt 'OAuth URL'
            }
            $ConfigTable.OAuthUrl = $TokenUrl
            break
        }
    }
    $Script:Config = New-Object -TypeName PSCustomObject -Property $ConfigTable
    if ($PassThru) { $Script:Config }
    <#
    .SYNOPSIS
    Initiates a new API configuration.

    .DESCRIPTION
    Initiates a new API configuration for logging into the specified Workspace ONE tenants API.

    .PARAMETER Uri
    The base uri for the API, i.e. https://host.domain.tld/API

    .PARAMETER Key
    The API key for accessing the API.

    .PARAMETER Credential
    PSCredential for logging in using Basic Auth.
    Required if Method is set to Basic.

    .PARAMETER Certificate
    The certificate used for certificate based authentication.
    Required if method is set to Certificate.

    .PARAMETER OAuthClient
    PSCredential containing the OAuth Client ID (username) and OAuth Client Secret (password).

    .PARAMETER TokenUrl
    The OAuth URL for logging in using OAuth. See the following documentation for a list of valid URLs:

    https://docs.omnissa.com/bundle/WorkspaceONE-UEM-Console-BasicsV2406/page/UsingUEMFunctionalityWithRESTAPI.html#datacenter_and_token_urls_for_oauth_20_support
    Kown Token URLs at the time of writing:
    Region                    |  Workspace ONE UEM SaaS Data Center Location   |  Token URL
    --------------------------|------------------------------------------------|----------------------------------------------------
    Ohio (United States)      |  All UAT environment                           |  https://uat.uemauth.vmwservices.com/connect/token
    Virginia (United States)  |  United States                                 |  https://na.uemauth.vmwservices.com/connect/token
    Virginia (United States)  |  Canada                                        |  https://na.uemauth.vmwservices.com/connect/token
    Frankfurt (Germany)       |  United Kingdom                                |  https://emea.uemauth.vmwservices.com/connect/token
    Frankfurt (Germany)       |  Germany                                       |  https://emea.uemauth.vmwservices.com/connect/token
    Tokyo (Japan)             |  India                                         |  https://apac.uemauth.vmwservices.com/connect/token
    Tokyo (Japan)             |  Japan                                         |  https://apac.uemauth.vmwservices.com/connect/token
    Tokyo (Japan)             |  Singapore                                     |  https://apac.uemauth.vmwservices.com/connect/token
    Tokyo (Japan)             |  Australia                                     |  https://apac.uemauth.vmwservices.com/connect/token
    Tokyo (Japan)             |  Hong Kong                                     |  https://apac.uemauth.vmwservices.com/connect/token
    --------------------------|------------------------------------------------|----------------------------------------------------
    Regions:
    NA   (North America)
    EMEA (Europe, Middle East and Africa)
    APAC (Asia and Pacifics)
    UAT  (User Acceptance Tests)

    .PARAMETER PassThru
    Returns the resulting configuration.

    .NOTES
    I will most likely rewrite some of the logic and remove the Method parameter, as the method is 
    implied depending on whether a certificate, a credential or an OAuth uri have been specified, as
    they are mutually exclusive.

    .LINK
    .EXAMPLE
    #>
}