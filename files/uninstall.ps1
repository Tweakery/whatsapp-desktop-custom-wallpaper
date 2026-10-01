# WhatsApp Desktop custom wallpaper - uninstaller
# Removes the --load-extension flag (keeping any other arguments) and deletes the extension folder.

$ErrorActionPreference = 'Stop'
$ExtDir    = Join-Path $env:LOCALAPPDATA 'WhatsAppWallpaper'
$RegKey    = 'HKCU:\Software\Policies\Microsoft\Edge\WebView2\AdditionalBrowserArguments'
$ValueName = 'WhatsApp.Root.exe'
$Flag      = "--load-extension=`"$ExtDir`""

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host 'Asking for administrator permission to remove the registry setting...'
    try {
        Start-Process powershell -Verb RunAs -Wait -ArgumentList @(
            '-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', "`"$PSCommandPath`"")
    } catch {
        Write-Host 'Administrator permission was declined, nothing changed.' -ForegroundColor Red
    }
    exit
}

Write-Host ''
Write-Host '=== Removing WhatsApp custom wallpaper ===' -ForegroundColor Cyan

$current = (Get-ItemProperty $RegKey -Name $ValueName -ErrorAction SilentlyContinue).$ValueName
if ($current) {
    $rest = $current.Replace($Flag, '').Trim()
    if ($rest) {
        New-ItemProperty $RegKey -Name $ValueName -Value $rest -PropertyType String -Force | Out-Null
    } else {
        Remove-ItemProperty $RegKey -Name $ValueName
    }
    Write-Host 'Registry setting removed.'
}

if (Test-Path $ExtDir) {
    Remove-Item $ExtDir -Recurse -Force
    Write-Host "Deleted $ExtDir"
}

$running = Get-Process WhatsApp.Root -ErrorAction SilentlyContinue
if ($running) {
    $running | Stop-Process -Force
    Start-Sleep -Seconds 2
    $pkg = Get-AppxPackage 5319275A.WhatsAppDesktop
    if ($pkg) { Start-Process "shell:AppsFolder\$($pkg.PackageFamilyName)!App" }
}

Write-Host ''
Write-Host 'Done. WhatsApp is back to normal.' -ForegroundColor Green
Read-Host 'Press Enter to close'
