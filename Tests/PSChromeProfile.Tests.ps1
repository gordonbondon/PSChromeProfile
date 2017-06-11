param (
    [string]
    $ModulePath = [system.io.path]::Combine((Split-Path $PSScriptRoot),'PSChromeProfile')
)

$moduleName     = 'PSChromeProfile'
$moduleManifest = [system.io.path]::Combine($ModulePath, "$moduleName.psd1")

Describe 'PSChromeProfile Module' {
    It 'Imports without errors' {
        { Import-Module -Name $moduleManifest -Force -ErrorAction Stop } | Should Not Throw
    }

    It 'Removes without error' {
        { Remove-Module -Name $ModuleName -ErrorAction Stop} | Should not Throw
    }
}