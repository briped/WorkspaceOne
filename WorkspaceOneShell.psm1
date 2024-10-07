<#PSScriptInfo

.VERSION 2024.10.7.1

.GUID d16a1243-3ecb-403a-af51-8701bddf4cb6

.AUTHOR Brian Schmidt Pedersen

.COMPANYNAME N/A

.COPYRIGHT (c) Brian Schmidt Pedersen. All rights reserved.

.TAGS 

.LICENSEURI https://raw.githubusercontent.com/briped/WorkSpaceOneShell/main/LICENSE

.PROJECTURI https://github.com/briped/WorkspaceOneShell

.ICONURI https://play-lh.googleusercontent.com/SA6Tj62xWYGBNoFjV1dXNNv9nhjQ7Zo4fQZQSe11V043bBe-urbd0YNsH5LVT5O32cA

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS 

.EXTERNALSCRIPTDEPENDENCIES 

.RELEASENOTES


.PRIVATEDATA


#>
<#

.DESCRIPTION
Workspace ONE API PowerShell module for automating WS1.

.SYNOPSIS
WorkspaceONE API cmdlets
.NOTES
TODO
.EXAMPLE
TODO
#>
function Get-OSEnvironment {
    $OSEnv = @{}
    if ($IsLinux) {
        $OSEnv.User = [System.Environment]::GetEnvironmentVariable('USER')
        $OSEnv.Host = [System.Environment]::GetEnvironmentVariable('NAME')
        $OSEnv.Home = [System.Environment]::GetEnvironmentVariable('HOME')
    }
    elseif ($IsMacOS) {
        $OSEnv.User = [System.Environment]::GetEnvironmentVariable('USER')
        $OSEnv.Host = Invoke-Expression -Command 'scutil --get LocalHostName'
        $OSEnv.Home = [System.Environment]::GetEnvironmentVariable('HOME')
    }
    else {
        $OSEnv.User = [System.Environment]::GetEnvironmentVariable('USERNAME')
        $OSEnv.Host = [System.Environment]::GetEnvironmentVariable('COMPUTERNAME')
        $OSEnv.Home = [System.Environment]::GetEnvironmentVariable('USERPROFILE')
    }
    $OSEnv.UserHost = "$($OSEnv.User)@$($OSEnv.Host)"
    New-Object -TypeName PSCustomObject -Property $OSEnv
}
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
    $OSEnv | ConvertTo-Json -Compress
    $Script:Config | ConvertTo-Json -Compress
    if (!$Script:Config -or !$Script:Config.Name -or $Script:Config.Name -ne $OSEnv.UserHost) {
        Write-Error 'Missing configuration' -ErrorAction Stop
    }
    switch ($Script:Config.Method) {
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
        ContentType = "application/json;version=$(Version)"
        Headers     = $Headers
    }
    Write-Verbose -Message ($Splattributes | ConvertTo-Json -Compress)
    Invoke-RestMethod @Splattributes
}
function Get-Authorization {
    [CmdletBinding(DefaultParameterSetName = 'Basic')]
    param(
        [Parameter(Mandatory = $true)]
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
        [X509Certificate]
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
    switch ($PSCmdlet.ParameterSetName) {
        'Basic' {
            $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Credential.Password)
            $Username = $Credential.UserName
            $Password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
            $Authorization = "Basic $([System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes("$($Username):$($Password)")))"
            break
        }
        'Certificate' {
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
            break
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
<#
function Get-ApiHeader {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [Alias('ApiUrl')]
        [ValidateNotNullOrEmpty()]
        [string]
        $Url
        ,
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias('ApiKey')]
        [pscredential]
        $Key
        ,
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [pscredential]
        $Credential
    )
    $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Config.ApiCredential.Password)
    $ApiKey = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
    $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Credential.Password)
    $Username = $Credential.UserName
    $Password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
    $Secret = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes("$($Username):$($Password)"))
    Remove-Variable -Force -Name Password -ErrorAction SilentlyContinue
    $Script:Headers = @{
        'Accept'         = 'application/json'
        'Authorization'  = "Basic $($Secret)"
        'aw-tenant-code' = $ApiKey
    }
    $Script:Headers
}
#>
function New-ApiConfig {
    [CmdletBinding(DefaultParameterSetName = 'Basic')]
    param(
        [Parameter()]
        [Alias('PSPath')]
        [ValidateNotNullOrEmpty()]
        [System.IO.FileInfo]
        $Path
        ,
        [Parameter()]
        [Alias('ApiUri')]
        [ValidateNotNullOrEmpty()]
        [uri]
        $Uri
        ,
        [Parameter()]
        [Alias('ApiKey')]
        [ValidateNotNullOrEmpty()]
        [securestring]
        $Key
        ,
        <#
        [Parameter()]
        [Alias('AuthMethod', 'AuthenticationMethod')]
        [ValidateSet('Basic', 'Certificate', 'OAuth')]
        [string]
        $Method = 'Basic'
        ,
        #>
        [Parameter(ParameterSetName = 'Basic')]
        [ValidateNotNullOrEmpty()]
        [pscredential]
        $Credential
        ,
        [Parameter(ParameterSetName = 'Certificate')]
        [ValidateNotNullOrEmpty()]
        [X509Certificate]
        $Certificate
        ,
        [Parameter(ParameterSetName = 'CertificateFromStore')]
        [ValidateNotNullOrEmpty()]
        [string]
        $Thumbprint
        ,
        [Parameter(ParameterSetName = 'CertificateFromFile')]
        [ValidateNotNullOrEmpty()]
        [System.IO.FileInfo]
        $CertificatePath
        ,
        [Parameter(ParameterSetName = 'CertificateFromFile')]
        [ValidateNotNullOrEmpty()]
        [securestring]
        $CertificatePassword
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
    )
    $PSCmdlet.ParameterSetName
    break
    $OSEnv = Get-OSEnvironment
    $ConfigTable = @{
        Name   = $OSEnv.UserHost
    }

    while (!$Uri -or ($Uri -as [uri]).Scheme -notmatch 'https?') {
        $Uri = Read-Host -Prompt 'API URL'
    }
    $ConfigTable.ApiUrl = $Uri

    if (!$Key) {
        $Key = Read-Host -AsSecureString -Prompt 'API Key'
    }
    $ConfigTable.ApiKey = $Key

    <#
    if (!$Method -or $Method -ne $PSCmdlet.ParameterSetName) {
        $Method = $PSCmdlet.ParameterSetName
    }
    $ConfigTable.AuthenticationMethod = $Method
    #>

    switch ($PSCmdlet.ParameterSetName) {
        'Basic' {
            if (!$Credential -or $Credential.GetType().Name -ne 'PSCredential') {
                $Credential = Get-Credential -Message 'Admininistrator credentials'
            }
            $ConfigTable.Credential = $Credential
            break
        }
        'Certificate' {
            #$Certificate = 
            $ConfigTable.Certificate = $Certificate
            break
        }
        'CertificateFromStore' {
            if (!$Thumbprint -or (Get-Item)) {
                #$Certificate = 
            }
            
            $ConfigTable.Certificate = $Certificate
            break
        }
        'CertificateFromFile' {
            if (!$Certificate) {
                #$Certificate = 
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
    $Config = New-Object -TypeName PSCustomObject -Property $ConfigTable

    if (!$Path -or !(Test-Path -Path $Path -PathType Leaf -ErrorAction SilentlyContinue)) {
        Add-Type -AssemblyName System.Windows.Forms
        $FileBrowser = New-Object -TypeName System.Windows.Forms.SaveFileDialog
        $FileBrowser.InitialDirectory = $OSEnv.Home
        $FileBrowser.FileName = ".ws1config_$($UserHost).xml" 
        $FileBrowser.Filter = 'Common Language Infrastructure eXensible Markup Language (*.xml)|*.xml|All files (*.*)|*.*'
        $FileBrowser.ShowDialog() | Out-Null
        $Path = [System.IO.FileInfo]$FileBrowser.FileName
    }
    $Config | Export-Clixml -Path $Path
    return $Path
}
function Get-ApiConfig {
    [CmdletBinding()]
    param(
        [Parameter()]
        [Alias('PSPath')]
        [ValidateNotNullOrEmpty()]
        [System.IO.FileInfo]
        $Path
    )
    $OSEnv = Get-OSEnvironment
    if (!$Path -or !(Test-Path -Path $Path -PathType Leaf -ErrorAction SilentlyContinue)) {
        Add-Type -AssemblyName System.Windows.Forms
        $FileBrowser = New-Object -TypeName System.Windows.Forms.OpenFileDialog
        $FileBrowser.InitialDirectory = $OSEnv.Host
        $FileBrowser.FileName = ".ws1config_$($OSEnv.UserHost).xml"
        $FileBrowser.Filter = 'Common Language Infrastructure eXensible Markup Language (*.xml)|*.xml|All files (*.*)|*.*'
        $FileBrowser.ShowDialog() | Out-Null
        $Path = [System.IO.FileInfo]$FileBrowser.FileName
    }
    Import-Clixml -Path $Path.FullName
}
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
function Get-Notification {
    [CmdletBinding()]
    param(
        [Parameter()]
        [Alias('Start', 'PageStart')]
        [int]
        $Page
        ,
        [Parameter()]
        [Alias('Limit')]
        [int]
        $PageSize
        ,
        [Parameter()]
        [ValidateSet('Active' ,'Dismissed')]
        [string]
        $Status
    )
    $Uri = "$($Config.ApiUrl)/system/notifications"
    $Data = @{}
    if ($Page -and $Page -gt 0) { $Data.startIndex = $Page }
    if ($PageSize -and $PageSize -gt 0) { $Data.pageSize = $PageSize }
    if ($Status -and $Status -eq 'Dismissed') { $Data.active = $false }
    $Query = @()
    foreach ($k in $Data.Keys) {
        $Query += "$($k)=$($Data[$k])"
    }
    if ($Query.Count -gt 0) { $Uri = "$($Uri)?$($Query -join '&')" }
    $Splattributes = @{
        Uri = $Uri
        Method = 'GET'
    }
    Write-Verbose -Message ($Splattributes | ConvertTo-Json -Compress)
    Invoke-ApiRequest @Splattributes
}
function Clear-Notification {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true)]
        [int]
        $Id
        ,
        [Parameter()]
        [switch]
        $Force
    )
    if ($Force -and !$Confirm) {
        $ConfirmPreference = 'None'
    }
    # TODO: Update the ShouldProcess text
    if ($PSCmdlet.ShouldProcess("Dismiss Notification ID '$($Id)'.")) {
        $Splattributes = @{
            Uri = "$($Config.ApiUrl)/system/notifications/$($Id)"
            Method = 'POST'
        }
        Write-Verbose -Message ($Splattributes | ConvertTo-Json -Compress)
        Invoke-ApiRequest @Splattributes
    }
}
function Find-PurchasedApp {
    [CmdletBinding()]
    param(
        [Parameter()]
        [Alias('AppName', 'ApplicationName')]
        [string]
        $Name
        ,
        [Parameter()]
        [string]
        $Assigned
        ,
        [Parameter()]
        [string]
        $BundleId
        ,
        [Parameter()]
        [int]
        $LocationGroupId
        ,
        [Parameter()]
        [string]
        $OrganizationGroupUuid
        ,
        [Parameter()]
        [ValidateSet('iPhone', 'iPad')]
        [string]
        $Model
        ,
        [Parameter()]
        [string]
        $Status
        ,
        [Parameter()]
        [string]
        $Platform
        ,
        [Parameter()]
        [Alias('Start', 'PageStart')]
        [int]
        $Page
        ,
        [Parameter()]
        [Alias('Limit')]
        [int]
        $PageSize
        ,
        [Parameter()]
        [string]
        $OrderBy
    )
    $Uri = "$($Config.ApiUrl)/mam/apps/purchased/search"
	$Data = @{}
    if ($Name) { $Data.applicationName = $Name }
    if ($Assigned) { $Data.isAssigned = $Assigned }
    if ($BundleId) { $Data.bundleId = $BundleId }
    if ($LocationGroupId -and $LocationGroupId -gt 0) { $Data.locationGroupId = $LocationGroupId }
    if ($OrganizationGroupUuid) { $Data.organizationGroupUuid = $OrganizationGroupUuid }
    if ($Model) { $Data.model = $Model }
    if ($Status) { $Data.status = $Status }
    if ($Platform) { $Data.platform = $Platform }
    if ($Page -and $Page -gt 0) { $Data.startIndex = $Page }
    if ($PageSize -and $PageSize -gt 0) { $Data.pageSize = $PageSize }
    if ($OrderBy) { $Data.orderBy = $OrderBy }
    $Query = @()
    foreach ($k in $Data.Keys) {
        $Query += "$($k)=$($Data[$k])"
    }
    if ($Query.Count -gt 0) { $Uri = "$($Uri)?$($Query -join '&')" }
    $Splattributes = @{
        Uri = $Uri
        Method = 'GET'
    }
    Write-Verbose -Message ($Splattributes | ConvertTo-Json -Compress)
    $Response = Invoke-ApiRequest @Splattributes
    $Response.Application
}
function Get-DeviceWithPurchasedApp {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [Alias('AppId')]
        [int]
        $ApplicationId
        ,
        [Parameter(Mandatory = $true)]
        [ValidateSet('Installed', 'Assigned')]
        [string]
        $Status
        ,
        [Parameter()]
        [int]
        $LocationGroupId
        ,
        [Parameter()]
        [Alias('Start', 'PageStart')]
        [int]
        $Page
        ,
        [Parameter()]
        [Alias('Limit')]
        [int]
        $PageSize
    )
    $Uri = "$($Config.ApiUrl)/mam/apps/purchased/$($ApplicationId)/devices"
    $Data = @{}
    if ($Status) { $Data.status = $Status.ToLower() }
    if ($LocationGroupId -and $LocationGroupId -gt 0) { $Data.locationGroupId = $LocationGroupId }
    if ($Page -and $Page -gt 0) { $Data.page = $Page }
    if ($PageSize -and $PageSize -gt 0) { $Data.pageSize = $PageSize }
    $Query = @()
    foreach ($k in $Data.Keys) {
        $Query += "$($k)=$($Data[$k])"
    }
    if ($Query.Count -gt 0) { $Uri = "$($Uri)?$($Query -join '&')" }
    $Splattributes = @{
        Uri = $Uri
        Method = 'GET'
    }
    Write-Verbose -Message ($Splattributes | ConvertTo-Json -Compress)
    $Response = Invoke-ApiRequest @Splattributes
    $Response.DeviceId
}
function Get-PurchasedApp {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [Alias('AppId', 'ApplicationId')]
        [int]
        $Id
    )
    $Splattributes = @{
        Uri = "$($Config.ApiUrl)/mam/apps/purchased/$($Id)"
        Method = 'GET'
    }
    Write-Verbose -Message ($Splattributes | ConvertTo-Json -Compress)
    $Response = Invoke-ApiRequest @Splattributes
    $Response.Application
}
function Install-PurchasedAppV1 {
    [CmdletBinding(DefaultParameterSetName = 'ID'
                  ,SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true
                  ,ParameterSetName = 'ID')]
        [int]
        $DeviceId
        ,
        [Parameter(Mandatory = $true
                  ,ParameterSetName = 'UUID')]
        [int]
        $DeviceUuid
        ,
        [Parameter(Mandatory = $true
                  ,ParameterSetName = 'UDID')]
        [int]
        $DeviceUdid
        ,
        [Parameter(Mandatory = $true
                  ,ParameterSetName = 'SerialNumber')]
        [int]
        $SerialNumber
        ,
        [Parameter(Mandatory = $true
                  ,ParameterSetName = 'ID')]
        [Alias('AppId')]
        [int]
        $ApplicationId
        ,
        [Parameter(Mandatory = $true
                  ,ParameterSetName = 'UUID')]
        [Alias('AppUuid')]
        [int]
        $ApplicationUuid
        ,
        [Parameter()]
        [switch]
        $Force
    )
    if ($Force -and !$Confirm) {
        $ConfirmPreference = 'None'
    }
    $Data = @{
        DeviceId = $DeviceID
    }
    # TODO: Update the ShouldProcess text
    if ($PSCmdlet.ShouldProcess("Install Application ID '$($ApplicationId)' on Device ID '$($DeviceId)'.")) {
        $Splattributes = @{
            Uri = "$($Config.ApiUrl)/mam/apps/purchased/$($ApplicationId)/install"
            Method = 'POST'
            Body = $Data | ConvertTo-Json -Compress
        }
        Write-Verbose -Message ($Splattributes | ConvertTo-Json -Compress)
        Invoke-ApiRequest @Splattributes
    }
}
function Install-PurchasedAppV2 {
    [CmdletBinding(DefaultParameterSetName = 'UUID'
                  ,SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true
                  ,ParameterSetName = 'UUID')]
        [int]
        $DeviceUuid
        ,
        [Parameter(Mandatory = $true
                  ,ParameterSetName = 'UDID')]
        [int]
        $DeviceUdid
        ,
        [Parameter(Mandatory = $true
                  ,ParameterSetName = 'SerialNumber')]
        [int]
        $SerialNumber
        ,
        [Parameter(Mandatory = $true)]
        [Alias('AppUUID')]
        [int]
        $ApplicationUuid
        ,
        [Parameter()]
        [switch]
        $Force
    )
    if ($Force -and !$Confirm) {
        $ConfirmPreference = 'None'
    }
    $Data = @{
        DeviceId = $DeviceId
    }
    # TODO: Update the ShouldProcess text
    if ($PSCmdlet.ShouldProcess("Install Application UUID '$($ApplicationUuid)' on Device UUID '$($DeviceUuid)'.")) {
        $Splattributes = @{
            Uri = "$($Config.ApiUrl)/mam/apps/purchased/$($ApplicationUuid)/install"
            Method = 'POST'
            Body = $Data | ConvertTo-Json -Compress
        }
        Write-Verbose -Message ($Splattributes | ConvertTo-Json -Compress)
        Invoke-ApiRequest @Splattributes
    }
}
function Remove-PurchasedAppV1 {
    [CmdletBinding(DefaultParameterSetName = 'ID'
                  ,SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true
                  ,ParameterSetName = 'ID')]
        [int]
        $DeviceId
        ,
        [Parameter(Mandatory = $true
                  ,ParameterSetName = 'UUID')]
        [int]
        $DeviceUuid
        ,
        [Parameter(Mandatory = $true
                  ,ParameterSetName = 'UDID')]
        [int]
        $DeviceUdid
        ,
        [Parameter(Mandatory = $true
                  ,ParameterSetName = 'SerialNumber')]
        [int]
        $SerialNumber
        ,
        [Parameter(Mandatory = $true)]
        [Alias('AppID')]
        [int]
        $ApplicationId
        ,
        [Parameter()]
        [switch]
        $Force
    )
    if ($Force -and !$Confirm) {
        $ConfirmPreference = 'None'
    }
    $Data = @{
        DeviceId = $DeviceId
    }
    # TODO: Update the ShouldProcess text
    if ($PSCmdlet.ShouldProcess("Install Application ID '$($ApplicationId)' on Device ID '$($DeviceId)'.")) {
        $Splattributes = @{
            Uri = "$($Config.ApiUrl)/mam/apps/purchased/$($ApplicationId)/uninstall"
            Method = 'POST'
            Body = $Data | ConvertTo-Json -Compress
        }
        Write-Verbose -Message ($Splattributes | ConvertTo-Json -Compress)
        Invoke-ApiRequest @Splattributes
    }
}
function Remove-PurchasedAppV2 {
    [CmdletBinding(DefaultParameterSetName = 'UUID'
                  ,SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true
                  ,ParameterSetName = 'UUID')]
        [int]
        $DeviceUuid
        ,
        [Parameter(Mandatory = $true
                  ,ParameterSetName = 'UDID')]
        [int]
        $DeviceUdid
        ,
        [Parameter(Mandatory = $true
                  ,ParameterSetName = 'SerialNumber')]
        [int]
        $SerialNumber
        ,
        [Parameter(Mandatory = $true)]
        [Alias('AppUuid')]
        [int]
        $ApplicationUuid
        ,
        [Parameter()]
        [switch]
        $Force
    )
    if ($Force -and !$Confirm) {
        $ConfirmPreference = 'None'
    }
    $Data = @{
        DeviceId = $DeviceId
    }
    # TODO: Update the ShouldProcess text
    if ($PSCmdlet.ShouldProcess("Install Application UUID '$($ApplicationUuid)' on Device UUID '$($DeviceUuid)'.")) {
        $Splattributes = @{
            Uri = "$($Config.ApiUrl)/mam/apps/purchased/$($ApplicationUuid)/uninstall"
            Method = 'POST'
            Body = $Data | ConvertTo-Json -Compress
        }
        Write-Verbose -Message ($Splattributes | ConvertTo-Json -Compress)
        Invoke-ApiRequest @Splattributes
    }
}
function Update-PurchasedAppV1 {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true)]
        [Alias('AppId', 'ApplicationId')]
        [int]
        $Id
        ,
        [Parameter()]
        [switch]
        $Force
    )
    if ($Force -and !$Confirm) {
        $ConfirmPreference = 'None'
    }
    # TODO: Update the ShouldProcess text
    if ($PSCmdlet.ShouldProcess("Update Application ID '$($ApplicationId)' on devices.")) {
        $Splattributes = @{
            Uri = "$($Config.ApiUrl)/mam/apps/purchased/$($ApplicationId)"
            Method = 'POST'
        }
        Write-Verbose -Message ($Splattributes | ConvertTo-Json -Compress)
        Invoke-ApiRequest @Splattributes
    }
}
function Find-DeviceV1 {
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]
        $User
        ,
        [Parameter()]
        [ValidateSet('iPhone', 'iPad')]
        [string]
        $Model
        ,
        [Parameter()]
        [ValidateSet('Apple', 'Android')]
        [string]
        $Platform
        ,
        [Parameter()]
        [ValidateSet('C', 'E', 'S', 'Undefined')]
        [string]
        $Ownership
        ,
        [Parameter()]
        [bool]
        $Compliant
        ,
        [Parameter()]
        [string]
        $OrganizationGroupUuid # lgid #TODO: Follow-up check if LocationGroupId rather than OrganisationGroupUuid.
        ,
        [Parameter()]
        [datetime]
        $LastSeen
        ,
        [Parameter()]
        [datetime]
        $SeenSince
        ,
        [Parameter()]
        [Alias('Start', 'PageStart')]
        [int]
        $Page
        ,
        [Parameter()]
        [Alias('Limit')]
        [int]
        $PageSize
        ,
        [Parameter()]
        [ValidateSet('LastSeen', 'Ownership', 'Platform', 'DeviceId')]
        [string]
        $OrderBy
        ,
        [Parameter()]
        [Alias('Sort')]
        [ValidateSet('ASC', 'DESC')]
        [string]
        $SortOrder
    )
    $Uri = "$($Config.ApiUrl)/mdm/devices/search"
    $Data = @{}
    if ($User) { $Data.user = $User }
    if ($Model) { $Data.model = $Model }
    if ($Platform) { $Data.platform = $Platform }
    if ($Ownership) { $Data.ownership = $Ownership }
    if ($Compliance) { $Data.compliance_status = $Compliance }
    if ($Page -and $Page -gt 0) { $Data.page = $Page }
    if ($PageSize -and $PageSize -gt 0) { $Data.pagesize = $PageSize }
    if ($OrderBy) { $Data.orderby = $OrderBy }
    if ($SortOrder -and $SortOrder -ne 'ASC') { $Data.sortorder = $SortOrder }
    $Query = @()
    foreach ($k in $Data.Keys) {
        $Query += "$($k)=$($Data[$k])"
    }
    if ($Query.Count -gt 0) { $Uri = "$($Uri)?$($Query -join '&')" }
    $Splattributes = @{
        Uri = $Uri
        Method = 'GET'
    }
    Invoke-ApiRequest @Splattributes
}
function Find-DeviceV2 {
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]
        $User
        ,
        [Parameter()]
        [ValidateSet('iPhone'
                    ,'iPad')]
        [string]
        $Model
        ,
        [Parameter()]
        [ValidateSet('Apple', 'Android')]
        [string]
        $Platform
        ,
        [Parameter()]
        [ValidateSet('C', 'E', 'S', 'Undefined')]
        [string]
        $Ownership
        ,
        [Parameter()]
        [string]
        $Compliance
        ,
        [Parameter()]
        [string]
        $OrganizationGroupUuid # lgid #TODO: Follow-up check if LocationGroupId rather than OrganisationGroupUuid.
        ,
        [Parameter()]
        [datetime]
        $LastSeen
        ,
        [Parameter()]
        [datetime]
        $SeenSince
        ,
        [Parameter()]
        [Alias('Start', 'StartPage')]
        [int]
        $Page
        ,
        [Parameter()]
        [Alias('Limit')]
        [int]
        $PageSize
        ,
        [Parameter()]
        [string]
        $OrderBy
        ,
        [Parameter()]
        [Alias('Sort')]
        [ValidateSet('ASC', 'DESC')]
        [string]
        $SortOrder
    )
    $Uri = "$($Config.ApiUrl)/mdm/devices/search"
    $Data = @{}
    if ($User) { $Data.user = $User }
    if ($Model) { $Data.model = $Model }
    if ($Platform) { $Data.platform = $Platform }
    if ($Ownership) { $Data.ownership = $Ownership }
    if ($Compliance) { $Data.compliance_status = $Compliance }
    if ($Page -and $Page -gt 0) { $Data.page = $Page }
    if ($PageSize -and $PageSize -gt 0) { $Data.pagesize = $PageSize }
    if ($OrderBy) { $Data.orderby = $OrderBy }
    if ($SortOrder -and $SortOrder -ne 'ASC') { $Data.sortorder = $SortOrder }
    $Query = @()
    foreach ($k in $Data.Keys) {
        $Query += "$($k)=$($Data[$k])"
    }
    if ($Query.Count -gt 0) { $Uri = "$($Uri)?$($Query -join '&')" }
    $Splattributes = @{
        Uri = $Uri
        Method = 'GET'
    }
    Invoke-ApiRequest @Splattributes
}
function Find-DeviceV3 {
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]
        $User
        ,
        [Parameter()]
        [string]
        $Ownership
        ,
        [Parameter()]
        [string]
        $Compliance
        ,
        [Parameter()]
        [string]
        $OrganizationGroupUuid
        ,
        [Parameter()]
        [string]
        $ModelId
        ,
        [Parameter()]
        [ValidateSet('Apple', 'Android')]
        [string]
        $Platform
        ,
        [Parameter()]
        [Alias('Start', 'PageStart')]
        [int]
        $Page
        ,
        [Parameter()]
        [Alias('Limit')]
        [int]
        $PageSize
        ,
        [Parameter()]
        [string]
        $OrderBy
        ,
        [Parameter()]
        [Alias('Sort')]
        [ValidateSet('ASC', 'DESC')]
        [string]
        $SortOrder
    )
    $Uri = "$($Config.ApiUrl)/mdm/devices/search"
	$Data = @{}
    if ($User) { $Data.user = $User }
    if ($Ownership) { $Data.ownership = $Ownership }
    if ($Compliance) { $Data.compliance_status = $Compliance }
    if ($OrganizationGroupUuid) { $Data.organization_group_uuid = $OrganizationGroupUuid }
    if ($ModelID) { $Data.model_identifier = $ModelID }
    if ($Platform) { $Data.device_type = $Platform }
    if ($Page -and $Page -gt 0) { $Data.page = $Page }
    if ($PageSize -and $PageSize -gt 0) { $Data.page_size = $PageSize }
    if ($OrderBy) { $Data.order_by = $OrderBy }
    if ($SortOrder -and $SortOrder -ne 'ASC') { $Data.sort_order = $SortOrder }
	$Query = @()
	foreach ($k in $Data.Keys) {
		$Query += "$($k)=$($Data[$k])"
	}
    if ($Query.Count -gt 0) { $Uri = "$($Uri)?$($Query -join '&')" }
    $Splattributes = @{
        Uri = $Uri
        Method = 'GET'
    }
    Invoke-ApiRequest @Splattributes
}
function Find-DeviceV4 {
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]
        $OrganizationGroupUuid
        ,
        [Parameter()]
        [ValidateSet('iPhone', 'iPad')]
        [string[]]
        $Model
        ,
        [Parameter()]
        [Alias('Start', 'PageStart')]
        [int]
        $Page
        ,
        [Parameter()]
        [Alias('Limit')]
        [int]
        $PageSize
        ,
        [Parameter()]
        [string]
        $OrderBy
    )
    # TODO: Implement it.
    Write-Output 'Not implemented yet'
}
function Get-DeviceById {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]
        $Id
    )
    $Splattributes = @{
        Uri = "$($Config.ApiUrl)/mdm/devices/$($Id)"
        Method = 'GET'
    }
    Invoke-ApiRequest @Splattributes
    # TODO: Combine Get-DeviceById and Get-DeviceByUdid
}
function Get-DeviceByUdid {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]
        $Udid
    )
    $Splattributes = @{
        Uri = "$($Config.ApiUrl)/mdm/devices/udid/$($Udid)"
        Method = 'GET'
    }
    Invoke-ApiRequest @Splattributes
    # TODO: Combine Get-DeviceById and Get-DeviceByUdid
}
function Get-DeviceV2 {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]
        $Uuid
    )
    $Splattributes = @{
        Uri = "$($Config.ApiUrl)/mdm/devices/$($Uuid)"
        Method = 'GET'
    }
    Invoke-ApiRequest @Splattributes
}
function Get-DeviceV3 {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]
        $Uuid
    )
    $Splattributes = @{
        Uri = "$($Config.ApiUrl)/mdm/devices/$($Uuid)"
        Method = 'GET'
    }
    Invoke-ApiRequest @Splattributes
}
#New-Variable -Force -Scope Script -Name Headers -Value $null
#New-Variable -Force -Scope Script -Name ApiKey -Value $null
New-Variable -Force -Scope Script -Name Config -Value $null
