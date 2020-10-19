Write-Host "INFO: Beginne mit Konfigurationen für Isarland Ökokiste" -F Yellow
$global:steps = $global:steps + 1

$workgroup = "isarland"

# ---------------- Hier werden alle Funktionen definiert ----------------

# ------------------- ENDE Definition der Funktionen --------------------

# ------------------- Hier beginnt der Befehlsablauf --------------------

# Arbeitsgruppe ändern

$yeah = "OK: Der Computer wurde erfolgreich zur Arbeitsgruppe $workgroup hinzugefügt"
$shit = "FEHLER: Der Computer konnte nicht zur Arbeitsgruppe $workgroup hinzugefügt werden"
Add-Computer -WorkgroupName $workgroup ;errorcheck


# E N D E

Write-Host "FERTIG: Konfigurationen für Isarland Ökokiste erledigt" -F Green