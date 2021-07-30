<#

	Konfigurationen für alle Privat-PCs
	Aufruf durch start-party4pc.cmd
    version: 0.7


    Vorlage für neuen Registry-Block:

    $title = ""
    $action = ""
    $key = "HKCU:\"
    $name = ""
    $type = "DWORD"
    $value = 0
    set-registry
    #>

Write-Host "INFO: Beginne mit Konfigurationen für Privat-PCs" -F Yellow
$global:steps = $global:steps + 1


# ---------------- Hier werden alle Funktionen definiert --------------

# Funktion: legt einen Registry Wert für AppPrivacy fest

    function set-registryappp {
        if (!(Test-Path $key)) {New-Item $key -Force | Out-Null}
        $yeah = "OK: App Datenschutz: $name erfolgreich deaktiviert"
        $shit = "FEHLER:  App Datenschutz: $name konnte nicht deaktiviert werden"
        Set-ItemProperty -Type $type -Path $key -Name $name -Value $value
        errorcheck
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


# ------------------- ENDE Definition der Funktionen --------------------

# ------------------- Hier beginnt der Befehlsablauf --------------------


# Standard-Apps definieren

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


# Dienste deaktivieren

    $title = "Benutzererfahrung und Telemetrie"
    $servicename = "DiagTrack"
    deactivate-service


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


# E N D E

Write-Host "FERTIG: Konfigurationen für Privat-PCs erledigt" -F Green
