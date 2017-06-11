# .EXTERNALHELP PSChromeProfile-help.xml
function Open-ChromeProfile {
    [CmdletBinding(DefaultParameterSetName='Name')]
    param(
        [Parameter(ParameterSetName='Name', Position=0)]
        [ValidateScript({
            if (Get-ChromeProfile -ProfileName $_) {
                $true
            }
            else {
                throw "Profile with name $($_) does not exist"
            }
        })]
        [string]
        $ProfileName,

        [Parameter(ParameterSetName='Id')]
        [ValidateScript({
            if (Get-ChromeProfile -ProfileId $_) {
                $true
            }
            else {
                throw "Profile with Id $($_) does not exist"
            }
        })]
        [string]
        $ProfileId,

        [Parameter(Position=2)]
        [Alias('URL')]
        [string]
        $Link
    )

    $chrome = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\chrome.exe').'(default)'

    [System.Collections.ArrayList]$arguments = @()

    if ($PSBoundParameters['Link']) {
        $arguments.Add('"{0}"' -f $Link)
        $null = $PSBoundParameters.Remove('Link')
    }

    # Select only first profile because Chrome allows creating profiles with similar names
    $profile = Get-ChromeProfile @PSBoundParameters | Select-Object -First 1

    $arguments.Add('--profile-directory="{0}"' -f $profile.Id)

    Start-Process -FilePath $chrome -ArgumentList $arguments
}

# .EXTERNALHELP PSChromeProfile-help.xml
function Get-ChromeProfile {
    [CmdletBinding(DefaultParameterSetName='Name')]
    param(
        [Parameter(ParameterSetName='Name', Mandatory=$false, Position=0)]
        [string]
        $ProfileName,

        [Parameter(ParameterSetName='Id', Mandatory=$false, Position=0)]
        [string]
        $ProfileId
    )

    # Get profile list from Chromes local state
    $statePath = "C:\Users\${env:USERNAME}\AppData\Local\Google\Chrome\User Data\Local State"
    $state = Get-Content $statePath

    # Using Serializer instead of ConvertFrom-Json because https://github.com/PowerShell/PowerShell/issues/1755
    [void][System.Reflection.Assembly]::LoadWithPartialName('System.Web.Extensions')
    $jsser = New-Object System.Web.Script.Serialization.JavaScriptSerializer
    $jsser.MaxJsonLength = $jsser.MaxJsonLength * 10

    $serProfiles = $jsser.DeserializeObject($state).profile.info_cache

    $profiles = @()
    $serProfiles.Keys.ForEach{
        $profile = New-Object -TypeName psobject -Property @{
            'Id' = $_
            'Name' = $serProfiles[$_]['shortcut_name']
        }
        $profiles += $profile
    }

    if($PSBoundParameters['ProfileId']) {
        $profiles.Where{$_.Id -like "$ProfileId"}
    }
    elseif ($PSBoundParameters['ProfileName']) {
        $profiles.Where{$_.Name -like "$ProfileName"}
    }
    else {
        $profiles
    }
}

Export-ModuleMember -Function *-*

# Autocompletion
function ChromeProfileNameCompleter {
    param (
        $commandName,
        $parameterName,
        $wordToComplete,
        $commandAst,
        $fakeBoundParameter
    )

    Get-ChromeProfile -ProfileName "$wordToComplete*" |
        ForEach-Object {
            New-CompletionResult -CompletionText $_.Name
        }
}

TabExpansionPlusPlus\Register-ArgumentCompleter -CommandName ( 'Open-ChromeProfile' ) `
                           -ParameterName ProfileName `
                           -ScriptBlock $function:ChromeProfileNameCompleter `
                           -Description 'Completes Chrome Profile Name'

function ChromeProfileIdCompleter {
    param (
        $commandName,
        $parameterName,
        $wordToComplete,
        $commandAst,
        $fakeBoundParameter
    )

    Get-ChromeProfile -ProfileId "$wordToComplete*" |
        ForEach-Object {
            New-CompletionResult -CompletionText $_.Id -ListItemText $_.Name
       }
}

TabExpansionPlusPlus\Register-ArgumentCompleter -CommandName ( 'Open-ChromeProfile' ) `
                           -ParameterName ProfileId `
                           -ScriptBlock $function:ChromeProfileIdCompleter `
                           -Description 'Completes Chrome Profile Id'
