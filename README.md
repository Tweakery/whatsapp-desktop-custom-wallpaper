# Custom wallpaper for WhatsApp Desktop

Use **any image** as the chat background in WhatsApp Desktop for Windows. The official app only lets you choose from its built-in colors and patterns.

> Not affiliated with, endorsed by, or connected to WhatsApp or Meta in any way.

WhatsApp itself is **not modified**. Modern WhatsApp Desktop is WhatsApp Web running inside Microsoft's embedded Edge browser (WebView2). This mod is a tiny browser extension (one CSS file) that the embedded browser is told to load.

## Requirements

- Windows 10 or 11
- WhatsApp Desktop from the Microsoft Store
- A Windows account with administrator rights (asked for once, during install)

## Easy install

1. Download `WhatsAppWallpaper-mod.zip` from the [latest release](../../releases/latest) and unzip it anywhere.
2. **Right-click `Install.cmd` → Run as administrator** and click **Yes**.
3. Pick your image in the window that opens.
4. WhatsApp restarts. Open any chat and enjoy your wallpaper.

**Change the image:** run `Install.cmd` again the same way and pick a new one.
**Remove it:** right-click **`Uninstall.cmd`** → Run as administrator.

> **"Smart App Control blocked..."**: Windows 11's Smart App Control blocks unsigned scripts when you double-click them. Use right-click → **Run as administrator** as shown above. If it's still blocked, use the [manual install](#manual-install) below; it's just copying files and pasting one command.
>
> **"Windows protected your PC"**: click **More info → Run anyway**. Windows shows this for any script downloaded from the internet.
>
> Everything the scripts run is in this repo, so you can read it first.

## Manual install

If you'd rather not run a script:

1. Create the folder `%LOCALAPPDATA%\WhatsAppWallpaper` (paste that into the File Explorer address bar).
2. Copy `manifest.json` and `wallpaper.css` from [`files/extension`](files/extension) into it.
3. Copy your image into it and rename it to `wallpaper.jpg` (PNG and other formats work too, just keep that name).
4. Open PowerShell **as administrator** and run:
   ```powershell
   $k='HKCU:\Software\Policies\Microsoft\Edge\WebView2\AdditionalBrowserArguments'; New-Item $k -Force | Out-Null; New-ItemProperty $k -Name 'WhatsApp.Root.exe' -Value "--load-extension=`"$env:LOCALAPPDATA\WhatsAppWallpaper`"" -PropertyType String -Force
   ```
5. Fully quit WhatsApp (check the system tray) and open it again.

**Manual removal** (admin PowerShell), then delete the `%LOCALAPPDATA%\WhatsAppWallpaper` folder:
```powershell
Remove-ItemProperty 'HKCU:\Software\Policies\Microsoft\Edge\WebView2\AdditionalBrowserArguments' -Name 'WhatsApp.Root.exe'
```

## How it works

- WebView2 reads a per-app registry policy, `AdditionalBrowserArguments`, and adds those flags when it launches. The installer adds `--load-extension` for `WhatsApp.Root.exe` only, so no other app is affected.
- **Why admin?** Windows only lets administrators write under `HKCU\Software\Policies`. That registry write is the only thing that needs it.
- The extension ([`wallpaper.css`](files/extension/wallpaper.css)) places your image behind the open chat and hides WhatsApp's default pattern. It only runs on `web.whatsapp.com`, asks for no permissions, and contains no JavaScript.
- No debugging ports, no patched files, nothing sent anywhere.

## Troubleshooting

- **Background didn't change:** a WhatsApp update may have renamed the part of the page the mod targets. The selectors are in [`wallpaper.css`](files/extension/wallpaper.css). Issues and pull requests are welcome.
- **Setting didn't apply:** if you're on a standard account and typed in a *different* admin account's password, the setting was saved for that account instead. Run the installer from an admin account.
- **It stopped working entirely:** Meta could turn off extension support in WhatsApp's embedded browser in a future update.

## License

[MIT](LICENSE)

---

<sub>Freshly baked by [Tweakery](https://github.com/Tweakery) 🥐</sub>
