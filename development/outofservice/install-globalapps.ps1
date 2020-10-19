Write-Host "INFO: Beginne mit der Installation von Standard-Software" -F Yellow
$global:steps = $global:steps + 1


# Installation Windows 10 PC
# This script downloads and installs standard software products for our Windows 10 installation

# Author: flo.alt@fa-netz.de
# https://github.com/floalt/installparty
# Version: 0.5


# --------- Config Software Downloads ---------- #

# Download Folder
$DWL = "c:\install\downloads"

<# Vorlage Configurations-Block:
    
# SoftwareName
$_NAME = ""
$_VER = ""
$_URL = ""
$_FILE = ""
$_PARAM = ""

#>


# 7-Zip
$7ZIP_NAME = "7-Zip"
$7ZIP_VER = "19.00"
$7ZIP_URL = "https://www.7-zip.org/a/7z1900-x64.exe"
$7ZIP_FILE = "7z1900-x64.exe"
$7ZIP_PARAM = "/S"

# Adobe Reader
$ADREADER_NAME = "Adobe Reader"
$ADREADER_VER = "2000620042"
$ADREADER_URL = "ftp://ftp.adobe.com/pub/adobe/reader/win/AcrobatDC/2000620042/AcroRdrDC2000620042_de_DE.exe"
$ADREADER_FILE = "AcroRdrDC2000620042_de_DE.exe"
$ADREADER_PARAM = "/sPB"

# Firefox
$FIREFOX_NAME = "Mozilla Firefox"
$FIREFOX_VER = "latest-build"
$FIREFOX_URL = "https://download.mozilla.org/?product=firefox-msi-latest-ssl&os=win64&lang=de"
$FIREFOX_FILE = "firefoxsetup.msi"
$FIREFOX_PARAM = "/passive"

# IrfanView
$IRFAN_NAME = "Irfan View"
$IRFAN_VER = "4.54"
$IRFAN_URL = "http://download.betanews.com/download/967963863-1/iview454_x64_setup.exe"
$IRFAN_FILE = "iview454_x64_setup.exe"
$IRFAN_PARAM = "/silent /group=1 /assoc=1 /ini=$env:APPDATA\IrfanView"

# KeePass
$KEEPASS_NAME = "KeePass"
$KEEPASS_VER = "2.44"
$KEEPASS_URL = "https://cloud.fa-netz.de/index.php/s/3By3SsA83EermWH/download"
$KEEPASS_FILE = "KeePass-2.43-Setup.exe"
$KEEPASS_PARAM = "/VERYSILENT"
$KEEPASS_LANGURL = "https://cloud.fa-netz.de/index.php/s/3Ax3NpMJ2JJ32d3/download"
$KEEPASS_LANGFILE = "German.lngx"
$KEEPASS_RPCURL = "https://github.com/kee-org/keepassrpc/releases/download/v1.9.0/KeePassRPC.plgx"
$KEEPASS_RPCFILE = "KeePassRPC.plgx"

# VLC Media Player
$VLC_NAME = "VLC Media Player"
$VLC_VER = "3.0.8"
$VLC_URL = "https://mirror.init7.net/videolan/vlc/3.0.8/win64/vlc-3.0.8-win64.exe"
$VLC_FILE = "vlc-3.0.8-win64.exe"
$VLC_PARAM = "/S /L=1031"

# Libre Office
$LIBOFF_NAME = "Libre Office"
$LIBOFF_VER = "6.4.2"
$LIBOFF_URL = "https://mirror1.hs-esslingen.de/pub/Mirrors/tdf/libreoffice/stable/6.4.2/win/x86_64/LibreOffice_6.4.2_Win_x64.msi"
$LIBOFF_FILE = "LibreOffice_6.4.2_Win_x64.msi"
$LIBOFF_PARAM = "/passive REGISTER_ALL_MSO_TYPES=1"

# Thunderbird
$TBIRD_NAME = "Thunderbird"
$TBIRD_VER = "68.7.0"
$TBIRD_URL = "https://download.mozilla.org/?product=thunderbird-68.7.0-msi-SSL&os=win64&lang=de"
$TBIRD_FILE = "thunderbird-68.7.0.msi"
$TBIRD_PARAM = "/passive"




# ------- END Config Software Downlodas -------- #

# -------------- Functions --------------------- #

# Download Software

function download {
    # Download
 function download {
    # Download
    Write-Host "OK: Starte Download $INST_NAME..." -F Green
    $yeah = "OK: Installations-Datei erfolgreich heruntergeladen."    $shit = "FEHLER: Installations-Datei konnte leider nicht heruntergeladen werden"
    wget $INST_URL -OutFile $INST_FILE
    errorcheck
}
}


