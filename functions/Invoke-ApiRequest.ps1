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
    $Authributes = @{
        Uri = $Uri
    }
    Write-Verbose -Message "$($MyInvocation.MyCommand.Name): Script:Config: $($Script:Config | ConvertTo-Json -Compress)"
    if (!$Script:Config) {
        Write-Error 'Missing configuration' -ErrorAction Stop
    }
    switch ($Script:Config.AuthenticationMethod) {
        'Basic' {
            $Authributes.Credential = $Script:Config.Credential
            break
        }
        'Certificate' {
            $Authributes.Certificate = $Script:Config.Certificate
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
        'Accept'         = "application/json;version=$($Version)"
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
    Write-Verbose -Message "$($MyInvocation.MyCommand.Name): Invoke-RestMethod $($Splattributes | ConvertTo-Json -Compress)"
    Invoke-RestMethod @Splattributes
}