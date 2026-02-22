function New-ApiConfig {
    [CmdletBinding(DefaultParameterSetName = 'Basic')]
    param(
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias('ApiUri')]
        [ValidateNotNullOrEmpty()]
        [uri]
        $Uri
        ,
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias('ApiKey')]
        [ValidateNotNullOrEmpty()]
        [Security.SecureString]
        $Key
        ,
        [Parameter(ParameterSetName = 'Basic'
                ,  ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [pscredential]
        $Credential
        ,
        [Parameter(ParameterSetName = 'Certificate'
                ,  ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [System.Object]
        $Certificate
        ,
        [Parameter(ParameterSetName = 'Certificate'
                ,  ValueFromPipelineByPropertyName = $true)]
        [Security.SecureString]
        $CertificatePassword
        ,
        [Parameter(ParameterSetName = 'OAuth'
                ,  ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [uri]
        $OAuthUrl = 'https://emea.uemauth.vmwservices.com/connect/token'
        ,
        [Parameter(ParameterSetName = 'OAuth'
                ,  ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [pscredential]
        $OAuthCredential
        ,
        [Parameter()]
        [switch]
        $PassThru
    )
    Write-Verbose -Message "$($MyInvocation.MyCommand.Name): New-ApiConfig"
    Write-Verbose -Message "$($MyInvocation.MyCommand.Name): New-ApiConfig: Authentication method: $($PSCmdlet.ParameterSetName)"

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
            $CertificateTable = @{}
            if ($Certificate.GetType().Name -eq 'String') {
                Write-Verbose -Message "$($MyInvocation.MyCommand.Name): New-ApiConfig: Certificate type is: $($Certificate.GetType().Name)"
                if (!(Test-Path -PathType Leaf -Path $Certificate)) {
                    Write-Log -PassThru -Message "Certificate path not found: $($Certificate)" | Write-Error -ErrorAction Stop
                    break
                }
                Write-Verbose -Message "$($MyInvocation.MyCommand.Name): New-ApiConfig: Reading certificate from path: $($Certificate)"
                $Certificate = Get-Item -Path $Certificate
            }
            if ($Certificate.GetType().Name -eq 'FileInfo') {
                Write-Verbose -Message "$($MyInvocation.MyCommand.Name): New-ApiConfig: Certificate type is: $($Certificate.GetType().Name)"
                if (!$CertificatePassword) {
                    $CertificatePassword = Read-Host -AsSecureString -Prompt 'Certificate Password'
                }
                $CertificateTable.Password = $CertificatePassword
                $CertificateTable.PSPath = $Certificate.PSPath
                <#
                Write-Verbose -Message "$($MyInvocation.MyCommand.Name): New-ApiConfig: Reading certificate as ByteStream."
                [byte[]]$ConfigTable.Certificate.Bytes = [System.IO.File]::ReadAllBytes($Certificate)
                $Certificate = $ConfigTable.Certificate.Bytes
                #>
            }
            <#
            if ($Certificate.GetType().Name -eq 'Byte[]') {
                Write-Verbose -Message "$($MyInvocation.MyCommand.Name): New-ApiConfig: Certificate type is: $($Certificate.GetType().Name)"
                if (!$CertificatePassword) {
                    $CertificatePassword = Read-Host -AsSecureString -Prompt 'Certificate Password'
                }
                $ConfigTable.Certificate.Password = $CertificatePassword
                Write-Verbose -Message "$($MyInvocation.MyCommand.Name): New-ApiConfig: Converting ByteStream to X509Certificate2."
                $Certificate = [System.Security.Cryptography.X509Certificates.X509Certificate2]::new($ConfigTable.Certificate.Bytes, $ConfigTable.Certificate.Password)
            }
            #>
            if ($Certificate.GetType().Name -eq 'X509Certificate2') {
                Write-Verbose -Message "$($MyInvocation.MyCommand.Name): New-ApiConfig: Certificate type is: $($Certificate.GetType().Name)"
                if ($null -ne $Certificate.PSDrive -and $Certificate.PSDrive.Provider.Name -eq 'Certificate') {
                    $Certificate.PSPath = $Certificate.PSPath
                }
            }
            $ConfigTable.Certificate = [PSCustomObject]$CertificateTable
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
    $Script:Config = [PSCustomObject]$ConfigTable
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

    .PARAMETER Certificate
    The certificate used for certificate based authentication.
    * Path to certificate as a string.
    * FileInfo object to the certificate file. Must contain the PSPath to the certificate.
    * X509Certificate2 object from the certificate store. Must contain the PSPath to the certificate.

    .PARAMETER OAuthUrl
    The OAuth URL for logging in using OAuth, i.e. 'https://emea.uemauth.vmwservices.com/connect/token'

    .PARAMETER OAuthCredential
    PSCredential containing the OAuth Client ID (username) and OAuth Client Secret (password).

    .PARAMETER PassThru
    Returns the resulting configuration.

    .EXAMPLE
    $Attributes = @{
        Uri = 'https://ws1.example.com/API'
        Key = ('APIKEY' | ConvertTo-SecureString -Force -AsPlainText)
        Certificate = (Get-Item -Path Cert:\CurrentUser\My\1234567890ABCDEF0987654321FEDCBA01234567)
    }
    New-ApiConfig @Attributes

    .EXAMPLE
    $Attributes = @{
        Uri = 'https://ws1.example.com/API'
        Key = ('APIKEY' | ConvertTo-SecureString -Force -AsPlainText)
        Certificate = (Get-Item -Path C:\Script\cert.p12)
        CertificatePassword = ('CERTIFICATE PASSWORD' | ConvertTo-SecureString -Force -AsPlainText)
    }
    New-ApiConfig @Attributes

    .EXAMPLE
    $Attributes = @{
        Uri = 'https://ws1.example.com/API'
        Key = ('APIKEY' | ConvertTo-SecureString -Force -AsPlainText)
        Credential = Get-Credential
    }
    New-ApiConfig @Attributes

    .NOTES
        .TODO:
        .CHANGES
            * Changed Certificate logic
            - Removed Method parameter as it is not longer needed.
    #>
}