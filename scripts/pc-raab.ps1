<#

	Konfigurationen für Raab Home Company
	Aufruf durch start-party4pc.cmd
    version: 0.72

#>


﻿Write-Host "INFO: Beginne mit Konfigurationen für Raab Home Company" -F Yellow
$global:steps = $global:steps + 1

$workgroup = "raab"
$tv_config = "teamviewer_raab.tvopt"

$filestodelete = @(
    "$env:PUBLIC\Desktop\Office2PDF5.lnk",
    "$env:PUBLIC\Desktop\PDF-Tools 4.lnk",
    "$env:PUBLIC\Desktop\PDF-XChange Editor.lnk"
    )

# ---------------- Hier werden alle Funktionen definiert ----------------


# Lösche Dateien

    function remove-files {
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


# Lizenzdatei für PDF Exchange Editor

    Write-Output "PXP50-RtYdiRRNw3dfZ6dYoL9DKxevHJNkBJuooBeJUxE7Ll0CejjR+2QM3SaST4LIFEpY" > $env:USERPROFILE\Desktop\XChangeEditor-Lizenz.txt
    Write-Output "AxG7qtWGiO/UVk6O4bgzOFrUEfRVkIsJluVdJZ012kg+0igJY/ToITyoNNb8HY9gwp9umnoxF/QEm4IQ" >> $env:USERPROFILE\Desktop\XChangeEditor-Lizenz.txt
    Write-Output "wchND5X6K7QaARrX71646joENfSACJ+UQt04eCZHEbrK8faljKTyVoQHwuSAq/UGJROVZDPMC9t7t+wP" >> $env:USERPROFILE\Desktop\XChangeEditor-Lizenz.txt
    Write-Output "cAYNbbYB01CYjngPWJxWnmneEZu17zR6Tj7vnCkPBJMX3si3wsVDAXz8VYqGFE6x8Mr6rSJDxbXeC/dr" >> $env:USERPROFILE\Desktop\XChangeEditor-Lizenz.txt
    Write-Output "ynPTap0XHO7pinCsjTqrOOaEDmgDF0kpLICGWqbjyOs=" >> $env:USERPROFILE\Desktop\XChangeEditor-Lizenz.txt


# Dateien löschen

    remove-files

# Teamviewer-Config auf Desktop kopieren

    Copy-Item $global:scriptpath\customerfiles\$tv_config $env:USERPROFILE\Desktop


# E N D E

Write-Host "FERTIG: Konfigurationen für Raab Home Company erledigt" -F Green
