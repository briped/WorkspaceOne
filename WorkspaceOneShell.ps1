function New-Config {
    [CmdletBinding()]
    param(
        # Path to CliXML config.
        [Parameter()]
        [Alias('PSPath')]
        [ValidateNotNullOrEmpty()]
        [System.IO.FileInfo]
        $Path
        ,
        # URL to Workspace ONE API.
        [Parameter(HelpMessage = 'URL to Workspace ONE API')]
        [Alias('ApiUrl')]
        [ValidateNotNullOrEmpty()]
        [string]
        $Url
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
    if (!$Url -or ($Url -as [uri]).Scheme -notmatch 'https?') {
        $Url = Read-Host -Prompt 'Workspace ONE APO URL'
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
function Get-Config {
    [CmdletBinding()]
    param(
        # Path to CliXML config.
        [Parameter(Position = 0
                  ,ValueFromPipeline = $true
                  ,ValueFromPipelineByPropertyName = $true)]
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
        # App URL
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
        # Starting index if multiple pages.
        [Parameter()]
        [Alias('Start', 'PageStart')]
        [int]
        $Page
        ,
        # Results per page.
        [Parameter()]
        [Alias('Limit')]
        [int]
        $PageSize
        ,
        # Active/dismissed notifications.
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
        # Notification ID.
        [Parameter(Mandatory = $true)]
        [int]
        $Id
		,
		# Force action.
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
        [Alias('ApplicationName'
              ,'AppName')]
        [string]
        $Name
        ,
        # Flag to indicate whether the app is assigned or not, for example - true.
        [Parameter()]
        [string]
        $Assigned
        ,
        # BundleId/PackageId, for example - xyz.Angrybirds.com.
        [Parameter()]
        [string]
        $BundleId
        ,
        # LocationGroup Identifier, for example - 777.
        [Parameter()]
        [int]
        $LocationGroupId
        ,
        # OrganizationGroup Identifier.
        [Parameter()]
        [string]
        $OrganizationGroupUuid
        ,
        # Device Model, for example - iPhone.
        [Parameter()]
        [ValidateSet('iPhone'
                    ,'iPad')]
        [string]
        $Model
        ,
        # Application Status, for example - Active.
        [Parameter()]
        [string]
        $Status
        ,
        # The Application Platform, for example - Apple.
        [Parameter()]
        [string]
        $Platform
        ,
        # Specific page number to get. 0 based index.
        [Parameter()]
        [Alias('Start', 'StartPage')]
        [int]
        $Page
        ,
        # Maximumm records per page. Default 500.
        [Parameter()]
        [Alias('Limit')]
        [int]
        $PageSize
        ,
        # Orderby column name, for example - applicationname.
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
        # Application ID.
        [Parameter(Mandatory = $true
                  ,Position = 0
                  ,ValueFromPipeline = $true
                  ,ValueFromPipelineByPropertyName = $true)]
        [Alias('AppId')]
        [int]
        $ApplicationId
        ,
        # Status - installed/assigned.
        [Parameter(Mandatory = $true)]
        [ValidateSet('Installed'
                    ,'Assigned')]
        [string]
        $Status
        ,
        # The LocationGroup Identifier.
        [Parameter()]
        [int]
        $LocationGroupId
        ,
        # Starting index if multiple pages.
        [Parameter()]
        [Alias('PageStart')]
        [int]
        $Page
        ,
        # Results per page.
        [Parameter()]
        [Alias('Pages'
              ,'Size'
              ,'Count')]
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
function Install-PurchasedAppV1 {
    [CmdletBinding(DefaultParameterSetName = 'ID'
                  ,SupportsShouldProcess = $true)]
    param(
        # Device ID.
        [Parameter(Mandatory = $true
                  ,ParameterSetName = 'ID')]
        [int]
        $DeviceId
        ,
        # Device UUID.
        [Parameter(Mandatory = $true
                  ,ParameterSetName = 'UUID')]
        [int]
        $DeviceUuid
        ,
        # Device UDID.
        [Parameter(Mandatory = $true
                  ,ParameterSetName = 'UDID')]
        [int]
        $DeviceUdid
        ,
        # Device Serial Number.
        [Parameter(Mandatory = $true
                  ,ParameterSetName = 'SerialNumber')]
        [int]
        $SerialNumber
        ,
        # Application ID.
        [Parameter(Mandatory = $true
                  ,ParameterSetName = 'ID')]
        [Alias('AppId')]
        [int]
        $ApplicationID
        ,
        # Application UUID.
        [Parameter(Mandatory = $true
                  ,ParameterSetName = 'UUID')]
        [Alias('AppUuid')]
        [int]
        $ApplicationUuid
		,
		# Force action.
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
	if ($PSCmdlet.ShouldProcess("Install Application ID '$($ApplicationID)' on Device ID '$($DeviceID)'.")) {
		$Splattributes = @{
			Method = 'POST'
			ContentType = 'application/json'
			Header = $Headers
            Uri = "$($Config.ApiUrl)/mam/apps/purchased/$($ApplicationID)/install"
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
        # Device UUID.
        [Parameter(Mandatory = $true
                  ,ParameterSetName = 'UUID')]
        [int]
        $DeviceUUID
        ,
        # Device UDID.
        [Parameter(Mandatory = $true
                  ,ParameterSetName = 'UDID')]
        [int]
        $DeviceUDID
        ,
        # Device Serial Number.
        [Parameter(Mandatory = $true
                  ,ParameterSetName = 'SerialNumber')]
        [int]
        $SerialNumber
        ,
        # Application UUID.
        [Parameter(Mandatory = $true)]
        [Alias('AppUUID')]
        [int]
        $ApplicationUUID
		,
		# Force action.
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
	if ($PSCmdlet.ShouldProcess("Install Application UUID '$($ApplicationUUID)' on Device UUID '$($DeviceUUID)'.")) {
		$Splattributes = @{
			Method = 'POST'
			ContentType = 'application/json'
			Header = $Headers
            Uri = "$($Config.ApiUrl)/mam/apps/purchased/$($ApplicationUUID)/install"
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
        # Device ID.
        [Parameter(Mandatory = $true
                  ,ParameterSetName = 'ID')]
        [int]
        $DeviceID
        ,
        # Device UUID.
        [Parameter(Mandatory = $true
                  ,ParameterSetName = 'UUID')]
        [int]
        $DeviceUUID
        ,
        # Device UDID.
        [Parameter(Mandatory = $true
                  ,ParameterSetName = 'UDID')]
        [int]
        $DeviceUDID
        ,
        # Device Serial Number.
        [Parameter(Mandatory = $true
                  ,ParameterSetName = 'SerialNumber')]
        [int]
        $SerialNumber
        ,
        # Application ID.
        [Parameter(Mandatory = $true)]
        [Alias('AppID')]
        [int]
        $ApplicationID
		,
		# Force action.
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
	if ($PSCmdlet.ShouldProcess("Install Application ID '$($ApplicationID)' on Device ID '$($DeviceID)'.")) {
		$Splattributes = @{
			Method = 'POST'
			ContentType = 'application/json'
			Header = $Headers
            Uri = "$($Config.ApiUrl)/mam/apps/purchased/$($ApplicationID)/uninstall"
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
        # Device UUID.
        [Parameter(Mandatory = $true
                  ,ParameterSetName = 'UUID')]
        [int]
        $DeviceUUID
        ,
        # Device UDID.
        [Parameter(Mandatory = $true
                  ,ParameterSetName = 'UDID')]
        [int]
        $DeviceUDID
        ,
        # Device Serial Number.
        [Parameter(Mandatory = $true
                  ,ParameterSetName = 'SerialNumber')]
        [int]
        $SerialNumber
        ,
        # Application UUID.
        [Parameter(Mandatory = $true)]
        [Alias('AppUUID')]
        [int]
        $ApplicationUUID
		,
		# Force action.
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
	if ($PSCmdlet.ShouldProcess("Install Application UUID '$($ApplicationUUID)' on Device UUID '$($DeviceUUID)'.")) {
		$Splattributes = @{
			Method = 'POST'
			ContentType = 'application/json'
			Header = $Headers
            Uri = "$($Config.ApiUrl)/mam/apps/purchased/$($ApplicationUUID)/uninstall"
			Body = $Data | ConvertTo-Json -Compress
		}
        Write-Verbose -Message ($Splattributes | ConvertTo-Json -Compress)
		Invoke-RestMethod @Splattributes
	}
}
function Update-PurchasedAppV1 {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        # Application ID.
        [Parameter(Mandatory = $true)]
        [Alias('Id'
              ,'AppId')]
        [int]
        $ApplicationId
		,
		# Force action.
		[Parameter()]
		[switch]
		$Force
    )
    if ($Force -and !$Confirm) {
        $ConfirmPreference = 'None'
    }
    # TODO: Update the ShouldProcess text
	if ($PSCmdlet.ShouldProcess("Update Application ID '$($ApplicationID)' on devices.")) {
		$Splattributes = @{
			Method = 'POST'
			ContentType = 'application/json'
			Header = $Headers
            Uri = "$($Config.ApiUrl)/mam/apps/purchased/$($ApplicationID)"
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
        # Device Model.
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
        [bool]
        $Compliant
        ,
        # OrganizationGroup Identifier? LocationGroupID?
        [Parameter()]
        [string]
        $OrganizationGroupUuid # lgid
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
        [Alias('PageStart')]
        [int]
        $Page
        ,
        # Maximumm records per page. Default 500.
        [Parameter()]
        [int]
        $PageSize
        ,
        [Parameter()]
        [ValidateSet('lastseen', 'ownership', 'platform', 'deviceid')]
        [string]
        $OrderBy
        ,
        [Parameter()]
        [Alias('Sort')]
        [ValidateSet('ASC'
                    ,'DESC')]
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
        # Device Model.
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
        # OrganizationGroup Identifier? LocationGroupID?
        [Parameter()]
        [string]
        $OrganizationGroupUuid # lgid
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
        [Alias('StartPage')]
        [int]
        $Page
        ,
        # Maximumm records per page. Default 500.
        [Parameter()]
        [int]
        $PageSize
        ,
        [Parameter()]
        [string]
        $OrderBy
        ,
        [Parameter()]
        [Alias('Sort')]
        [ValidateSet('ASC'
                    ,'DESC')]
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
        # OrganizationGroup Identifier.
        [Parameter()]
        [string]
        $OrganizationGroupUuid
        ,
        # Device Model ID.
        [Parameter()]
        [string]
        $ModelID
        ,
        [Parameter()]
        [ValidateSet('Apple'
                    ,'Android')]
        [string]
        $Platform
        ,
        [Parameter()]
        [Alias('PageStart')]
        [int]
        $Page
        ,
        # Maximumm records per page. Default 500.
        [Parameter()]
        [int]
        $PageSize
        ,
        [Parameter()]
        [string]
        $OrderBy
        ,
        [Parameter()]
        [Alias('Sort')]
        [ValidateSet('ASC'
                    ,'DESC')]
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
        # OrganizationGroup Identifier.
        [Parameter()]
        [string]
        $OrganizationGroupUuid
        ,
        # Device Model, for example - iPhone.
        [Parameter()]
        [ValidateSet('iPhone'
                    ,'iPad')]
        [string[]]
        $Model
        ,
        # Specific page number to get. 0 based index.
        [Parameter()]
        [Alias('PageStart')]
        [int]
        $Page
        ,
        # Maximumm records per page. Default 500.
        [Parameter()]
        [int]
        $PageSize
        ,
        # Orderby column name, for example - applicationname.
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


$ConfigFile = "$($Env:USERPROFILE)\.ws1config_$($Env:USERNAME)@$($Env:COMPUTERNAME).xml"
$Config = if (Test-Path -PathType Leaf -Path $ConfigFile) { Get-Config -Path $ConfigFile } else { Get-Config }

$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Config.ApiCredential.Password)
$ApiKey = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Config.Ws1Credential.Password)
$Ws1Username = $Config.Ws1Credential.UserName
$Ws1Password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
$Secret = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes("$($Ws1Username):$($Ws1Password)"))
Remove-Variable -Force -Name Ws1Password -ErrorAction SilentlyContinue
$Headers = @{
    'Accept'         = 'application/json'
    'Authorization'  = "Basic $($Secret)"
    'aw-tenant-code' = $ApiKey
}


#$Notifications = Get-Notification -PageSize 1000 -Verbose
#Update-PurchasedAppV1 -ApplicationID 858 -Verbose

<# MAM (Mobile Application Management) REST API V1+V2
GET
/mam/apps/purchased/{applicationId/ApplicationUuid}

V2/UUID doesn't work when calling from PowerShell.
Param block for when V2 works:
[CmdletBinding(DefaultParameterSetName = 'ID')]
param(
    # Application ID.
    [Parameter(Mandatory = $true
                ,ParameterSetName = 'ID')]
    [Alias('AppId'
            ,'ApplicationId')]
    [int]
    $Id
    ,
    # Application UUID.
    [Parameter(Mandatory = $true
                ,ParameterSetName = 'UUID')]
    [Alias('ApplicationUuid'
            ,'AppUuid')]
    [string]
    $Uuid
)


Taken from the API helper, where it works.
curl -X GET --header 'Accept: application/json' --header 'Authorization: Basic REDACTED' --header 'aw-tenant-code: REDACTED' 'https://REDACTED/API/mam/apps/purchased/205c6b8c-6a9e-41c5-b492-6f2c0af3fec5'

Converted to PowerShell and tested manually
$Splattributes = @{
    Method = 'GET'
    Headers = @{
        'Accept' = 'application/json'
        'Authorization' = 'Basic REDACTED'
        'aw-tenant-code' = 'REDACTED'
    }
    Uri = 'https://REDACTED/API/mam/apps/purchased/205c6b8c-6a9e-41c5-b492-6f2c0af3fec5'
}
Invoke-WebRequest @Splattributes

Gives the following error:
Server Error in '/Api/Mam' Application.
The resource cannot be found.
Description: HTTP 404. The resource you are looking for (or one of its dependencies) could 
            have been removed, had its name changed, or is temporarily unavailable. 
            Please review the following URL and make sure that it is spelled correctly.
Requested URL: /API/mam/apps/purchased/205c6b8c-6a9e-41c5-b492-6f2c0af3fec5
#>
function Get-PurchasedApp {
    [CmdletBinding()]
    param(
        # Application ID.
        [Parameter(Mandatory = $true)]
        [Alias('AppId'
              ,'ApplicationId')]
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

Get-PurchasedApp -Id 791 -Verbose
break

#$Apps = Find-PurchasedApp -Verbose
foreach ($App in $Apps) {
    if ($App.Id.Value -eq 750) { continue }
    #Get-DeviceWithPurchasedApp -Status Installed -ApplicationId $App.Id.Value -Verbose
    Get-PurchasedApp -Id $App.Id.Value -Verbose
    break
}

#$AppUpdates = $Notifications | Where-Object { $_.Title -eq 'App Updated' }
$Now = Get-Date
foreach ($App in $AppUpdates) {
    $NotificationTime = Get-Date -Date $App.GlobalizedCreatedOn
    if ($NotificationTime.AddDays(2) -lt $Now) { continue }
    $AppData = $App.Data | ConvertFrom-Json
    $Properties = [ordered]@{
        Id   = $AppData.AppIdentifier
        Name = $AppData.AppName
    }
}

#Get-Date $Notifications[0].GlobalizedCreatedOn



#$AppDevices = Get-DeviceWithPurchasedApp -Status Installed -Id 858 -Verbose
#foreach ($d in $AppDevices) {
#    Install-PurchasedAppV1 -DeviceID $d -ApplicationID 858 -Verbose
#}

<#
foreach ($App in $Apps) {
    # Skip the app if it doesn't have an application URL.
    if ($App.ApplicationUrl -notmatch "apps\.apple\.com/(?<Country>[^/]+)/.*/id(?<Id>\d+)(/|$)") { continue }
    # Skip the app if already have categories specified.
    if ($App.psobject.Members.Name -contains 'Categories') { continue }

    # Request app details.
    $Splattributes = @{
        Method = 'GET'
        ContentType = 'application/json'
        Uri = "https://itunes.apple.com/lookup?id=$($Matches.Id)&country=$($Matches.Country)"
    }
    try {
        $Response = Invoke-RestMethod @Splat
        #$WebResponse = Invoke-WebRequest -UseBasicParsing -Uri $Splat.Uri
    }
    catch {
        Write-Warning -Message "Getting details for '$($App.ApplicationName)' ($($App.BundleId)) failed. Skipping."
        continue
    }
    # Create an array with the categories.
    $Categories = @()
    foreach ($g in $Response.results.genres) {
        $Categories += @{ Name = $g }
    }

    # Prepare the JSON payload to update app categories.
    $Body = @{ CategoryList = @{ Category = $Categories } }

    # Update the app details.
    $Splattributes = @{
        Method = 'PUT'
        ContentType = 'application/json'
        Headers = $Headers
        Uri = "$($Config.ApiUrl)/mam/apps/purchased/$($App.Id.Value)"
        Body = $Body | ConvertTo-Json -Compress -Depth 5
    }
    Write-Verbose -Message "Updating '$($App.ApplicationName)' ($($App.Id.Value): $($App.BundleId)) with the categories '$($Categories.Name -join "', '")'." -Verbose
    #Write-Verbose -Message "Calling REST: '$($Splat.Uri)' with body '$($Splat.Body)'." -Verbose
    $Response = Invoke-RestMethod @Splat
}
#>


$Splattributes = @{
    Method = 'GET'
    ContentType = 'application/json'
    Headers = $Headers
    Uri = "$($Config.ApiUrl)/mdm/devices/search?organization_group_uuid=$($OrganizationGroupUuid)"
}

$Splattributes = @{
    Method = 'GET'
    ContentType = 'application/json'
    Headers = $Headers
    Uri = "$($Config.ApiUrl)/system/groups/search?organization_group_uuid=$($OrganizationGroupUuid)"
}

$Splattributes = @{
    Method = 'GET'
    ContentType = 'application/json'
    Headers = $Headers
    Uri = "$($Config.ApiUrl)/system/groups/devicecounts"
}

$Splattributes = @{
    Method = 'GET'
    ContentType = 'application/json'
    Headers = $Headers
    Uri = "$($Config.ApiUrl)/system/groups/$($OrganizationGroupUuid)"
}