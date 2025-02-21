$Config = @{
    Manifest = [System.IO.FileInfo](Join-Path -Path (Join-Path -Path $PSScriptRoot -ChildPath 'pwshModule') -ChildPath 'WorkspaceOneShell.psd1')
    API = @(
        @{
            LocationGroupId = 666
            Attributes = @{
                Uri = 'https://WS1-HOST/API'
                Key = ('APIKEYFORORGANIZATION' | ConvertTo-SecureString -Force -AsPlainText)
                Method = 'Certificate'
                Certificate = (Get-Item -Path 'Cert:\LocalMachine\My\CERTIFICATETHUMBPRINT')
            }
        }
        @{
            LocationGroupId = 777
            Attributes = @{
                Uri = 'https://WS1-HOST/API'
                Key = ('APIKEYFORORGANIZATION' | ConvertTo-SecureString -Force -AsPlainText)
                Method = 'Basic'
                Credential = ([pscredential]::new('api-username', (ConvertTo-SecureString -Force -AsPlainText -String 'password4api-username')))
            }
        }
    )
}