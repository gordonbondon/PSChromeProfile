if (!(Get-PackageProvider -Name NuGet -ForceBootstrap)) {
    $null = Install-PackageProvider nuget -force -ForceBootstrap
    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
}

if(!(Get-Module -listAvailable InvokeBuild )) {
    Install-Module InvokeBuild -ErrorAction Stop -scope CurrentUser -force
}