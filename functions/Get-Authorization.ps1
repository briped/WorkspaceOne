<#
.SYNOPSIS
Gets the authorization details.

.DESCRIPTION
Returns the authorization to be used in the header when accessing the API.

.PARAMETER Uri
The URL for which to authenticate against.

.PARAMETER Credential
PSCredential containing the username and password for Basic Auth.

.PARAMETER Certificate
The certificate (with private key) to use for Certificate Auth.

.PARAMETER OAuthUrl
The OAuth URL for authenticating using OAuth.

.PARAMETER OAuthCredential
PSCredential containing the Client ID (username) and Client Secret (password) for use with OAuth.

.NOTES
.EXAMPLE
#>
function Get-Authorization {
    [CmdletBinding(DefaultParameterSetName = 'Basic')]
    param(
        [Parameter(Mandatory = $true
                ,  ParameterSetName = 'Certificate')]
        [ValidateNotNullOrEmpty()]
        [Alias('ApiUrl')]
        [uri]
        $Uri
        ,
        [Parameter(Mandatory = $true, ParameterSetName = 'Basic')]
        [ValidateNotNullOrEmpty()]
        [pscredential]
        $Credential
        ,
        [Parameter(Mandatory = $true, ParameterSetName = 'Certificate')]
        [ValidateNotNullOrEmpty()]
        [System.Security.Cryptography.X509Certificates.X509Certificate2]
        $Certificate
        ,
        [Parameter(ParameterSetName = 'OAuth')]
        [ValidateNotNullOrEmpty()]
        [Alias('TokenUrl')]
        [uri]
        $OAuthUrl = 'https://emea.uemauth.vmwservices.com/connect/token'
        ,
        [Parameter(ParameterSetName = 'OAuth')]
        [ValidateNotNullOrEmpty()]
        [pscredential]
        $OAuthCredential
    )
    Write-Verbose -Message "$($MyInvocation.MyCommand.Name): Authentication Method: $($PSCmdlet.ParameterSetName)"
    switch ($PSCmdlet.ParameterSetName) {
        'Basic' {
            $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Credential.Password)
            $Username = $Credential.UserName
            $Password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
            $Authorization = "Basic $([System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes("$($Username):$($Password)")))"
            break
        }
        'Certificate' {
            Add-Type -AssemblyName System.Security
            $AbsolutePath = $Uri.AbsolutePath
            $Bytes = [System.Text.Encoding]::UTF8.GetBytes($AbsolutePath)
            $ContentInfo = [System.Security.Cryptography.Pkcs.ContentInfo]::new($Bytes)
            $SignedCms = [System.Security.Cryptography.Pkcs.SignedCms]::new($ContentInfo, $true)
            $CmsSigner = [System.Security.Cryptography.Pkcs.CmsSigner]::new($Certificate)
            $CmsSigner.IncludeOption = [System.Security.Cryptography.X509Certificates.X509IncludeOption]::EndCertOnly
            $CmsSigner.SignedAttributes.Add([System.Security.Cryptography.Pkcs.Pkcs9SigningTime]::new()) | Out-Null
            $SignedCms.ComputeSignature($CmsSigner)
            $Authorization = 'CMSURL`1 '
            $Authorization += [System.Convert]::ToBase64String($SignedCms.Encode())
            break
        }
        'OAuth' {
            $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($OAuthCredential.Password)
            $OAuthClientId = $OAuthCredential.UserName
            $OAuthClientSecret = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
            break #TODO Complete and test implementation
            # https://docs.omnissa.com/bundle/WorkspaceONE-UEM-Console-BasicsVSaaS/page/UsingUEMFunctionalityWithRESTAPI.html
            $Payload = @{
                grant_type = 'client_credentials'
                client_id = $OAuthClientId
                client_secret = $OAuthClientSecret
            } | ConvertTo-Json -Compress
            $Splattributes = @{
                Uri = $OAuthUrl
                Method = 'POST'
                ContentType = 'application/json'
                Body = $Payload
            }
            $Response = Invoke-RestMethod @Splattributes
            $Authorization = "Bearer $($Response.access_token)"
            break
        }
    }
    $Authorization
}