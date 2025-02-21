# ThisScript will always reference the script that calls the variable, regardles if the script is dot-sourced.
$ThisScript = $null
if ($MyInvocation.ScriptName -and (Test-Path -PathType Leaf -Path $MyInvocation.ScriptName)) {
    $ThisScript = [System.IO.FileInfo]$MyInvocation.ScriptName
}
elseif ($MyInvocation.InvocationName -and (Test-Path -PathType Leaf -Path $MyInvocation.InvocationName)) {
    $ThisScript = [System.IO.FileInfo]$MyInvocation.InvocationName
}
function WriteLog {
    param(
        [Parameter(Mandatory = $true)]
        [string]
        $Message
        ,
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.IO.FileInfo]
        $FilePath
    )
    if (!$FilePath) {
        $DateNow = Get-Date
        $LogPath = Join-Path -Path $ThisScript.DirectoryName -ChildPath 'logs'
        $FilePath = Join-Path -Path $LogPath -ChildPath "$($DateNow.ToString('yyyyMMdd'))-$($ThisScript.BaseName).log"
    }
    if (!$FilePath.Directory.Exists) {
        $FilePath = New-Item -Force -ItemType Directory -Path $FilePath.DirectoryName
    }
    $LogMessage = @(
        $(Get-Date -Format o)
        , $($env:USERNAME)
        , $ThisScript.Name
        , $Message
    )
    $LogMessage -join "`t" | Out-File -FilePath $FilePath -Append
}

$SharedPath = Join-Path -Path $PSScriptRoot -ChildPath 'shared'
if (Test-Path -PathType Container -Path $SharedPath) {
    Get-ChildItem -File -Path $SharedPath -Filter '*.ps1' | 
    Where-Object { $_.BaseName -notmatch '(^\.|\.dev$|\.test$)' } | 
    Sort-Object -Property BaseName | 
    ForEach-Object {
        . $_.FullName
    }
}
