<#

    Konfigurations-Script zum Aufruf von Firefox-Addon-Installationen
    wird bei PCs angewandt, die nicht in einer Domäne verwaltet werden
    Aufruf durch start-party4me.cmd

    author: flo.alt@fa-netz.de
    https://github.com/floalt/installparty/blob/master/executionpolicy.cmd
    version: 0.7


#>


$mysoftware = "Firefox"

# Prüfe auf 32-Bit oder 64-Bit:

    $check32 = Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object {$_.DisplayName -like "*$mysoftware*"}
    if (!$check32) {
        Write-Host "INFO: Keine 32-Bit Software für $mysoftware gefunden" -F Yellow
        $check64 = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object {$_.DisplayName -like "*$mysoftware*"}
        if (!$check64) {
            Write-Host "FEHLER: $mysoftware ist nicht installiert" -F Red
        } else {
            Write-Host "OK: $mysoftware 64-Bit gefunden." -F Green
            $details = $check64
        }

    } else {
        Write-Info "OK: $mysoftware 64-Bit gefunden." -F Green
        $details = $check32
    }

# Ermittle Installationspfad

$mypath = $details.InstallLocation

# Starte Firefox mit Link:

& $mypath\firefox.exe https://addons.mozilla.org/de/firefox/addon/ublock-origin/
