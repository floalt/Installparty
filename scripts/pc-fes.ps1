<#

	Konfigurationen für Friedel-Eder-Schule
	Aufruf durch start-party4pc.cmd
    version: 0.62

#>


Write-Host "INFO: Beginne mit Konfigurationen für Friedel-Eder-Schule" -F Yellow
$global:steps = $global:steps + 1

$workgroup = "fes"
$tv_config = "teamviewer_fes.tvopt"

$filestodelete = @(
    "$env:PUBLIC\Desktop\TeamViewer Host"
    )

# ---------------- Hier werden alle Funktionen definiert ----------------


# Lösche Dateien

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

# Arbeitsgruppe ändern

    $workgroupnow = (Get-ComputerInfo).csdomain
    if ($workgroup -ne $workgroupnow) {
        $yeah = "OK: Der Computer wurde erfolgreich zur Arbeitsgruppe $workgroup hinzugefügt"
        $shit = "FEHLER: Der Computer konnte nicht zur Arbeitsgruppe $workgroup hinzugefügt werden"
        Add-Computer -WorkgroupName $workgroup ;errorcheck
    }

# Dateien löschen

    remove-files

# Teamviewer-Config auf Desktop kopieren

    Copy-Item $global:scriptpath\customerfiles\$tv_config $env:USERPROFILE\Desktop


# E N D E

Write-Host "FERTIG: Konfigurationen für Friedel-Eder-Schule erledigt" -F Green
