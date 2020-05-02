<#

    Konfigurations-Script zur Anlage von neuen Benutzern
    wird bei PCs angewandt, die nicht in einer Dom�ne verwaltet werden
    Aufruf durch start-party4pc.cmd

    author: flo.alt@fa-netz.de
    https://github.com/floalt/installparty
    version: 0.62


#>

# ---------------- Start: Funktionen definieren ---------------------

# Funktion: Frage ob Benutzer angelegt werden sollen

function ask-adduser {
    $letsdoit = Read-Host "Soll(en) jetzt ein oder mehrere Benutzer angelegt werden? [J/n]"
    if (($letsdoit -eq "j") -or (!$letsdoit)) {
            $script:doit = 1
            } elseif ($letsdoit -eq "n") {
            $script:doit = 0
            } else {
            Write-Host "Bitte 'j' oder 'n' eingeben (Enter f�r Ja)" -F Red
            ask-adduser
        }
}

# Funktion: Vollst�ndiger Name abfragen

function read-fullname {
    $script:fullname = Read-Host "Vollst�ndiger Name"
    # pr�fe, ob Benutzername leer ist
    if (!$fullname) {
        Write-Host "Bitte gib einen Namen (Vor- / Nachnamen) ein!" -ForegroundColor Red
        read-fullname
    }
}

# Funktion: Benutzername abfragen

function read-username {
    $script:username = Read-Host "Benutzername"
    
    # pr�fe, ob Benutzername leer ist
    if (!$username) {
        Write-Host "Bitte gib einen Benutzernamen ein!" -ForegroundColor Red
        read-username
    
    # pr�fe, ob Benutzer schon existiert
    } else {
        $userexist = Get-LocalUser | where {$_.Name -eq $username}
        if ($userexist) {
            Write-Host "FEHLER: Der Benutzer existiert bereits auf diesem PC" -F Red
            read-username
        }
    }
}

# Funktion: Passwort generieren

    function Get-RandomCharacters($length, $characters) {
        $random = 1..$length | ForEach-Object { Get-Random -Maximum $characters.length }
        $private:ofs=""
        return [String]$characters[$random]
    }
 
    function Scramble-String([string]$inputString){     
        $characterArray = $inputString.ToCharArray()   
        $scrambledStringArray = $characterArray | Get-Random -Count $characterArray.Length     
        $outputString = -join $scrambledStringArray
        return $outputString
    }

    function get-password {
        $password = Get-RandomCharacters -length 6 -characters 'abcdefghikmnprstuvwxyz'
        $password += Get-RandomCharacters -length 3 -characters 'ABCDEFGHKLMNPRSTUVWXYZ'
        $password += Get-RandomCharacters -length 2 -characters '23456789'
        $password += Get-RandomCharacters -length 1 -characters '!"$%&()=?@#*+'
        $script:pw = Scramble-String $password
    }


# Funktion: nach Passwort fragen

    function read-password {
        $mypasswd = Read-Host "Passwort (Enter f�r automatisches generieren)"
        if (!$mypasswd) {
            get-password
        } else {
            $script:pw = $mypasswd
        }
        $script:pws = ConvertTo-SecureString -String $pw -AsPlainText -Force
    }


# Funktion: Benutzerinfo in Datei eintragen

    function write-userinfo {
        $date = Get-Date -Format dd.MM.yyyy
        $time = Get-Date -Format HH.mm.ss
        $hostname = Get-Content -path $scriptpath\hostname.tmp
        $filename = "Benutzerliste_" + $hostname + ".txt"
        echo "$fullname erstellt am $date um $time" >> $env:USERPROFILE\Desktop\$filename
        echo "Benutzername: $username" >> $env:USERPROFILE\Desktop\$filename
        echo "Passwort: $pw `n" >> $env:USERPROFILE\Desktop\$filename

        Write-Host "Der Benutzer $username ($fullname) wurde erfolgreich erstellt." -F Green
        Write-Host "Der Benutzername und das Passwort wurden in die Textdatei Benutzerliste.txt auf dem Desktop eingetragen." -F Yellow
    }


# Funktion: Frage nach weiterem Benutzer

    function ask-addmoreuser {
        $more = Read-Host "Soll ein weiterer Benutzer angelegt werden? [j/N]"
        if (($more -eq "n") -or (!$more)) {
            $script:doit = 0
            } elseif ($more -eq "j") {
            $script:doit = 1
            } else {
            Write-Host "Bitte 'j' oder 'n' eingeben (Enter f�r Nein)" -F Red
            ask-addmoreuser
        }
    }


