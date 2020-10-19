<#

	Installiert Standard-Software auf einem neuen PC
	lädt Textdatei Softwarequellen von software.txt
	Aufruf durch start-party4pc.cmd
    version: 0.4
    
#>


# ---------------- BEGINN Development ------------------

# Script-Verzeichnis auslesen

    function Get-ScriptDirectory {
        Split-Path -parent $PSCommandPath
    }

$global:scriptpath = Get-ScriptDirectory

$global:scriptpath = "C:\installparty\scripts"

$global:kindof = "privat"


# ---------------- ENDE Development ------------------


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
        'Adobe Reader'
        'Libre Office'
        'Thunderbird'
    )

    $inst_ascair = @(
        'ESET ERA'
        'ESET Endpoint'
        'GFI Agent'
        'Teamviewer Host'
        'CallAssist'
        'Greenshot'
    )

    $inst_biomichl = @(
        'Adobe Reader'
        'ESET ERA'
        'ESET Endpoint'
        'GFI Agent'
        'Teamviewer Host'
        'CallAssist'
    )

    $inst_isarland = @(
        'ESET ERA'
        'ESET Endpoint'
#        'Foxit Reader'
#        'Freemind'
        'GFI Agent'
#        'Launchy'
#        'Open Java JDK'
        'Teamviewer 11'
        'CallAssist'
    )

    $inst_raab = @(
        'ESET ERA'
        'ESET Endpoint'
        'GFI Agent'
        'PDF XChange Editor'
        'Teamviewer Host'
        'CallAssist'
    )



# ------------- ENDE Konfiguratin der Variablen --------------------------


Write-Host "INFO: Beginne mit der Software-Installation" -F Yellow
$global:steps = $global:steps + 1

$software_list = $scriptpath + "\software.txt"



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
        wget $url -OutFile $file
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


# ------------------- ENDE Definition der Funktionen --------------------

# ------------------- Hier beginnt der Befehlsablauf --------------------


# Textdatei Softwareliste einlesen

    $all_software = Import-Csv -Path $software_list -Delimiter ";"


# Softwareliste für Standard-Software bauen

    # Tempfile für Softwareliste vorbereiten
    $tmpfile = "$env:TEMP\softwarenow.txt"
    Get-Content -path $software_list -head 1 | Out-File $tmpfile

    if ($software) {Remove-Variable software}

    # Nach den richtigen Objekten in der Gesamtliste suchen und in Tempfile schreiben
    foreach ($result in $inst_standard) {
        $match = ($all_software | where {$_.name -eq $result})
        $match.name + ";" + $match.ver + ";" + $match.url + ";" + $match.file + ";" + $match.param | Out-File $tmpfile -Append
    }

# Softwareliste für zusätzliche Software bauen

    # Was wird installiert?
    switch -Wildcard($global:kindof) {
        ascair {$inst_list = $inst_ascair; break}
        biomichl {$inst_list = $inst_biomichl; break}
        isarland {$inst_list = $inst_isarland; break}
        raab {$inst_list = $inst_raab; break}
        privat {$inst_list = $inst_private; break}
    }


    # Nach den richtigen Objekten in der Gesamtliste suchen und in Tempfile schreiben
    foreach ($result in $inst_list) {
        $match = ($all_software | where {$_.name -eq $result})
        $match.name + ";" + $match.ver + ";" + $match.url + ";" + $match.file + ";" + $match.param | Out-File $tmpfile -Append
    }


# Array erstellen: Software, die jetzt installiert werden soll

    $software = Import-Csv -Path $tmpfile -Delimiter ";"


# Nachfragen, welche Software installiert werden soll

Write-Host "Ich kann folgende Software installieren:" -F Yellow
Write-Host $inst_standard
Write-Host $inst_list



# Download & Install

$ProgressPreference = 'SilentlyContinue'

    foreach ($app in $software) {

        # Variablen extrahieren

            $name = $app.name
            $ver = $app.ver
            $url = $app.url
            $file = $env:TEMP + "\" + $app.file
            $param = $app.param


        # Download & Install

            download
            install
            rm $file
    }

$ProgressPreference = 'Continue'


# E N D E

Write-Host "FERTIG: Alle Programme wurden installiert" -F Green



<#

$KEEPASS_LANGURL = "https://cloud.fa-netz.de/index.php/s/3Ax3NpMJ2JJ32d3/download"
$KEEPASS_LANGFILE = "German.lngx"
$KEEPASS_RPCURL = "https://github.com/kee-org/keepassrpc/releases/download/v1.9.0/KeePassRPC.plgx"
$KEEPASS_RPCFILE = "KeePassRPC.plgx"

#>
