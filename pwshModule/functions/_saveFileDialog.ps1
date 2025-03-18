function _saveFileDialog {
    [CmdletBinding()]
    param(
        [Parameter()]
        [Alias('PSPath')]
        [ValidateNotNullOrEmpty()]
        [System.IO.FileInfo]
        $Path
    )
    if ($IsLinux) {
        $EnvUser = [System.Environment]::GetEnvironmentVariable('USER')
        $EnvHost = [System.Environment]::GetEnvironmentVariable('NAME')
        $EnvHome = [System.Environment]::GetEnvironmentVariable('HOME')
        if (!$Path) {
            $Path = Join-Path -Path $EnvHome -ChildPath ".$($MyInvocation.MyCommand.Module.Name)_$($EnvUser)@$($EnvHost).config.xml"
        }
        if (!$Path.Directory.Exists) {
            # Find the first directory to be created.
            # To be used if SaveDialog is cancelled to clean up.
            $FirstNewDirectory = $Path.Directory
            while (!$FirstNewDirectory.Parent.Exists) {
                $FirstNewDirectory = $FirstNewDirectory.Parent
            }
            # Create the config-file.
            New-Item -Force -ItemType File -Path $Path
        }
        $IsDesktop = [System.Environment]::GetEnvironmentVariable('DISPLAY') -as [bool]
        if ($IsDesktop) {
            #TODO: Test for zenity and kdialog.
            Set-Location -Path $EnvHome
            $Path = & zenity --file-selection --save --file-filter='Common Language Infrastructure eXensible Markup Language (*.xml)|*.xml' --file-filter='All files|*.*' 2> /dev/null
            #$Path = & kdialog --getexistingdirectory
            if ($true -eq $?) {
                # Cancelled. Do clean-up.
                Remove-Item -Force -Path $FirstNewDirectory
            }
        }
    }
    elseif ($IsMacOS) {
        $EnvUser = [System.Environment]::GetEnvironmentVariable('USER')
        $EnvHost = Invoke-Expression -Command 'scutil --get LocalHostName'
        $EnvHome = [System.Environment]::GetEnvironmentVariable('HOME')
        #Invoke-Expression -Command 'osascript -e 'set selectedFolder to choose folder with prompt "Select a Folder"''
    }
    elseif ($IsWindows) {
        $EnvUser = [System.Environment]::GetEnvironmentVariable('USERNAME')
        $EnvHost = [System.Environment]::GetEnvironmentVariable('COMPUTERNAME')
        $EnvHome = [System.Environment]::GetEnvironmentVariable('USERPROFILE')
        $IsDesktop = (Get-Process | Where-Object { $_.MainWindowTitle -ne '' }).Count -gt 0
        if ($IsDesktop) {
            Add-Type -AssemblyName System.Windows.Forms
            $FileBrowser = New-Object -TypeName System.Windows.Forms.SaveFileDialog
            $FileBrowser.InitialDirectory = $EnvHome
            $FileBrowser.FileName = ".$($MyInvocation.MyCommand.Module.Name)_$($EnvUser)@$($EnvHost).config.xml"
            $FileBrowser.Filter = 'Common Language Infrastructure eXensible Markup Language (*.xml)|*.xml|All files (*)|*'
            $DialogResult = $FileBrowser.ShowDialog()
            if ($DialogResult -ne 'OK') { return }
            [System.IO.FileInfo]$FileBrowser.FileName
        }
    }
    else {
        throw "Unkown Operating System"
    }
}