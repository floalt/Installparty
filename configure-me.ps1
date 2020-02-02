<#

    Konfigurations-Script für ein neues Benutzerprofil
    wird bei PCs angewandt, die nicht in einer Domäne verwaltet werden

    author: flo.alt@fa-netz.de
    version: 0.5


    Vorlage für neuen Registry-Block:

    $key = "HKCU:\"
    $name = ""
    $type = "DWORD"
    $value = 0
    set-registry

#>


# Funktion: legt einen Registry Wert fest

    function set-registry {
        if (!(Test-Path $key)) {New-Item $key -Force}
        Set-ItemProperty -Type $type -Path $key -Name $name -Value $value
    }

# Funktion: Script-Verzeichnis auslesen

    function Get-ScriptDirectory {
        Split-Path -parent $PSCommandPath
    }
    $scriptpath = Get-ScriptDirectory



# Onedrive deinstallieren

    & $env:SystemRoot\SysWOW64\OneDriveSetup.exe /uninstall
    echo "OK: OneDrive wurde deinstalliert"


# Cortana / Bing Search deaktivieren
    
    <# Das funktioniert so nicht!!!
    $key = "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"
    $name = "AllowCortana"
    $type = "DWORD"
    $value = 0
    set-registry
    #>

    $key = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search"
    $name = "BingSearchEnabled"
    $type = "DWORD"
    $value = 0
    set-registry

    $key = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search"
    $name = "CortanaConsent"
    $type = "DWORD"
    $value = 0
    set-registry

# Schaltet die Suchleiste in der Taskbar aus:

    $key = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search"
    $name = "SearchboxTaskbarMode"
    $type = "DWORD"
    $value = 0
    set-registry
    echo "OK: Cortana & Bing Search wurde deaktiviert"

# Blendet den Arbeitsplatz auf dem Desktop ein:

    $key = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel"
    $name = "{20D04FE0-3AEA-1069-A2D8-08002B30309D}"
    $type = "DWORD"
    $value = 0
    set-registry
    echo "OK: Arbeitsplatz wurde eingeblendet"

# Desktop-Verknüpfungen löschen

    $unwantedlink = "Microsoft Edge"
    del $env:USERPROFILE\Desktop\$unwantedlink.lnk

# Standard-Apps definieren

    Dism /Online /Import-DefaultAppAssociations:$scriptpath\AppAssoc.xml | Out-Null
    echo "OK: Standard-Apps wurden festgelegt"
    
# Appdata Defaults

    $7zpath = "C:\Program Files\7-Zip"
    $7zfile = "appdata.7z"
    $appdtadir = $env:APPDATA

    mkdir C:\tempdir7z | Out-Null
    & $7zpath\7z.exe x  -o"c:\tempdir7z" -y $scriptpath\$7zfile | Out-Null
    Copy-Item C:\tempdir7z\* $appdtadir -Force -Recurse
    Remove-Item C:\tempdir7z -Recurse -Force
    echo "OK: Appdata Defaults wurden festgelegt"
