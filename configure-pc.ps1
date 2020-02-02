<#

    Konfigurations-Script für eine neu Windows-Installation
    wird bei PCs angewandt, die nicht in einer Domäne verwaltet werden

    author: flo.alt@fa-netz.de
    version: 0.5


    Vorlage für neuen Registry-Block:

    $key = "HKCU:\"
    $name = ""
    $type = "DWORD"
    $value = 0
    set-registry

#>


# Funktion: Drucker löschen

    function delete-unwantedprinter {
        $queryprinter = Get-WMIObject -Class Win32_Printer | where {$_.name -eq $printer}
            if ($queryprinter) {
               Remove-Printer -Name $printer
               echo "Lösche Drucker $printer" 
           
               $querydelete = Get-WMIObject -Class Win32_Printer | where {$_.name -eq $printer}
               if ($querydelete) {
                    echo "FEHLER: Der Drucker $printer konnte nicht gelöscht werden"
               } else {
                    echo "OK: Der Drucker $printer wurde gelöscht"
               }
        
            } else {
                echo "INFO: Der Drucker $printer ist nicht vorhanden"
        }
    }


# Funktion: legt einen Registry Wert fest

    function set-registry {
        if (!(Test-Path $key)) {New-Item $key -Force | Out-Null}
        Set-ItemProperty -Type $type -Path $key -Name $name -Value $value
    }



# Funktion: Script-Verzeichnis auslesen

    function Get-ScriptDirectory {
        Split-Path -parent $PSCommandPath
    }


# Drucker löschen

    $printer = "Microsoft XPS Document Writer"
    delete-unwantedprinter $printer

    $printer = "Fax"
    delete-unwantedprinter $printer


# Standard-Apps definieren

    $scriptpath = Get-ScriptDirectory
    Dism /Online /Import-DefaultAppAssociations:$scriptpath\AppAssoc.xml | Out-Null
    echo "OK: Standard-Apps wurden festgelegt"


# (fast) alle Kacheln im Startmenü löschen

    <#
    Hier wird eine Datei im Default User Profile geändert.
    Wirkt sich also somit auf alle neu angelegten User aus
    #>

    $defaultpath = "C:\Users\Default User\Appdata\Local\Microsoft\Windows\Shell"

    if (!(Test-Path $defaultpath\DefaultLayouts-original.xml)) {
        ren $defaultpath\DefaultLayouts.xml $defaultpath\DefaultLayouts-original.xml
        copy $scriptpath\startmenu.xml $defaultpath\DefaultLayouts.xml
        echo "OK: Startmenü-Kacheln werden für den nächsten neuen User entfernt"
    } else {
        echo "INFO: Einstellungen für Startmenü-Kacheln wurden bereits gesetzt"
    }


# App Datenschutz

        <# Vorlage für Registry-Set
        
        $name = ""
        $type = "DWORD"
        $value = 2
        set-registry

        #>


    # Registry-Key anlegen
    
    $key = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy"
    if (!(Test-Path $key)) {New-Item $key | Out-Null}
    
    $type = "DWORD"
    $value = 2

    # Kontoinformationen

        $name = "LetAppsAccessAccountInfo"
        set-registry

    # Kalender

        $name = "LetAppsAccessCalendar"
        set-registry

    # Telefonanrufe

        $name = "LetAppsAccessCallHistory"
        set-registry

    # Kamera

        $name = "LetAppsAccessCamera"
        set-registry

    # Kontakte

        $name = "LetAppsAccessContacts"
        set-registry

    # Email

        $name = "LetAppsAccessEmail"
        set-registry

    # Position

        $name = "LetAppsAccessLocation"
        set-registry

    # Messaging

        $name = "LetAppsAccessMessaging"
        set-registry

    # Mikrofon

        $name = "LetAppsAccessMicrophone"
        set-registry

    # Motion

        $name = "LetAppsAccessMotion"
        set-registry

    # Benachrichtigungen

        $name = "LetAppsAccessNotifications"
        set-registry

    # Telefonie

        $name = "LetAppsAccessPhone"
        set-registry

    # Funktechnik

        $name = "LetAppsAccessRadios"
        set-registry

    # App Syncronisierung

        $name = "LetAppsSyncWithDevices"
        set-registry

    # Aufgaben

        $name = "LetAppsAccessTasks"
        set-registry

    # weitere Geräte

        $name = "LetAppsAccessTrustedDevices"
        set-registry

    # Hintergrund-Apps

        $name = "LetAppsRunInBackground"
        set-registry

    # Diagnose-Informationen

        $name = "LetAppsGetDiagnosticInfo"
        set-registry

    echo "OK: App-Datenschutzeinstellungen wurden konfiguriert"


# AppV deaktivieren

    $key = "HKLM:\Software\Policies\Microsoft\AppV\Client"
    $name = "Enabled"
    $type = "DWORD"
    $value = 0
    set-registry
    echo "OK: AppV Client wurde deaktiviert"

# Telemetrie deaktivieren

    $key = "HKLM:\SOFTWARE\Microsoft\DataCollection"
    $name = "AllowTelemetry"
    $type = "DWORD"
    $value = 0
    set-registry
    echo "OK: Telemetrie wurde deaktiviert"

# Postionen und Sensoren: Sensoren deaktivieren

    $key = "HKLM:\Software\Policies\Microsoft\Windows\LocationAndSensors"
    $name = "DisableSensors"
    $type = "DWORD"
    $value = 1
    set-registry
    echo "OK: Positions-Sensor wurde deaktiviert"

echo `n "Jippie ya yeah Schweinebacke!" `n
