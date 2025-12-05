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
    Remove-Variable -Force -Name Authributes -ErrorAction SilentlyContinue
    Write-Verbose -Message "$($MyInvocation.MyCommand.Name): Script:Config: $($Script:Config | ConvertTo-Json -Compress -Depth 5)"
    if (!$Script:Config) {
        Write-Error 'Missing configuration' -ErrorAction Stop
    }
    switch ($Script:Config.AuthenticationMethod) {
        'Basic' {
            $Authributes = @{
                Credential = $Script:Config.Credential
            }
            break
        }
        'Certificate' {
            $Authributes = @{
                Uri = $Uri
                Certificate = $Script:Config.Certificate
            }
            break
        }
        'OAuth' {
            $Authributes = @{
                OAuthUrl = $Script:Config.OAuthUrl
                OAuthCredential = $Script:Config.OAuthCredential
            }
            break
        }
        Default {
            Write-Error -Message "Unknown authentication method: $($Script:Config.AuthenticationMethod)"
        }
    }
    Write-Verbose -Message "$($MyInvocation.MyCommand.Name): Get-Authorization $($Authributes | ConvertTo-Json -Compress -Depth 5)"
    $Authorization = Get-Authorization @Authributes

    $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Script:Config.ApiKey)
    $ApiKey = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
    $Headers = @{
        'Accept'         = "application/json;version=$($Version)"
        'Authorization'  = $Authorization
        'aw-tenant-code' = $ApiKey
    }

    $Attributes = @{
        Uri         = $Uri
        Method      = $Method
        ContentType = "application/json;version=$($Version)"
        Headers     = $Headers
    }
    if ($Body) {
        $Attributes.Body = $Body
    }
    Write-Verbose -Message "$($MyInvocation.MyCommand.Name): Invoke-RestMethod $($Attributes | ConvertTo-Json -Compress)"
    Invoke-RestMethod @Attributes
    <#
    .SYNOPSIS
    Invoke a REST API call against the Workspace ONE API.

    .DESCRIPTION
    Adds the proper authentication headers and calls the Workspace ONE API using the specified parameters.

    .PARAMETER Uri
    The API URL to call.

    .PARAMETER Method
    The HTTP method to use.

    .PARAMETER Body
    The API payload/body.

    .PARAMETER Version
    The API Version to use.

    .PARAMETER ContentType
    The content type to use. 
    Default: application/json

    .NOTES
    .EXAMPLE
    #>
}