function New-ApiConfig {
    [CmdletBinding(DefaultParameterSetName = 'Basic')]
    param(
        [Parameter()]
        [Alias('ApiUri')]
        [ValidateNotNullOrEmpty()]
        [uri]
        $Uri
        ,
        [Parameter()]
        [Alias('ApiKey')]
        [ValidateNotNullOrEmpty()]
        [Security.SecureString]
        $Key
        ,
        [Parameter()]
        [Alias('AuthMethod', 'AuthenticationMethod')]
        [ValidateSet('Basic', 'Certificate', 'OAuth')]
        [string]
        $Method = 'Basic'
        ,
        [Parameter(ParameterSetName = 'Basic')]
        [ValidateNotNullOrEmpty()]
        [pscredential]
        $Credential
        ,
        [Parameter(ParameterSetName = 'Certificate')]
        [ValidateNotNullOrEmpty()]
        [System.Security.Cryptography.X509Certificates.X509Certificate2]
        $Certificate
        ,
        [Parameter(ParameterSetName = 'OAuth')]
        [ValidateNotNullOrEmpty()]
        [uri]
        $OAuthUrl = 'https://emea.uemauth.vmwservices.com/connect/token'
        ,
        [Parameter(ParameterSetName = 'OAuth')]
        [ValidateNotNullOrEmpty()]
        [pscredential]
        $OAuthCredential
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

    if (!$Method -or $Method -ne $PSCmdlet.ParameterSetName) {
        $Method = $PSCmdlet.ParameterSetName
    }
    $ConfigTable.AuthenticationMethod = $Method

    switch ($Method) {
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
            if (!$OAuthUrl -or ($OAuthUrl -as [uri]).Scheme -notmatch 'https?') {
                $OAuthUrl = Read-Host -Prompt 'OAuth URL'
            }
            $ConfigTable.OAuthUrl = $OAuthUrl

            if (!$OAuthCredential -or $OAuthCredential.GetType().Name -ne 'PSCredential') {
                $OAuthCredential = Get-Credential -Message 'OAuth Client ID and Secret'
            }
            $ConfigTable.OAuthCredential = $OAuthCredential
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

    .PARAMETER Method
    Specifies the authentication method; Basic, Certificate, or OAuth.
    Default: Basic

    .PARAMETER Credential
    PSCredential for logging in using Basic Auth.
    Required if Method is set to Basic.

    .PARAMETER Certificate
    The certificate used for certificate based authentication.
    Required if method is set to Certificate.

    .PARAMETER OAuthUrl
    The OAuth URL for logging in using OAuth, i.e. 'https://emea.uemauth.vmwservices.com/connect/token'

    .PARAMETER OAuthCredential
    PSCredential containing the OAuth Client ID (username) and OAuth Client Secret (password).

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