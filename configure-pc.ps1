<#

    Konfigurations-Script für eine neu Windows-Installation
    wird bei PCs angewandt, die nicht in einer Domäne verwaltet werden

    author: flo.alt@fa-netz.de
    version: 0.6


    Vorlage für neuen Registry-Block:

    $title = ""
    $action = ""
    $key = "HKCU:\"
    $name = ""
    $type = "DWORD"
    $value = 0
    set-registry

#>



# ---------------- Hier werden alle Funktionen definiert ---------------------

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


# Funktion: legt einen Registry Wert für AppPrivacy fest

    function set-registryappp {
        if (!(Test-Path $key)) {New-Item $key -Force | Out-Null}
        $yeah = "OK: App Datenschutz: $name erfolgreich deaktiviert"
        $shit = "FEHLER:  App Datenschutz: $name konnte nicht deaktiviert werden"
        Set-ItemProperty -Type $type -Path $key -Name $name -Value $value
        errorcheck
    }



# Funktion: Script-Verzeichnis auslesen

    function Get-ScriptDirectory {
        Split-Path -parent $PSCommandPath
    }


# Funktion: Fehlercheck

    function errorcheck {
        if ($?) {
            write-host $yeah -F Green
        } else {
            write-host $shit -F Red
            $script:errorcount = $script:errorcount + 1
        }
    }

# ------------------- ENDE Definition der Funktionen --------------------

# ------------------- Hier beginnt der Befehlsablauf --------------------

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

$script:errorcount = 0

# Drucker löschen

    $printer = "Microsoft XPS Document Writer"
    delete-unwantedprinter $printer

    $printer = "Fax"
    delete-unwantedprinter $printer


# Standard-Apps definieren

    $scriptpath = Get-ScriptDirectory
    $yeah = "OK: Standard-Apps wurden für den nächsten neuen User festgelegt"
    $shit = "FEHLER: Die Standard-Apps konnten nicht festgelegt werden."
    Dism /Online /Import-DefaultAppAssociations:$scriptpath\AppAssoc.xml | Out-Null
    errorcheck


# (fast) alle Kacheln im Startmenü löschen

    <#
    Hier wird eine Datei im Default User Profile geändert.
    Wirkt sich also somit auf alle neu angelegten User aus
    #>

    $defaultpath = "C:\Users\Default User\Appdata\Local\Microsoft\Windows\Shell"

    if (!(Test-Path $defaultpath\DefaultLayouts-original.xml)) {
        $yeah = "OK: Startmenü-Kacheln werden für den nächsten neuen User entfernt"
        $shit = "FEHLER: Starmenü-Kacheln konnten nicht kongifuriert werden"
        ren $defaultpath\DefaultLayouts.xml $defaultpath\DefaultLayouts-original.xml
        copy $scriptpath\startmenu.xml $defaultpath\DefaultLayouts.xml
        errorcheck
    } else {
        write-host "INFO: Einstellungen für Startmenü-Kacheln wurden bereits gesetzt" -F Yellow
    }


# App Datenschutz

        <# Vorlage für Registry-Set
        
        $name = ""
        $type = "DWORD"
        $value = 2
        set-registryvalue

        #>


    # Registry-Key anlegen
    
    $key = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy"
    set-registrykey
 
    $type = "DWORD"
    $value = 2

    # Kontoinformationen

        $name = "LetAppsAccessAccountInfo"
        set-registryappp

    # Kalender

        $name = "LetAppsAccessCalendar"
        set-registryappp

    # Telefonanrufe

        $name = "LetAppsAccessCallHistory"
        set-registryappp

    # Kamera

        $name = "LetAppsAccessCamera"
        set-registryappp

    # Kontakte

        $name = "LetAppsAccessContacts"
        set-registryappp

    # Email

        $name = "LetAppsAccessEmail"
        set-registryappp

    # Position

        $name = "LetAppsAccessLocation"
        set-registryappp

    # Messaging

        $name = "LetAppsAccessMessaging"
        set-registryappp

    # Mikrofon

        $name = "LetAppsAccessMicrophone"
        set-registryappp

    # Motion

        $name = "LetAppsAccessMotion"
        set-registryappp

    # Benachrichtigungen

        $name = "LetAppsAccessNotifications"
        set-registryappp

    # Telefonie

        $name = "LetAppsAccessPhone"
        set-registryappp

    # Funktechnik

        $name = "LetAppsAccessRadios"
        set-registryappp

    # App Syncronisierung

        $name = "LetAppsSyncWithDevices"
        set-registryappp

    # Aufgaben

        $name = "LetAppsAccessTasks"
        set-registryappp

    # weitere Geräte

        $name = "LetAppsAccessTrustedDevices"
        set-registryappp

    # Hintergrund-Apps

        $name = "LetAppsRunInBackground"
        set-registryappp

    # Diagnose-Informationen

        $name = "LetAppsGetDiagnosticInfo"
        set-registryappp



# AppV deaktivieren

    $title = "AppV Client"
    $key = "HKLM:\Software\Policies\Microsoft\AppV\Client"
    $name = "Enabled"
    $type = "DWORD"
    $value = 0
    set-registryvalue

# Telemetrie deaktivieren

    $title = "Telemetrie"
    $key = "HKLM:\SOFTWARE\Microsoft\DataCollection"
    $name = "AllowTelemetry"
    $type = "DWORD"
    $value = 0
    set-registryvalue

# Postionen und Sensoren: Sensoren deaktivieren

    $title = "Positions-Sensor"
    $key = "HKLM:\Software\Policies\Microsoft\Windows\LocationAndSensors"
    $name = "DisableSensors"
    $type = "DWORD"
    $value = 1
    set-registryvalue


# Script-Ende

if ($errorcount -lt 1) {
    write-host "
        Alles erfolgreich abgeschlossen.
          > > Yippie ya yeah Schweinebacke!
        " -F Green
} else {
    write-host "
        Es sind $script:errorcount Fehler aufgetreten...
        ...but it's better to burn out then to fade away
        " -F Red
}