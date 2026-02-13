<#PSScriptInfo
.VERSION
2025.3.18.0

.GUID
dade5267-f5d4-4ac1-9480-533e44718f47

.AUTHOR
Brian Schmidt Pedersen

.COMPANYNAME
N/A

.COPYRIGHT
(c) Brian Schmidt Pedersen. All rights reserved.

.LICENSEURI
https://raw.githubusercontent.com/briped/WorkSpaceOne/main/LICENSE

.PROJECTURI
https://github.com/briped/WorkspaceOne

.RELEASENOTES
2025.3.18.0
+ Initial version
#>
<#
.SYNOPSIS
Generate device/app reports for user(s)

.DESCRIPTION
Takes one or more usernames and finds all devices and installed apps for those users.

.NOTES
TODO
.EXAMPLE
TODO
#>

# Get all device and app data for the specified users.
$ReturnedData = $Users | Get-Ws1UserDevicesInstalledApps

# Simple report with just the installed apps and the installation count.
$CsvFile = 'UserCountApps.csv'
$ReturnedData.InstalledApps | 
    Select-Object -Property name,bundle_id,installed_version,assignment_status | 
    Group-Object -Property bundle_id | 
    Sort-Object -Property Count -Descending | 
    Select-Object -Property Count,
                            @{Name='Name'; Expression={$_.Group[0].name}},
                            @{Name='Bundle ID'; Expression={$_.Group[0].bundle_id}} | 
    Export-Csv -Path $CsvFile

# Another simple report with the installed apps and versions and the installation count for each app/version.
$CsvFile = 'UserCountAppsVersions.csv'
$ReturnedData.InstalledApps | 
Select-Object -Property name,bundle_id,installed_version,assignment_status | 
Group-Object -Property bundle_id,installed_version | 
Sort-Object -Property Count -Descending | 
Select-Object -Property Count,
                        @{Name='Name'; Expression={$_.Group[0].name}},
                        @{Name='Bundle ID'; Expression={$_.Group[0].bundle_id}},
                        @{Name='Version'; Expression={$_.Group[0].installed_version}} | 
Export-Csv -Path $CsvFile

# Flatten the returned data for a complete report.
$SetHeaders = $true
$CsvFile = 'UserDevicesAppsAllData.csv'
foreach ($Device in $ReturnedData) {
    foreach ($App in $Device.InstalledApps) {
        $DataRow = [ordered]@{}
        $DataRow = $Device | Select-Object -ExcludeProperty InstalledApps
        $App.psobject.Properties | 
            Where-Object { $_.TypeNameOfValue -notmatch 'Object' } | 
            ForEach-Object {
                $DataRow | Add-Member -MemberType NoteProperty -Name $_.Name -Value $_.Value
            }
        if ($SetHeaders) {
            $DataRow | ConvertTo-Csv | Select-Object -First 1 | Out-File -Force -FilePath $CsvFile
            $SetHeaders = $false
        }
        $DataRow | ConvertTo-Csv -NoHeader | Out-File -Append -FilePath $CsvFile
    }
}
