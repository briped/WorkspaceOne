function _openFileDialog {
    if ($IsLinux) {
        $EnvUser = [System.Environment]::GetEnvironmentVariable('USER')
        $EnvHost = [System.Environment]::GetEnvironmentVariable('NAME')
        $EnvHome = [System.Environment]::GetEnvironmentVariable('HOME')
        #TODO: Implement OpenFileDialog equivalent for Linux desktops
    }
    elseif ($IsMacOS) {
        $EnvUser = [System.Environment]::GetEnvironmentVariable('USER')
        $EnvHost = Invoke-Expression -Command 'scutil --get LocalHostName'
        $EnvHome = [System.Environment]::GetEnvironmentVariable('HOME')
        #TODO: Implement OpenFileDialog equivalent for MacOS desktops
    }
    elseif ($IsWindows) {
    $EnvUser = [System.Environment]::GetEnvironmentVariable('USERNAME')
    $EnvHost = [System.Environment]::GetEnvironmentVariable('COMPUTERNAME')
    $EnvHome = [System.Environment]::GetEnvironmentVariable('USERPROFILE')
    $IsDesktop = (Get-Process | Where-Object { $_.MainWindowTitle -ne '' }).Count -gt 0
        if ($IsDesktop) {
            Add-Type -AssemblyName System.Windows.Forms
            $FileBrowser = New-Object -TypeName System.Windows.Forms.OpenFileDialog
            $FileBrowser.InitialDirectory = $EnvHome
            $FileBrowser.FileName = ".$($MyInvocation.MyCommand.Module.Name)_$($EnvUser)@$($EnvHost).config.xml"
            $FileBrowser.Filter = 'Common Language Infrastructure eXensible Markup Language (*.xml)|*.xml|All files (*.*)|*.*'
            $DialogResult = $FileBrowser.ShowDialog()
            if ($DialogResult -ne 'OK') { return }
            [System.IO.FileInfo]$FileBrowser.FileName
        }
        else {
            Read-Host -Prompt 'Path'
        }
    }
    else {
        throw "Unkown Operating System"
    }
}