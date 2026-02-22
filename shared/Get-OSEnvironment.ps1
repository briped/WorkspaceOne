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
    <#
    .SYNOPSIS
    Gets environment variables based on OS.

    .DESCRIPTION
    Returns a standardized set of variables regardless of the underlying OS.

    .NOTES
    .LINK
    .EXAMPLE
    #>
}