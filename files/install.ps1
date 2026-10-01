# WhatsApp Desktop custom wallpaper - installer
# Copies a small browser extension + your image to %LOCALAPPDATA%\WhatsAppWallpaper and
# tells WhatsApp's embedded browser (WebView2) to load it. Run again to change the image.
param(
    [string]$Image  # optional: image path, skips the file picker
)

$ErrorActionPreference = 'Stop'
$ExtDir    = Join-Path $env:LOCALAPPDATA 'WhatsAppWallpaper'
$RegKey    = 'HKCU:\Software\Policies\Microsoft\Edge\WebView2\AdditionalBrowserArguments'
$ValueName = 'WhatsApp.Root.exe'
$Flag      = "--load-extension=`"$ExtDir`""

function Finish([int]$code) {
    Write-Host ''
    Read-Host 'Press Enter to close' | Out-Null
    exit $code
}

# Writing under HKCU\Software\Policies needs admin, so relaunch this script elevated
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    $argList = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', "`"$PSCommandPath`"")
    if ($Image) { $argList += @('-Image', "`"$Image`"") }
    try {
        Start-Process powershell -Verb RunAs -ArgumentList $argList
    } catch {
        Write-Host 'Administrator permission was declined, nothing changed.' -ForegroundColor Red
        Finish 1
    }
    exit 0
}

Write-Host ''
Write-Host '=== WhatsApp Desktop custom wallpaper ===' -ForegroundColor Cyan

$pkg = Get-AppxPackage 5319275A.WhatsAppDesktop
if (-not $pkg) {
    Write-Host 'WhatsApp Desktop (Microsoft Store version) was not found on this PC.' -ForegroundColor Red
    Write-Host 'Install it from the Microsoft Store first, then run this again.'
    Finish 1
}

# 1. Pick the image
if (-not $Image) {
    Add-Type -AssemblyName System.Windows.Forms
    $dlg = New-Object System.Windows.Forms.OpenFileDialog
    $dlg.Title  = 'Choose your WhatsApp wallpaper'
    $dlg.Filter = 'Images|*.jpg;*.jpeg;*.png;*.webp;*.gif;*.bmp|All files|*.*'
    if ($dlg.ShowDialog() -ne [System.Windows.Forms.DialogResult]::OK) {
        Write-Host 'No image chosen, nothing changed.'
        Finish 1
    }
    $Image = $dlg.FileName
}
if (-not (Test-Path $Image)) {
    Write-Host "Image not found: $Image" -ForegroundColor Red
    Finish 1
}

# 2. Copy the extension and the image
New-Item -ItemType Directory -Force $ExtDir | Out-Null
Copy-Item (Join-Path $PSScriptRoot 'extension\*') $ExtDir -Force
Copy-Item $Image (Join-Path $ExtDir 'wallpaper.jpg') -Force
Write-Host "Copied wallpaper and extension to $ExtDir"

# 3. Register the extension with WhatsApp, keeping any other arguments already set
if (-not (Test-Path $RegKey)) { New-Item $RegKey -Force | Out-Null }
$current = (Get-ItemProperty $RegKey -Name $ValueName -ErrorAction SilentlyContinue).$ValueName
if ($current -and $current.Contains($Flag)) {
    Write-Host 'Extension already registered, just updating the image.'
} else {
    $new = if ($current) { "$current $Flag" } else { $Flag }
    New-ItemProperty $RegKey -Name $ValueName -Value $new -PropertyType String -Force | Out-Null
    Write-Host 'Extension registered.'
}

# 4. Restart WhatsApp so it picks up the change
$running = Get-Process WhatsApp.Root -ErrorAction SilentlyContinue
if ($running) {
    Write-Host 'Restarting WhatsApp...'
    $running | Stop-Process -Force
    Start-Sleep -Seconds 2
}
Start-Process "shell:AppsFolder\$($pkg.PackageFamilyName)!App"

Write-Host ''
Write-Host 'Done! Open any chat to see your wallpaper.' -ForegroundColor Green
Write-Host 'To change the image later, run Install again. To remove it, run Uninstall.'
Finish 0
