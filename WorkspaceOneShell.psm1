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
function New-ApiConfig {
    [CmdletBinding()]
    param(
        [Parameter()]
        [Alias('PSPath')]
        [ValidateNotNullOrEmpty()]
        [System.IO.FileInfo]
        $Path
        ,
        [Parameter()]
        [Alias('ApiUrl')]
        [ValidateNotNullOrEmpty()]
        [string]
        $Url
    )
    #TODO: Add Credential and API key parameters
    if ($IsLinux) {
        $EnvUser = 'USER'
        $EnvName = 'NAME'
        $EnvHome = 'HOME'
    }
    else {
        $EnvUser = 'USERNAME'
        $EnvName = 'COMPUTERNAME'
        $EnvHome = 'USERPROFILE'
    }
    $HostUser = [System.Environment]::GetEnvironmentVariable($EnvUser)
    $HostName = [System.Environment]::GetEnvironmentVariable($EnvName)
    $HostHome = [System.Environment]::GetEnvironmentVariable($EnvHome)
    $UserHost = "$($HostUser)@$($HostName)"
    if (!$Url -or ($Url -as [uri]).Scheme -notmatch 'https?') {
        $Url = Read-Host -Prompt 'Workspace ONE API URL'
    }
    $Config = New-Object -TypeName PSCustomObject -Property @{
        Name = $UserHost
        ApiUrl = [uri]$Url
        ApiCredential = (Get-Credential -Message 'Workspace ONE API key' -UserName 'aw-tenant-code')
        Ws1Credential = (Get-Credential -Message 'Workspace ONE admin')
    }
    if (!$Path -or !(Test-Path -Path $Path -PathType Leaf -ErrorAction SilentlyContinue)) {
        Add-Type -AssemblyName System.Windows.Forms
        $FileBrowser = New-Object -TypeName System.Windows.Forms.SaveFileDialog
        $FileBrowser.InitialDirectory = $HostHome
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
    if ($IsLinux) {
        $EnvUser = 'USER'
        $EnvName = 'NAME'
        $EnvHome = 'HOME'
    }
    else {
        $EnvUser = 'USERNAME'
        $EnvName = 'COMPUTERNAME'
        $EnvHome = 'USERPROFILE'
    }
    $HostUser = [System.Environment]::GetEnvironmentVariable($EnvUser)
    $HostName = [System.Environment]::GetEnvironmentVariable($EnvName)
    $HostHome = [System.Environment]::GetEnvironmentVariable($EnvHome)
    $UserHost = "$($HostUser)@$($HostName)"
    if (!$Path -or !(Test-Path -Path $Path -PathType Leaf -ErrorAction SilentlyContinue)) {
        Add-Type -AssemblyName System.Windows.Forms
        $FileBrowser = New-Object -TypeName System.Windows.Forms.OpenFileDialog
        $FileBrowser.InitialDirectory = $HostHome
        $FileBrowser.FileName = ".ws1config_$($UserHost).xml"
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
        Method = 'GET'
        ContentType = 'application/json'
        Headers = $Headers
        Uri = $Uri
    }
    Write-Verbose -Message ($Splattributes | ConvertTo-Json -Compress)
    Invoke-RestMethod @Splattributes
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
            Method = 'POST'
            ContentType = 'application/json'
            Headers = $Headers
            Uri = "$($Config.ApiUrl)/system/notifications/$($Id)"
        }
        Write-Verbose -Message ($Splattributes | ConvertTo-Json -Compress)
        Invoke-RestMethod @Splattributes
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
        Method = 'GET'
        ContentType = 'application/json'
        Headers = $Headers
        Uri = $Uri
    }
    Write-Verbose -Message ($Splattributes | ConvertTo-Json -Compress)
    $Response = Invoke-RestMethod @Splattributes
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
        Method = 'GET'
        ContentType = 'application/json'
        Headers = $Headers
        Uri = $Uri
    }
    Write-Verbose -Message ($Splattributes | ConvertTo-Json -Compress)
    $Response = Invoke-RestMethod @Splattributes
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
        Method = 'GET'
        ContentType = 'application/json'
        Headers = $Headers
        Uri = "$($Config.ApiUrl)/mam/apps/purchased/$($Id)"
    }
    Write-Verbose -Message ($Splattributes | ConvertTo-Json -Compress)
    $Response = Invoke-RestMethod @Splattributes
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
            Method = 'POST'
            ContentType = 'application/json'
            Header = $Headers
            Uri = "$($Config.ApiUrl)/mam/apps/purchased/$($ApplicationId)/install"
            Body = $Data | ConvertTo-Json -Compress
        }
        Write-Verbose -Message ($Splattributes | ConvertTo-Json -Compress)
        Invoke-RestMethod @Splattributes
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
            Method = 'POST'
            ContentType = 'application/json'
            Header = $Headers
            Uri = "$($Config.ApiUrl)/mam/apps/purchased/$($ApplicationUuid)/install"
            Body = $Data | ConvertTo-Json -Compress
        }
        Write-Verbose -Message ($Splattributes | ConvertTo-Json -Compress)
        Invoke-RestMethod @Splattributes
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
            Method = 'POST'
            ContentType = 'application/json'
            Header = $Headers
            Uri = "$($Config.ApiUrl)/mam/apps/purchased/$($ApplicationId)/uninstall"
            Body = $Data | ConvertTo-Json -Compress
        }
        Write-Verbose -Message ($Splattributes | ConvertTo-Json -Compress)
        Invoke-RestMethod @Splattributes
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
            Method = 'POST'
            ContentType = 'application/json'
            Header = $Headers
            Uri = "$($Config.ApiUrl)/mam/apps/purchased/$($ApplicationUuid)/uninstall"
            Body = $Data | ConvertTo-Json -Compress
        }
        Write-Verbose -Message ($Splattributes | ConvertTo-Json -Compress)
        Invoke-RestMethod @Splattributes
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
            Method = 'POST'
            ContentType = 'application/json'
            Header = $Headers
            Uri = "$($Config.ApiUrl)/mam/apps/purchased/$($ApplicationId)"
        }
        Write-Verbose -Message ($Splattributes | ConvertTo-Json -Compress)
        Invoke-RestMethod @Splattributes
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
        Method = 'GET'
        ContentType = 'application/json'
        Headers = $Headers
        Uri = $Uri
    }
    Invoke-RestMethod @Splattributes
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
        Method = 'GET'
        ContentType = 'application/json'
        Headers = $Headers
        Uri = $Uri
    }
    Invoke-RestMethod @Splattributes
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
        Method = 'GET'
        ContentType = 'application/json'
        Headers = $Headers
        Uri = $Uri
    }
    Invoke-RestMethod @Splattributes
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
        Method = 'GET'
        ContentType = 'application/json'
        Headers = $Headers
        Uri = "$($Config.ApiUrl)/mdm/devices/$($Id)"
    }
    Invoke-RestMethod @Splattributes
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
        Method = 'GET'
        ContentType = 'application/json'
        Headers = $Headers
        Uri = "$($Config.ApiUrl)/mdm/devices/udid/$($Udid)"
    }
    Invoke-RestMethod @Splattributes
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
        Method = 'GET'
        ContentType = 'application/json'
        Headers = $Headers
        Uri = "$($Config.ApiUrl)/mdm/devices/$($Uuid)"
    }
    Invoke-RestMethod @Splattributes
}
function Get-DeviceV3 {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]
        $Uuid
    )
    $Splattributes = @{
        Method = 'GET'
        ContentType = 'application/json'
        Headers = $Headers
        Uri = "$($Config.ApiUrl)/mdm/devices/$($Uuid)"
    }
    Invoke-RestMethod @Splattributes
}
New-Variable -Force -Scope Script -Name Headers -Value $null