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
}
