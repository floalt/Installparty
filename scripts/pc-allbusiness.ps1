<#

	Konfigurationen für alle Business-PCs
	Aufruf durch start-party4pc.cmd
    version: 0.7


    Vorlage für neuen Registry-Block:

    $title = ""
    $action = ""
    $key = "HKCU:\"
    $name = ""
    $type = "DWORD"
    $value = 0
    set-registry
#>

# ---------------- Hier werden alle Funktionen definiert ----------------

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
        $yeah = "OK: $title wurde erfolgreich ausgeführt"
        $shit = "Fehler: $title konnte nicht ausfeführt werden"
        Set-ItemProperty -Type $type -Path $key -Name $name -Value $value
        errorcheck
    }



# ------------------- ENDE Definition der Funktionen --------------------

# ------------------- Hier beginnt der Befehlsablauf --------------------

Write-Host "INFO: Beginne mit allgemeinen Konfigurationen für Business-PCs" -F Yellow
$global:steps = $global:steps + 1



# Remotedesktop deaktivieren

    # Registry Key
    $title = "Remotedesktop aktivieren"
    $key = "HKLM:\System\CurrentControlSet\Control\Terminal Server"
    $name = "fDenyTSConnections"
    $type = "DWORD"
    $value = 0
    set-registryvalue

    # Firewall:
    $yeah = "OK: Firewall wurde für RDP geöffnet"
    $shit = "FEHLER: Firewall konnte nicht für RDP geöffnet werden"
    Enable-NetFirewallRule -DisplayGroup "RemoteDesktop"
    errorcheck

 


# E N D E

Write-Host "FERTIG: Allgemeine Konfigurationen für Business-PCserledigt" -F Green