# Install Software

function install {

    Write-Host "OK: Starte Installation von $INST_NAME..." -F Green       $EXT = (Get-Item $INST_FILE).extension    $yeah = "OK: Installation von $INST_NAME erfolgreich abgeschlossen."
    $shit = "FEHLER: Installation von $INST_NAME fehlgeschlagen"    if ($EXT -eq ".exe") {        if ($INST_PARAM -eq "") {            Start-Process $INST_FILE -Wait        } else {            Start-Process $INST_FILE -Wait -ArgumentList $INST_PARAM        }    } elseif ($EXT -eq ".msi") {        if ($INST_PARAM -eq "") {            Start-Process msiexec.exe -Wait -ArgumentList "/i $INST_FILE"        } else {            Start-Process msiexec.exe -Wait -ArgumentList "/i $INST_FILE $INST_PARAM"        }    } else {        Write-Host "FEHLER: Installation-Datei hat keine gültige Dateierweiterung (exe oder msi)" -ForegroundColor Red    }    errorcheck
    rm $INST_FILE
}

# Download and Install Software

function dwl-and-inst {

    Write-Host "Installation $INST_NAME Version $INST_VER" -F Yellow

    download
    install

}

# ----------- END Functions -------------------- #


# F I R S T   S T E P S

if (!(Test-Path $DWL)) {mkdir $DWL > $null}


# S O F T W A R E   I N S T A L L I E R E N

<# Vorlage

# SoftwareName
$INST_NAME = $_NAME
$INST_VER = $_VER
$INST_URL = $_URL
$INST_FILE = "$DWL\$_FILE"
$INST_PARAM = "$_PARAM"
dwl-and-inst

#>



# 7-Zip
$INST_NAME = $7ZIP_NAME
$INST_VER = $7ZIP_VER
$INST_URL = $7ZIP_URL
$INST_FILE = "$DWL\$7ZIP_FILE"
$INST_PARAM = "$7ZIP_PARAM"
dwl-and-inst

# Adobe Reader
$INST_NAME = $ADREADER_NAME
$INST_VER = $ADREADER_VER
$INST_URL = $ADREADER_URL
$INST_FILE = "$DWL\$ADREADER_FILE"
$INST_PARAM = "$ADREADER_PARAM"
dwl-and-inst

# Mozilla Firefox
$INST_NAME = $FIREFOX_NAME
$INST_VER = $FIREFOX_VER
$INST_URL = $FIREFOX_URL
$INST_FILE = "$DWL\$FIREFOX_FILE"
$INST_PARAM = "$FIREFOX_PARAM"
dwl-and-inst

# IrfanView
$INST_NAME = $IRFAN_NAME
$INST_VER = $IRFAN_VER
$INST_URL = $IRFAN_URL
$INST_FILE = "$DWL\$IRFAN_FILE"
$INST_PARAM = "$IRFAN_PARAM"
dwl-and-inst

# KeePass
$INST_NAME = $KEEPASS_NAME
$INST_VER = $KEEPASS_VER
$INST_URL = $KEEPASS_URL
$INST_FILE = "$DWL\$KEEPASS_FILE"
$INST_PARAM = "$KEEPASS_PARAM"
dwl-and-inst
wget $KEEPASS_LANGURL -OutFile $DWL\$KEEPASS_LANGFILE
mv $DWL\$KEEPASS_LANGFILE "C:\Program Files (x86)\KeePass Password Safe 2\Languages" -Force > $null
wget $KEEPASS_RPCURL -OutFile $DWL\$KEEPASS_RPCFILE
mv $DWL\$KEEPASS_RPCFILE "C:\Program Files (x86)\KeePass Password Safe 2\Plugins" -Force > $null

# VLC Media Player
$INST_NAME = $VLC_NAME
$INST_VER = $VLC_VER
$INST_URL = $VLC_URL
$INST_FILE = "$DWL\$VLC_FILE"
$INST_PARAM = "$VLC_PARAM"
dwl-and-inst

# Libre Office
$INST_NAME = $LIBOFF_NAME
$INST_VER = $LIBOFF_VER
$INST_URL = $LIBOFF_URL
$INST_FILE = "$DWL\$LIBOFF_FILE"
$INST_PARAM = "$LIBOFF_PARAM"
dwl-and-inst

# Tunderbird
$INST_NAME = $TBIRD_NAME
$INST_VER = $TBIRD_VER
$INST_URL = $TBIRD_URL
$INST_FILE = "$DWL\$TBIRD_FILE"
$INST_PARAM = "$TBIRD_PARAM"
dwl-and-inst



# E N D E

Write-Host "FERTIG: Alle Programme wurden installiert" -F Green