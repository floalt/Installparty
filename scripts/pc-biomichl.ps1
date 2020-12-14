<#

	Konfigurationen für Biomichl OHG
	Aufruf durch start-party4pc.cmd
    version: 0.62

#>


﻿Write-Host "INFO: Beginne mit Konfigurationen für Biomichl OHG" -F Yellow
$global:steps = $global:steps + 1

$workgroup = "biomichl"
$tv_config = "teamviewer_biomichl.tvopt"

$filestodelete = @(
    "$env:PUBLIC\Desktop\TeamViewer Host"
    )

# ---------------- Hier werden alle Funktionen definiert ----------------


# Lösche Dateien

# Lösche Dateien

    function delete-files {
		if ($filestodelete) {
		    foreach ($item in $filestodelete) {
		        if (test-path $item) {rm $item}
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

    delete-files

# Teamviewer-Config auf Desktop kopieren

    cp $global:scriptpath\customerfiles\$tv_config $env:USERPROFILE\Desktop


# E N D E

Write-Host "FERTIG: Konfigurationen für Biomichl OHG erledigt" -F Green
