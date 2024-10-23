function Invoke-ApiRequest {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias('ApiUrl')]
        [uri]
        $Uri
        ,
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [Microsoft.PowerShell.Commands.WebRequestMethod]
        $Method
        ,
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Body
        ,
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [Alias('ApiVersion')]
        [int]
        $Version = 1
        ,
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]
        $ContentType = 'application/json'
    )
    $OSEnv = Get-OSEnvironment
    $Authributes = @{
        Uri = $Uri
    }
    Write-Verbose -Message "OSEnv: $($OSEnv | ConvertTo-Json -Compress)"
    Write-Verbose -Message "Script:Config: $($Script:Config | ConvertTo-Json -Compress)"
    if (!$Script:Config -or !$Script:Config.Name -or $Script:Config.Name -ne $OSEnv.UserHost) {
        Write-Error 'Missing configuration' -ErrorAction Stop
    }
    switch ($Script:Config.AuthenticationMethod) {
        'Basic' {
            $Authributes.Credential = $Script:Config.Credential
            break
        }
        'Certificate' {
            $Authributes.Certificate = (Get-Item -Path $Script:Config.CertificatePath)
            break
        }
        'OAuth' {
            $Authributes.OAuthUrl = $Script:Config.OAuthUrl
            $Authributes.OAuthCredential = $Script:Config.OAuthCredential
            break
        }
        Default {
            Write-Error -Message "Unknown authentication method: $($Script:Config.AuthenticationMethod)"
        }
    }
    $Authorization = Get-Authorization @Authributes

    $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Script:Config.ApiKey)
    $ApiKey = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
    $Headers = @{
        'Accept'         = 'application/json'
        'Authorization'  = $Authorization
        'aw-tenant-code' = $ApiKey
    }

    $Splattributes = @{
        Uri         = $Uri
        Method      = $Method
        ContentType = "application/json;version=$($Version)"
        Headers     = $Headers
    }
    if ($Body) {
        $Splattributes.Body = $Body
    }
    Write-Verbose -Message ($Splattributes | ConvertTo-Json -Compress)
    Invoke-RestMethod @Splattributes
}
