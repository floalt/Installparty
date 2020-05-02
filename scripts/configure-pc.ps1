<#

    Konfigurations-Script für eine neu Windows-Installation
    wird bei PCs angewandt, die nicht in einer Domäne verwaltet werden
    Aufruf durch start-party4pc.cmd

    author: flo.alt@fa-netz.de
    https://github.com/floalt/installparty/blob/master/executionpolicy.cmd
    version: 0.62


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


# Funktion: Desktop-Verknüpfung löschen
    
    function del-desktoplink {
        $yeah ="OK: $unwantedlink wurde vom Desktop gelöscht"
        $shit ="FEHLER: $title konnte nicht vom Desktop gelöscht werden"
        if (Test-Path $env:PUBLIC\Desktop\$unwantedlink.lnk) {
            del $env:PUBLIC\Desktop\$unwantedlink.lnk
            errorcheck
        }
    }


# Funktion: Desktop-Verknüpfungen erstellen

    function new-desktoplink {
        $menu = "$env:ProgramData\Microsoft\Windows\Start Menu\Programs"
        $linkpath = "$menu\$menudir\$linkfile.lnk"
        if (Test-Path $linkpath) {
            $yeah = "OK: Verknüpfung $linkfile wurde erstellt"
            $shit = "FEHLER: Verknüpfung $linkfile konnte nicht erstellt werden"
            cp $linkpath $env:PUBLIC\Desktop
            errorcheck
        }
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


# Funktion: Neuen Hostname abfragen

function read-hostname {
    $script:newhostname = Read-Host "neuer Hostname"
    # prüfe, ob Eingabe leer ist
    if ($newhostname) {
        $script:doit = 1
    } else {
        $script:doit = 0
    }
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

$scriptpath = Get-ScriptDirectory

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

    $yeah = "OK: Standard-Apps wurden für den nächsten neuen User festgelegt"
    $shit = "FEHLER: Die Standard-Apps konnten nicht festgelegt werden."
    Dism /Online /Import-DefaultAppAssociations:$scriptpath\files\AppAssoc.xml | Out-Null
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
        copy $scriptpath\files\startmenu.xml $defaultpath\DefaultLayouts.xml
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

    $title = "Telemetrie (1)"
    $key = "HKLM:\SOFTWARE\Microsoft\DataCollection"
    $name = "AllowTelemetry"
    $type = "DWORD"
    $value = 0
    set-registryvalue

    $title = "Telemetrie (2)"
    $key = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
    $name = "AllowTelemetry"
    $type = "DWORD"
    $value = 0
    set-registryvalue

# Diagnosedaten komplett deaktivieren

    $title = "Diagnosedaten komplett (1)"
    $key = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection"
    $name = "AllowTelemetry"
    $type = "DWORD"
    $value = 0
    set-registryvalue

    $title = "Diagnosedaten komplett (2)"
    $key = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection"
    $name = "MaxTelemetryAllowed"
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


# Dienste deaktivieren

    $title = "Benutzererfahrung und Telemetrie"
    $servicename = "DiagTrack"
    deactivate-service


# PC-Namen ändern

    $hostname = $env:COMPUTERNAME

    Write-Host "
        aktueller Hostname: $hostname
        Jetzt kann der Hostname des PCs geändert werden.
        Bitte gib einen neuen Hostnamen ein
        oder drücke Enter, um den aktuellen Namen zu behalten" -F Yellow
    
    read-hostname

    if ($doit -eq 1) {
        $yeah = "OK: Der Hostname wird beim nächsten Neustart geändert"
        $shit = "FEHLER: Der Hostname konnte nicht geändert werden"
        Rename-Computer -NewName $newhostname
        errorcheck
        echo $newhostname > $scriptpath\hostname.tmp
    
    } else {
        Write-Host "OK: Der Hostname bleibt unverändert." -F Yellow
        echo $hostname > $scriptpath\hostname.tmp
    }

# Desktop-Verknüpfungen löschen

    $unwantedlink = "Acrobat Reader DC"
    del-desktoplink

    $unwantedlink = "VLC media player*"
    del-desktoplink

# Desktop-Verknüpfungen erstellen

    $menudir = "LibreOffice 6.3"
    $linkfile = "LibreOffice Writer"
    new-desktoplink

    $menudir = "LibreOffice 6.3"
    $linkfile = "LibreOffice Calc"
    new-desktoplink


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
