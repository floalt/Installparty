<#

    Konfigurations-Script für eine neu Windows-Installation
    Aufruf durch start-party4pc.cmd

    author: flo.alt@fa-netz.de
    https://github.com/floalt/installparty/blob/master/executionpolicy.cmd
    version: 0.71

#>



# ---------------- Hier werden alle Funktionen definiert ---------------------


# Funktion: Fehlercheck

    function errorcheck {
        if ($?) {
            write-host $yeah -F Green
        } else {
            write-host $shit -F Red
            $global:errorcount = $global:errorcount + 1
        }
    }


# Funktion: Script-Verzeichnis auslesen

    function Get-ScriptDirectory {
        Split-Path -parent $PSCommandPath
    }

# Funktion: Drücke ein Taste zum Schließen

    function shutup {

        Read-Host "
        ENDE: Drücke die Entertaste, um das Fenster zu schließen."
        exit
    }

# Funktion: Ja / Nein Frage

    function ask-yesno ([string]$question) {
        $letsdoit = Read-Host $question [J/n]
        if (($letsdoit -eq "j") -or (!$letsdoit)) {
            $script:doit = 1
            $script:question = $null
        } elseif ($letsdoit -eq "n") {
            $script:doit = 0
            $script:question = $null
        } else {
            Write-Host "Bitte 'j' oder 'n' eingeben (Enter für Ja)" -F Red
            ask-yesno
        }
    }


# Funktion: Drucker löschen

    function delete-unwantedprinter {
        $queryprinter = Get-WMIObject -Class Win32_Printer | where {$_.name -eq $printer}
            if ($queryprinter) {
               Remove-Printer -Name $printer
               write-host "Lösche Drucker $printer"

               $querydelete = Get-WMIObject -Class Win32_Printer | where {$_.name -eq $printer}
               if ($querydelete) {
                    write-host "FEHLER: Der Drucker $printer konnte nicht gelöscht werden" -F Red
                    $script:errorcount = $script:errorcount + 1
               } else {
                    write-host "OK: Der Drucker $printer wurde gelöscht" -F Green
               }

            } else {
                write-host "INFO: Der Drucker $printer ist nicht vorhanden" -F Yellow
        }
    }


# Funktion: legt einen Registry Key fest

    function set-registrykey {
        if (!(Test-Path $key)) {
            $yeah = "OK: Registry Key $key erfolgreich angelegt"
            $shit = "FEHLER: Registry Key $key konnte nicht angelegt werden"
            New-Item $key -Force | Out-Null
            errorcheck}
        }


# Funktion: legt einen Registry Wert fest

    function set-registryvalue {
        set-registrykey
        $yeah = "OK: $title wurde erfolgreich deaktiviert"
        $shit = "Fehler: $title konnte nicht deaktiviert werden"
        Set-ItemProperty -Type $type -Path $key -Name $name -Value $value
        errorcheck
    }


# Funktion: Dienst deaktivieren

    function deactivate-service {
        # Dienst beenden
            $yeah = "OK: Dienst $title wurde erfolgreich beendet"
            $shit = "FEHLER: Dienst $title konnte nicht beednet werden"
            Stop-Service -Name $servicename
            errorcheck
        # Dienst deaktivieren
            $yeah = "OK: Dienst $title wurde erfolgreich dauerhaft deaktiviert"
            $shit = "FEHLER: Dienst $title konnte nicht deaktiviert werden"
            Set-Service -Name $servicename -StartupType Disabled
            errorcheck
    }


# Funktion: Was soll das werden?

    function read-kindof {
        $global:kindof = Read-Host "Bitte wähle"
        switch -Wildcard($global:kindof) {
            1 {Write-Host "OK: Ascair" -F Green
               $global:kindof = "ascair"; break}
            2 {Write-Host "OK: Biomichl" -F Green
               $global:kindof = "biomichl"; break}
            3 {Write-Host "OK: Isarland" -F Green
               $global:kindof = "isarland"; break}
            4 {Write-Host "OK: Raab" -F Green
               $global:kindof = "raab"; break}
            9 {Write-Host "OK: Privat-PC" -F Green
               $global:kindof = "privat"; break}
            q {Write-Host "Alles klar! Bis zum nächsten Mal..." -F Yellow
               shutup; break}
            * {Write-Host "Bitte tippe ein: 1, 2, 3, 4 oder Q" -F Red
              read-kindof; break}
        }
    }



# ------------------- ENDE Definition der Funktionen --------------------

# ------------------- Hier beginnt der Befehlsablauf --------------------

$global:scriptpath = Get-ScriptDirectory
$global:errorcount = 0
$global:steps = 0

# Begrüßung

    Write-Host "
        ;-) Install-Party ;-) `n
        Konfiguration für neue PCs
        " -F Yellow

    Write-Host "
        >>>>> Party on, Wayne
                >>>>> Party on, Garth `n
        " -F Green

    Start-Sleep 1


# Frage nach der Art der Installation

    Write-Host "
        Was soll denn das hier bitte werden?

            1     Ascair
            2     Biomichl
            3     Isarland
            4     Raab

            9     Privat-PC

            Q     ähh, ich bin hier falsch...
    "

    read-kindof


# Frage, ob Software installiert werden soll

$question = "Soll ich Software installieren? (Standard-Apps und individuelle Apps für die jeweiligen Unternehmen)"
ask-yesno $question
$install_apps = $doit




# SCHRITT 1: Installationen durchführen

    if ($install_apps -eq 1) {
        & $Global:scriptpath/install-apps.ps1
    }


# SCHRITT 2 & 3: Konfigurationen durchführen

    # 1) Konfigurationen für alle PCs
    & $Global:scriptpath/pc-allkind.ps1

    # 2) Konfigurationen für alle PCs
    & $Global:scriptpath/pc-allbusiness.ps1

    # 3) Konfiguration individuell nach Firma / Privat
    switch -Wildcard($global:kindof) {
        ascair {& $Global:scriptpath/pc-ascair.ps1; break}
        biomichl {& $Global:scriptpath/pc-biomichl.ps1; break}
        isarland {& $Global:scriptpath/pc-isarland.ps1; break}
        raab {& $Global:scriptpath/pc-raab.ps1; break}
        privat {& $Global:scriptpath/pc-private.ps1; break}
    }


# SCHRITT 4: Konfiguration Benutzer & Kennwörter

    & $Global:scriptpath/adduser.ps1


# Script-Ende

    if ($global:errorcount -lt 1) {
        write-host "
            Alles erfolgreich abgeschlossen.
              Schön, wenn auch mal was funktioniert!
            " -F Green
    } else {
        write-host "
            Es sind $global:errorcount Fehler aufgetreten...
            ...but it's better to burn out then to fade away
            " -F Red
    }

$global:steps
