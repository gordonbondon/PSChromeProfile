param (
    [string]
    $BuildOutput = [system.io.path]::Combine($PSScriptRoot, 'BuildOut', 'PSChromeProfile'),

    [string]
    $PesterOutput = (Join-Path $PSScriptRoot 'PesterOut'),

    [string]
    $LineSeparation = ('-' * 78),

    [string]
    $ModuleName = 'PSChromeProfile'
)

# Synopsis: Do Cleanup
task Clean {
    if (Test-Path $BuildOutput) {
        $LineSeparation
        "`t`t`t Cleaning output folders"
        $LineSeparation

        Get-ChildItem $BuildOutput | Remove-Item -Force -Recurse -Confirm:$false
        Get-ChildItem $PesterOutput | Remove-Item -Force -Recurse -Confirm:$false
    }

    Get-Item env:\BH* | Remove-Item
}

# Synopsis: Install PSDepend
task InstallPSDepend -if {!(Get-Module -ListAvailable PSDepend)} Clean, {
    Install-Module -Name PSDepend -Force
}

# Synopsis: Install Dependencies
task ResolveDependencies InstallPSDepend, {
    Invoke-PSDepend -Path (Join-Path $PSScriptRoot './requirements.psd1') -Force
    Install-Module TabExpansionPlusPlus -AllowClobber -Force
}

# Synopsis: Initialise env variables
task Init Clean, ResolveDependencies, {
    Set-BuildEnvironment
    $LineSeparation
    "`t`t`t Build environments"
    $LineSeparation
    "Branch:" + $env:BHBranchName
    "Commit:" + $env:BHCommitMessage
}

# Synopsis: Get next version
task Version Init, {
    $currVersion = Get-Metadata -Path $env:BHPSModuleManifest -PropertyName ModuleVersion

    # bump version only in CI
    if ($env:BHBuildSystem -eq 'AppVeyor') {
        $script:nextVersion = Get-NextPSGalleryVersion $env:BHProjectName
        # don't bump version if we did it manually
        if ($script:nextVersion -lt $currVersion) {
            $script:nextVersion = $currVersion
        }
    }
    else {
        $script:nextVersion = $currVersion
    }

    $LineSeparation
    "`t`t`t Module Build Version: $($script:nextVersion)"
    $LineSeparation
}

# Synopsis: Create output folder
task CreateOutFolder Version, {
    if (-not (Test-Path -Path $BuildOutput)) {
        New-Item $BuildOutput -ItemType Directory
    }

    if (-not (Test-Path -Path $PesterOutput)) {
        New-Item $PesterOutput -ItemType Directory
    }
}

# Synopsis: Build module
task BuildPSModule -Partial -Inputs {Get-ChildItem "${env:BHModulePath}" -Recurse} `
                            -Outputs {process{(Get-Item $_).FullName.Replace("${env:BHModulePath}","$BuildOutput")}} `
                            CreateOutFolder, {
    process {
        Copy-Item -Path $_ -Destination $2
    }
    end {
        Update-Metadata -Path ($env:BHPSModuleManifest).Replace("${env:BHModulePath}","$BuildOutput") `
                        -PropertyName ModuleVersion -Value $script:nextVersion
    }
}

# Synopsis: Update help files
task UpdateHelp {
    $script:docsPath = (Join-Path $PSScriptRoot 'Docs')
    Import-Module -Force $env:BHPSModuleManifest
    Update-MarkdownHelp -Path $script:docsPath
}

# Synopsis: Build platyPS help
task BuildHelp -Inputs {Get-Item $script:docsPath\*.md} -Outputs "$BuildOutput\en-US\$Modulename-help.xml" `
               CreateOutFolder, UpdateHelp, {
    New-ExternalHelp -Path "$($script:docsPath)" -OutputPath "$BuildOutput\en-US\" -Force
}

task Build BuildPSModule, BuildHelp

# Synopsis: Run tests
task PesterTest {
    $timeStamp = Get-date -uformat "%Y%m%d-%H%M%S"
    $script:pesterOutFile = (Join-Path $PesterOutput "Unit_$timeStamp.xml")

    $pesterParams = @{
        OutputFormat = 'NUnitXml'
        ErrorAction  = 'Stop'
        OutputFile   = $script:pesterOutFile
        Script       = @{
            Path       = (Join-Path $PSScriptRoot 'Tests')
            Parameters = @{
                ModulePath = $BuildOutput
            }
        }
    }

    $script:testResults = Invoke-Pester @pesterParams -PassThru
}

task FailIfTestFail -if ($script:testResults.FailedCount -ne 0) PesterTest, {
    assert ($script:testResults.FailedCount -eq 0) ('Failed {0} Unit tests. Aborting Build' -f $script:testResults.FailedCount)
}

task UploadTestInAppveyor -if ($env:BHBuildSystem -eq 'AppVeyor') PesterTest, {
    Add-TestResultToAppveyor -TestFile $script:pesterOutFile
}

task Test PesterTest, UploadTestInAppveyor

# Synopsis: Publish to PSGallery
task Deploy -if ($env:BHBranchName -like "master" -and $env:BHCommitMessage -like "*release*"){
    $params = @{
            Path = $BuildOutput
            Repository = 'PSGallery'
            NuGetApiKey = $env:NugetApiKey
        }

    Publish-Module @params
}

task . Build, Test, Deploy