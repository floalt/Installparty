<#

	Konfigurationen für Isarland Ökokiste
	Aufruf durch start-party4pc.cmd
    version: 0.72

#>


Write-Host "INFO: Beginne mit Konfigurationen für Isarland Ökokiste" -F Yellow
$global:steps = $global:steps + 1

$workgroup = "isarland"
$fabcert = "customerfiles\cacert_f4m_sha2.cer"

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


# Import Fab4Minds Root Zertifikat

    $yeah = "OK: Root-Zertifikat für Fab4Minds erfolgreich importiert"
    $shit = "Fehler: Root-Zertifikat für Fab4Minds konnte nicht importiert werden"
    Import-Certificate -FilePath $global:scriptpath\$fabcert -CertStoreLocation ‘Cert:\LocalMachine\Root’ | Out-Null
    errorcheck


# E N D E

Write-Host "FERTIG: Konfigurationen für Isarland Ökokiste erledigt" -F Green
