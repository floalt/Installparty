<#

	Konfigurationen für Isarland Ökokiste
	Aufruf durch start-party4pc.cmd
    version: 0.71

#>


Write-Host "INFO: Beginne mit Konfigurationen für Isarland Ökokiste" -F Yellow
$global:steps = $global:steps + 1

$workgroup = "isarland"

$filestodelete = @(
    )

# ---------------- Hier werden alle Funktionen definiert ----------------


# Lösche Dateien

    function delete-files {
        foreach ($item in $filestodelete) {
            if (test-path $item) {rm $item}
        }
    }

# ------------------- ENDE Definition der Funktionen --------------------

# ------------------- Hier beginnt der Befehlsablauf --------------------

# Arbeitsgruppe ändern

    $workgroupnow = (Get-ComputerInfo).csdomain
    if ($workgroup -ne $workgroup) {
        $yeah = "OK: Der Computer wurde erfolgreich zur Arbeitsgruppe $workgroup hinzugefügt"
        $shit = "FEHLER: Der Computer konnte nicht zur Arbeitsgruppe $workgroup hinzugefügt werden"
        Add-Computer -WorkgroupName $workgroup ;errorcheck
    }

# Dateien löschen

    delete-files

# E N D E

Write-Host "FERTIG: Konfigurationen für Isarland Ökokiste erledigt" -F Green
