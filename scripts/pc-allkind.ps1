<#

	Konfigurationen für alle PCs
	Aufruf durch start-party4pc.cmd
    version: 0.72


    Vorlage für neuen Registry-Block:

    $title = ""
    $action = ""
    $key = "HKCU:\"
    $name = ""
    $type = "DWORD"
    $value = 0
    set-registry
#>

$filestodelete = @(
    "$env:PUBLIC\Desktop\Microsoft Edge.lnk"
	"$env:PUBLIC\Desktop\VLC media player.lnk"
    "$env:PUBLIC\Desktop\Acrobat Reader.lnk"
    )

# ---------------- Hier werden alle Funktionen definiert ----------------

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


# Lösche Dateien

    function remove-files {
		if ($filestodelete) {
		    foreach ($item in $filestodelete) {
		        if (test-path $item) {Remove-Item $item}
		    }
		}
    }


# ------------------- ENDE Definition der Funktionen --------------------

# ------------------- Hier beginnt der Befehlsablauf --------------------


Write-Host "INFO: Beginne mit allgemeinen Konfigurationen" -F Yellow
$global:steps = $global:steps + 1

# Drucker löschen (wäre bei Windows 11 gar nicht nötig)

    $printer = "Microsoft XPS Document Writer"
    remove-unwantedprinter $printer

    $printer = "Fax"
    remove-unwantedprinter $printer


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


# Dienste deaktivieren

    $title = "Benutzererfahrung und Telemetrie"
    $servicename = "DiagTrack"
    deactivate-service

# Dateien löschen

	remove-files


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
        Write-Output $hostname > $scriptpath\hostname.tmp
    }


# E N D E

Write-Host "FERTIG: Allgemeine Konfigurationen erledigt" -F Green
