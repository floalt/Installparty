<#

    Konfigurations-Script für ein neues Benutzerprofil
    wird bei PCs angewandt, die nicht in einer Domäne verwaltet werden
    Aufruf durch start-party4me.cmd

    author: flo.alt@fa-netz.de
    https://github.com/floalt/installparty
    version: 0.7


    Vorlage für neuen Registry-Block:

    $title = ""
    $action = ""
    $key = "HKCU:\"
    $name = ""
    $type = "DWORD"
    $value = 0
    set-registryvalue

#>


# ---------------- Hier werden alle Funktionen definiert ---------------------

# Funktion: Script-Verzeichnis auslesen

    function Get-ScriptDirectory {
        Split-Path -parent $PSCommandPath
    }
    $scriptpath = Get-ScriptDirectory


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
        $yeah = "OK: $title wurde erfolgreich $action"
        $shit = "Fehler: $title konnte nicht $action werden"
        Set-ItemProperty -Type $type -Path $key -Name $name -Value $value
        errorcheck
    }


# FUnktion: löscht einen Registry Wert

    function del-registryvalue {
        $yeah = "OK: $title wurde erfolgreich gelöscht"
        $shit = "Fehler: $title konnte nicht gelöscht werden"
        if (Test-Path $key\$name) {
            Remove-ItemProperty -Path $key -Name $name
            errorcheck
        }
    }


# Funktion: Desktop-Verknüpfung löschen

    function del-desktoplink {
        $yeah ="OK: $unwantedlink wurde vom Desktop gelöscht"
        $shit ="FEHLER: $title konnte nicht vom Desktop gelöscht werden"
        if (Test-Path $env:USERPROFILE\Desktop\$unwantedlink.lnk) {
            del $env:USERPROFILE\Desktop\$unwantedlink.lnk
            errorcheck
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

# Begrüßung

Write-Host "
    ;-) Install-Party ;-) `n
    Konfiguration für neue Benutzerprofile
    " -F Yellow

Write-Host "
    >>>>> Party on, Wayne
            >>>>> Party on, Garth `n
    " -F Green

Start-Sleep 1

$script:errorcount = 0


# Cortana / Bing Search deaktivieren

    $title = "Bing Search"
    $action = "deaktiviert"
    $key = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search"
    $name = "BingSearchEnabled"
    $type = "DWORD"
    $value = 0
    set-registryvalue

    $title = "Cortanta Consent"
    $action = "deaktiviert"
    $key = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search"
    $name = "CortanaConsent"
    $type = "DWORD"
    $value = 0
    set-registryvalue

# Schaltet die Suchleiste in der Taskbar aus:

    $title = "Suchleiste in der Taskbar"
    $action = "deaktiviert"
    $key = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search"
    $name = "SearchboxTaskbarMode"
    $type = "DWORD"
    $value = 0
    set-registryvalue


# Anpassungen des Datenschutz

    $title = "Starten von Apps nachverfolgen"
    $action = "deaktiviert"
    $key = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    $name = "Start_TrackProgs"
    $type = "DWORD"
    $value = 0
    set-registryvalue

    $title = "Zugriff auf Sprachenliste für Websites"
    $key = "HKCU:\Software\Microsoft\Internet Explorer\International"
    $name = "AcceptLanguage"
    del-registryvalue

    $title = "Freihand- und Eingabeanpassung (1)"
    $action = "deaktiviert"
    $key = "HKCU:\Software\Microsoft\InputPersonalization\TrainedDataStore"
    $name = "HarvestContacts"
    $type = "DWORD"
    $value = 0
    set-registryvalue

    $title = "Freihand- und Eingabeanpassung (2)"
    $action = "deaktiviert"
    $key = "HKCU:\Software\Microsoft\Personalization\Settings"
    $name = "AcceptedPrivacyPolicy"
    $type = "DWORD"
    $value = 0
    set-registryvalue

    $title = "Feedbackhäufigkeit"
    $action = "genullt"
    $key = "HKCU:\Software\Microsoft\Siuf\Rules"
    $name = "NumberOfSIUFInPeriod"
    $type = "DWORD"
    $value = 0
    set-registryvalue

    $title = "Zugriff auf Dokumenten-Bibliothek"
    $action = "deaktiviert"
    $key = "HKCU:\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\documentsLibrary"
    $name = "Value"
    $type = "String"
    $value = "Deny"
    set-registryvalue

    $title = "Zugriff auf Bild-Bibliothek"
    $action = "deaktiviert"
    $key = "HKCU:\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\picturesLibrary"
    $name = "Value"
    $type = "String"
    $value = "Deny"
    set-registryvalue

    $title = "Zugriff auf Video-Bibliothek"
    $action = "deaktiviert"
    $key = "HKCU:\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\videosLibrary"
    $name = "Value"
    $type = "String"
    $value = "Deny"
    set-registryvalue

    $title = "Zugriff auf Dateisystem"
    $action = "deaktiviert"
    $key = "HKCU:\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\broadFileSystemAccess"
    $name = "Value"
    $type = "String"
    $value = "Deny"
    set-registryvalue


# Blendet den Arbeitsplatz auf dem Desktop ein:

    $title = "Arbeitsplatz auf dem Desktop"
    $action = "eingeblendet"
    $key = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel"
    $name = "{20D04FE0-3AEA-1069-A2D8-08002B30309D}"
    $type = "DWORD"
    $value = 0
    set-registryvalue


# Desktop-Verknüpfungen löschen

    $unwantedlink = "Microsoft Edge"
    del-desktoplink


# Appdata Defaults

    $7zpath = "C:\Program Files\7-Zip"
    $7zfile = "appdata.7z"
    $appdtadir = $env:APPDATA
    $yeah = "OK: Appdata Default wurden erfolgreich erstellt"
    $shit = "FEHLER: Appdata Defaults konnten nicht erstell werden"

    mkdir C:\tempdir7z | Out-Null
    & $7zpath\7z.exe x  -o"c:\tempdir7z" -y $scriptpath\$7zfile | Out-Null
    Copy-Item C:\tempdir7z\* $appdtadir -Force -Recurse
    errorcheck
    Remove-Item C:\tempdir7z -Recurse -Force


# Onedrive deinstallieren (funktioniert aber irgendwie nicht?)

    & $env:SystemRoot\SysWOW64\OneDriveSetup.exe /uninstall
    Write-Host "INFO: OneDrive Deinstallation wurde gestartet" -F Yellow

# Script Ende

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

write-host "Bitte klicke im Fenster OneDriveSetup auf >> Ja <<" -F Yellow
write-host "Füge das angezeigte Addon in Firefox hinzu.`n" -F Yellow
