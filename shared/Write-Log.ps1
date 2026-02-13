function Write-Log {
    param(
        [Parameter(Mandatory = $true
                ,  ValueFromPipeline = $true
                ,  ValueFromPipelineByPropertyName = $true
                ,  ValueFromRemainingArguments = $false
                ,  Position = 0)]
        [string]
        $Message
        ,
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.IO.FileInfo]
        $FilePath
        ,
        [Parameter()]
        [switch]
        $PassThru
    )
    begin {
        $UtcNow = [datetime]::UtcNow
        if (!$FilePath) {
            $LogPath = [System.IO.DirectoryInfo](Join-Path -Path $ThisScript.DirectoryName -ChildPath 'logs')
            $FileName = "$($UtcNow.ToString('yyyyMMdd'))-$($ThisScript.BaseName).log"
            $FilePath = [System.IO.FileInfo](Join-Path -Path $LogPath -ChildPath $FileName)
        }
        if (!$FilePath.Directory.Exists) {
            New-Item -Force -ItemType Directory -Path $FilePath.DirectoryName | Out-Null
        }
    }
    process {
        $LogMessage = @(
            $UtcNow.ToString('o')
            , $($env:USERNAME)
            , $ThisScript.Name
            , $Message
        )
        $LogMessage -join "`t" | Out-File -FilePath $FilePath -Append
        if ($PassThru) { $Message }
    }
    end {}
    <#
    .SYNOPSIS
    Delete a tag.

    .DESCRIPTION
    Delete a tag based on tag identifier.

    .PARAMETER Message
    The message to write to the logfile.

    .PARAMETER FilePath
    The path and filename to the logfile. Will auto create path and name if not set.

    .PARAMETER PassThru
    Also output the message to standard out. Usefull if wanting to pass to Write-Host, Write-Verbose etc.

    .INPUTS
    [String] message

    .EXAMPLE
    Write-Log -PassThru -Message "Something odd happened!" | Write-Warning

    .EXAMPLE
    Write-Log -PassThru -FilePath 'C:\Logs\debug.log' -Message "Something odd happened!" | Write-Verbose

    .NOTES
        .TODO
        .CHANGES
    #>
}