# Funktion: Frage ob Admin-Kennwort ge�ndert werden soll?

    function ask-changeadminpw {
        $askadmin = Read-Host "Soll das Admin-Kennwort gleich ge�ndert werden? [J/n]"
        if (($askadmin -eq "j") -or (!$askadmin)) {
            $script:doit = 1
            } elseif ($askadmin -eq "n") {
            $script:doit = 0
            } else {
            Write-Host "Bitte 'j' oder 'n' eingeben (Enter f�r Ja)" -F Red
            ask-addmoreuser
        }
    }


# Firefox Pfad ermitteln

    function get-firefox {
        $mysoftware = "Firefox"
        # Pr�fe auf 32-Bit oder 64-Bit:
            $check32 = Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | where {$_.DisplayName -like "*$mysoftware*"}
            if (!$check32) {
                $check64 = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | where {$_.DisplayName -like "*$mysoftware*"}
                if (!$check64) {
                    Write-Host "FEHLER: $mysoftware ist nicht installiert" -F Red
                } else {
                    $details = $check64
                }
            } else {
                $details = $check32
            }
        # Ermittle Installationspfad
            $script:mypath = $details.InstallLocation
}


# Funktion: Script-Verzeichnis auslesen

    function Get-ScriptDirectory {
        Split-Path -parent $PSCommandPath
    }


# Funktion: Fehlercheck 

     function errorcheck {
        if ($?) {
            write-host $yeah -F Green
        } else {
            write-host $shit -F Red
            $script:errorcount = $script:errorcount + 1
        }
    }



# ---------------- Ende: Funktionen definieren ---------------------

$scriptpath = Get-ScriptDirectory

ask-adduser

while ($doit -eq 1) {

    $errorcount = 0

    # Daten abfragen / generieren

        read-fullname
        read-username
        read-password

        if ($pws) {
            Write-Host "OK: Passwort wurde automatisch generiert bzw. manuell vergeben" -F Green
        } else {
            Write-Host "FEHLER: Passwort konnte nicht generiert werden bzw. ist ung�ltig" -F Red
            $errorcount = $errorcount + 1
        }

    # User anlegen

    if (($pws) -and ($username)) {

        New-LocalUser -Name $username -FullName $fullname -Password $pws -PasswordNeverExpires | Out-Null
        if ($?) {
            write-userinfo

            # Benutzer zur Gruppe "Benutzer" hinzuf�gen
                $yeah = "OK: $fullname wurde erfolgreich zur Gruppe 'Benutzer' hinzugef�gt"
                $shit = "FEHLER: $fullname konnte nicht zur Gruppe 'Benutzer' hinzugef�gt werden"
                Add-LocalGroupMember -Name Benutzer -Member $username
                errorcheck
            
        } else {
            Write-Host "FEHLER: Benutzer konnte nicht erstellt werden." -F Red
            $errorcount = $errorcount + 1
        }

    } else {

        Write-Host "FEHLER: Kein Benutzername oder kein Passwort angegeben?!" -F Red
        Write-Host "FEHLER: Benutzer wurde nicht erstellt." -F Red
        $errorcount = $errorcount + 1
    }

    # Frage: Weiteren Benutzter anlegen?

    ask-addmoreuser
}


# Admin-Kennwort �ndern

    $username = "admin"
    $fullname = "Admin Kennwort"
    
    ask-changeadminpw
    if ($doit -eq 1) {
        
    # Passwort vergeben

        read-password

        if ($pws) {
            Write-Host "OK: Passwort wurde automatisch generiert bzw. manuell vergeben" -F Green
        } else {
            Write-Host "FEHLER: Passwort konnte nicht generiert werden bzw. ist ung�ltig" -F Red
            $errorcount = $errorcount + 1
        }
    
    # Passw�rt �ndern
        
        Set-LocalUser -Name $username -Password $pws
        if ($?) {
            write-userinfo
        } else {
            Write-Host "FEHLER: Admin-Kennwort konnte nicht ge�ndert werden." -F Red
            $errorcount = $errorcount + 1
        }
    }


# Script Ende

    del $scriptpath\hostname.tmp
    if ($errorcount -lt 1) {
    write-host "
        ENDE: Alles fertig
        Nextcloud wird per Firefox gestartet. Bitte lade hier die gerade erstellte Benutzerliste hoch.
        " -F Green
    get-firefox
    & $mypath\firefox.exe https://cloud.fa-netz.de/index.php/s/wQcTEbFGkaQgMNw

} else {
    write-host "
        ENDE: Es sind Fehler auftretreten. Bitte pr�fe das Ergebnis.
        " -F Red
}
