<#

    Konfigurations-Script zur Aktivierung der Windows Lizenz
    wird bei PCs angewandt, die nicht in einer Domäne verwaltet werden
    Aufruf durch start-party4pc.cmd

    FUNKTIONIERT NICHT!
        
        obwohl die Syntax slmgr /ipk (Z. 56) korrekt ist,
        wird der Key als nicht gültig bezeichnet

    author: flo.alt@fa-netz.de
    version: 0.5


#>

# ---------------- Start: Funktionen definieren ---------------------

# Funktion: Nach Aktivierung fragen

function ask-activation {
    $askact = Read-Host "Soll die Aktivierung jetzt gestartet werden [J/n] ?"
        if (($askact -eq "j") -or (!$askact)) {
            $script:doact = 1
            Write-Host "Starte die Aktivierung..."
        } elseif ($letsdoit -eq "n") {
            $script:doact = 0
            Write-Host "OK: Windows soll jetzt nicht aktiviert werden" -F Green
        } else {
        Write-Host "Bitte 'j' oder 'n' eingeben (Enter für Ja)" -F Red
        }
}

function ask-key {
    $script:winkey = Read-Host "Windows-Key"
    if (!$winkey) {
        Write-Host "Bitte gib den Windos-Key ein!" -ForegroundColor Red
        ask-key
    }
}

# ---------------- Ende: Funktionen definieren ---------------------


# Aktivierung prüfen

WMIC /NAMESPACE:\\root\CIMV2 PATH SoftwareLicensingProduct WHERE LicenseStatus=1 GET LicenseStatus | findstr "1"

if ($?) {
    Write-Host "OK: Windows ist bereits aktiviert" -F Green
} else {
    Write-Host "INFO: Windows ist noch nicht aktiviert." -F Yellow
    ask-activation
    if ($doact -eq 1) {
        ask-key
        slmgr /ipk $winkey
        pause
        slmgr /ato
    }
}