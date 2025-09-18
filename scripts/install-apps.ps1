<#

	Installiert Standard-Software auf einem neuen PC
	lädt Textdatei Softwarequellen von software.txt
	Aufruf durch start-party4pc.cmd
    version: 0.73

#>


# ---------- Konfiguratin der Variablen --------------

    # Standard-Software für alle

    $inst_standard = @(
        '7-Zip'
        'Google Chrome'
        'Irfan View'
        'Mozilla Firefox'
        'KeePass'
        'VLC Media Player'
    )

    # Software indiviuell

    $inst_private = @(
#        'ESET Internet Security'
        'Libre Office'
        'Thunderbird'
    )

    $inst_ascair = @(
        'ESET ERA'
        'ESET Endpoint'
        'GFI Agent'
        'Teamviewer Host'
#       'CallAssist'
        'Greenshot'
    )

    $inst_biomichl = @(
        'Adobe Reader'
        'ESET ERA'
        'ESET Endpoint'
        'GFI Agent'
        'Teamviewer Host'
#       'CallAssist'
        'Nextcloud Client'
        'Libre Office'
    )

    $inst_fes = @(
        'ESET ERA'
        'ESET Endpoint'
        'GFI Agent'
        'Teamviewer Host'
        'Nextcloud Client'
    )

    $inst_isarland = @(
        'ESET ERA'
        'ESET Endpoint'
        'GFI Agent'
        'Nextcloud Client'
#       'Teamviewer 11'
        'Teamviewer 11 Host'
        'Nextcloud Client'
    )

    $inst_raab = @(
        'ESET ERA'
        'ESET Endpoint'
        'GFI Agent'
#       'PDF XChange Editor'
        'Teamviewer Host'
        'Nextcloud Client'
        'Libre Office'
    )



# ------------- ENDE Konfiguratin der Variablen --------------------------



# ---------------- Hier werden alle Funktionen definiert ----------------

# Funktion: Fehlercheck


    function errorcheck {
        if ($?) {
            write-host $yeah -F Green
        } else {
            write-host $shit -F Red
            $global:errorcount = $global:errorcount + 1
        }
    }



# Download Software

    function download {
        Write-Host "--------------------"
        Write-Host "OK: Starte Download $name..." -F Green
        $yeah = "OK: Installations-Datei erfolgreich heruntergeladen."
        $shit = "FEHLER: Installations-Datei konnte leider nicht heruntergeladen werden"
        Invoke-WebRequest $url -OutFile $file
        errorcheck
    }


# Install Software

    function install {

        Write-Host "OK: Starte Installation von $name..." -F Green
        $ext = (Get-Item $file).extension

        $yeah = "OK: Installation von $name erfolgreich abgeschlossen."
        $shit = "FEHLER: Installation von $name fehlgeschlagen"
        if ($ext -eq ".exe") {
            if ($param -eq "") {
                Start-Process $file -Wait
                errorcheck
            } else {
                Start-Process $file -Wait -ArgumentList $param
                errorcheck
            }
        } elseif ($ext -eq ".msi") {
            if ($param -eq "") {
                Start-Process msiexec.exe -Wait -ArgumentList "/i $file"
                errorcheck
            } else {
                Start-Process msiexec.exe -Wait -ArgumentList "/i $file $param"
                errorcheck
            }
        } else {
            Write-Host "FEHLER: Installation-Datei hat keine gültige Dateierweiterung (exe oder msi)" -ForegroundColor Red
        }
    }


# Programmpfad herausfinden

    function Get-AppPath ($mysoftware) {

        $check32 = Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object {$_.DisplayName -like "*$mysoftware*"}
        if (!$check32) {
            $check64 = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object {$_.DisplayName -like "*$mysoftware*"}
            if ($check64) {
                Write-Host "OK: found $mysoftware 64-bit." -F Green
                $details = $check64
            }

        } else {
            Write-Host "OK: found $mysoftware 32-bit." -F Green
            $details = $check32
        }

        $mypath = $details.InstallLocation
        return $mypath
    }

# ------------------- ENDE Definition der Funktionen --------------------

# ------------------- Hier beginnt der Befehlsablauf --------------------



Write-Host "INFO: Beginne mit der Software-Installation" -F Yellow
$global:steps = $global:steps + 1

$software_list = $scriptpath + "\software.txt"
$mytemp = (Get-Item $env:TEMP).fullname



# Textdatei Softwareliste einlesen

    $all_software = Import-Csv -Path $software_list -Delimiter ";"


# Softwareliste für Standard-Software bauen

    # Tempfile für Softwareliste vorbereiten
    $tmpfile = "$mytemp\softwarenow.txt"
    Get-Content -path $software_list -head 1 | Out-File $tmpfile

    if ($software) {Remove-Variable software}

    # Nach den richtigen Objekten in der Gesamtliste suchen und in Tempfile schreiben
    foreach ($result in $inst_standard) {
        $match = ($all_software | Where-Object {$_.name -eq $result})
        $match.name + ";" + $match.ver + ";" + $match.url + ";" + $match.file + ";" + $match.param | Out-File $tmpfile -Append
    }

# Softwareliste für zusüätzliche Software bauen

    # Was wird installiert?
    switch -Wildcard($global:kindof) {
        ascair {$inst_list = $inst_ascair; break}
        biomichl {$inst_list = $inst_biomichl; break}
        fes {$inst_list = $inst_fes; break}
        isarland {$inst_list = $inst_isarland; break}
        raab {$inst_list = $inst_raab; break}
        privat {$inst_list = $inst_private; break}
    }


    # Nach den richtigen Objekten in der Gesamtliste suchen und in Tempfile schreiben
    foreach ($result in $inst_list) {
        $match = ($all_software | Where-Object {$_.name -eq $result})
        $match.name + ";" + $match.ver + ";" + $match.url + ";" + $match.file + ";" + $match.param | Out-File $tmpfile -Append
    }


# Array erstellen: Software, die jetzt installiert werden soll

    $software = Import-Csv -Path $tmpfile -Delimiter ";"


# Download & Install

$ProgressPreference = 'SilentlyContinue'

    foreach ($app in $software) {

        # Variablen extrahieren

            $name = $app.name
            $ver = $app.ver
            $url = $app.url
            $file = $mytemp + "\" + $app.file
            $param = $app.param


        # Download & Install

            download
            install
            Remove-Item $file
    }

$ProgressPreference = 'Continue'


# Install KeePass Language & Plugin Files

    # Programmordner herausfinden

        $keepath = Get-AppPath Keepass

    # Download $ Extract ZIP

        if ($keepath) {

            $name = "KeePass Language & Script Files"
            $url = "https://doku.fa-netz.de/downloads/keepassfiles.zip"
            $zipfile = $mytemp + "\" + "keepassfiles.zip"
            
            $file = $zipfile
            download

            $yeah = "OK: KeePass Language & Script Files erfolgreich kopiert."
            $shit = "FEHLER: Extrahieren der KeePass Language & Script Files fehlgeschlagen"
            Expand-Archive $zipfile $keepath -Force; errorcheck
            
            Remove-Item $zipfile
        }




# E N D E

Write-Host "FERTIG: Alle Programme wurden installiert" -F Green
