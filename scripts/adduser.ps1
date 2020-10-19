<#

    Lokale Benutzerkonten anlegen
    wird bei PCs angewandt, die nicht in einer Domäne verwaltet werden
    Aufruf durch start-party4pc.cmd
    version: 0.7


#>


Write-Host "INFO: Beginne mit Konfiguration von Benutzern & Kennwörter" -F Yellow
$global:steps = $global:steps + 1
if ($pwdfile) {Remove-Variable pwdfile}


# ---------------- Start: Funktionen definieren ---------------------

# Funktion: Frage ob Benutzer angelegt werden sollen

function ask-adduser {
    $letsdoit = Read-Host "Soll(en) jetzt ein oder mehrere Benutzer angelegt werden? [J/n]"
    if (($letsdoit -eq "j") -or (!$letsdoit)) {
            $script:doit = 1
            } elseif ($letsdoit -eq "n") {
            $script:doit = 0
            } else {
            Write-Host "Bitte 'j' oder 'n' eingeben (Enter für Ja)" -F Red
            ask-adduser
        }
}

# Funktion: Vollständiger Name abfragen

function read-fullname {
    $script:fullname = Read-Host "Vollständiger Name"
    # prüfe, ob Benutzername leer ist
    if (!$fullname) {
        Write-Host "Bitte gib einen Namen (Vor- / Nachnamen) ein!" -ForegroundColor Red
        read-fullname
    }
}

# Funktion: Benutzername abfragen

function read-username {
    $script:username = Read-Host "Benutzername"

    # prüfe, ob Benutzername leer ist
    if (!$username) {
        Write-Host "Bitte gib einen Benutzernamen ein!" -ForegroundColor Red
        read-username

    # prüfe, ob Benutzer schon existiert
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
        $mypasswd = Read-Host "Passwort (Enter für automatisches generieren)"
        if (!$mypasswd) {
            get-password
        } else {
            $script:pw = $mypasswd
        }
        $script:pws = ConvertTo-SecureString -String $pw -AsPlainText -Force
    }


# Funktion: nach Passwort fragen (nur für Admins von Business-PCs)

    function read-adminpassword {
        $mypasswd = Read-Host "Passwort"
        if (!$mypasswd) {
            Write-Host "Bitte gib ein Passwort ein!" -F Red
            read-adminpassword
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
        Write-Host "Der Benutzername und das Passwort wurden in die Textdatei $filename auf dem Desktop eingetragen." -F Yellow
        $script:pwdfile = 1
    }


# Funktion: Frage nach weiterem Benutzer

    function ask-addmoreuser {
        $more = Read-Host "Soll ein weiterer Benutzer angelegt werden? [j/N]"
        if (($more -eq "n") -or (!$more)) {
            $script:doit = 0
            } elseif ($more -eq "j") {
            $script:doit = 1
            } else {
            Write-Host "Bitte 'j' oder 'n' eingeben (Enter für Nein)" -F Red
            ask-addmoreuser
        }
    }


# Funktion: Frage ob Admin-Kennwort geändert werden soll?

    function ask-changeadminpw {
        $askadmin = Read-Host "Soll das Admin-Kennwort gleich geändert werden? [J/n]"
        if (($askadmin -eq "j") -or (!$askadmin)) {
            $script:doit = 1
            } elseif ($askadmin -eq "n") {
            $script:doit = 0
            } else {
            Write-Host "Bitte 'j' oder 'n' eingeben (Enter für Ja)" -F Red
            ask-changeadminpw
        }
    }


# Firefox Pfad ermitteln

    function check-firefox {
        $mysoftware = "Firefox"
        # Prüfe auf 32-Bit oder 64-Bit:
            $check32 = Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | where {$_.DisplayName -like "*$mysoftware*"}
            if (!$check32) {
                $check64 = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | where {$_.DisplayName -like "*$mysoftware*"}
                if (!$check64) {
                    Write-Host "FEHLER: $mysoftware ist nicht installiert" -F Red
                    $script:firefox = 0
                } else {
                    $details = $check64
                }
            } else {
                $details = $check32
            }
        # Ermittle Installationspfad
            $script:mypath = $details.InstallLocation
}



# ---------------- Ende: Funktionen definieren ---------------------

$scriptpath = Get-ScriptDirectory


# neuen lokalen Benutzer anlegen

    if ($global:kindof -eq "privat") {

        ask-adduser

        while ($doit -eq 1) {

            # Daten abfragen / generieren

                read-fullname
                read-username
                read-password

                if ($pws) {
                    Write-Host "OK: Passwort wurde automatisch generiert bzw. manuell vergeben" -F Green
                } else {
                    Write-Host "FEHLER: Passwort konnte nicht generiert werden bzw. ist ungültig" -F Red
                    $global:errorcount = $global:errorcount + 1
                }

            # User anlegen

            if (($pws) -and ($username)) {

                New-LocalUser -Name $username -FullName $fullname -Password $pws -PasswordNeverExpires | Out-Null
                if ($?) {
                    write-userinfo

                    # Benutzer zur Gruppe "Benutzer" hinzufügen
                        $yeah = "OK: $fullname wurde erfolgreich zur Gruppe 'Benutzer' hinzugefügt"
                        $shit = "FEHLER: $fullname konnte nicht zur Gruppe 'Benutzer' hinzugefügt werden"
                        Add-LocalGroupMember -Name Benutzer -Member $username
                        errorcheck

                } else {
                    Write-Host "FEHLER: Benutzer konnte nicht erstellt werden." -F Red
                    $global:errorcount = $global:errorcount + 1
                }

            } else {

                Write-Host "FEHLER: Kein Benutzername oder kein Passwort angegeben?!" -F Red
                Write-Host "FEHLER: Benutzer wurde nicht erstellt." -F Red
                $global:errorcount = $global:errorcount + 1
            }

            # Frage: Weiteren Benutzter anlegen?

            ask-addmoreuser
        }
    }

# Admin-Kennwort ändern

    $username = "admin"
    $fullname = "Admin Kennwort"

    ask-changeadminpw
    if ($doit -eq 1) {

    # Passwort vergeben

        # Bei Privat-PC mit Option Passwort genrerieren

        if ($global:kindof -eq "privat") {

            read-password

            if ($pws) {
                Write-Host "OK: Passwort wurde automatisch generiert bzw. manuell vergeben" -F Green
            } else {
                Write-Host "FEHLER: Passwort konnte nicht generiert werden bzw. ist ungültig" -F Red
                $global:errorcount = $global:errorcount + 1
            }

        # Bei Business-PC ohne Passwort generieren

        } else {

            read-adminpassword

            if ($pws) {
                Write-Host "OK: Admin-Kennwort wird geändert..." -F Green
            } else {
                Write-Host "FEHLER: Passwort konnte nicht vergeben werden bzw. ist ungültig" -F Red
                $global:errorcount = $global:errorcount + 1
            }
        }

    # Passwört ändern

        Set-LocalUser -Name $username -Password $pws
        if ($?) {
            Write-Host "OK: Admin-Kennwort wurde geändert" -F Green
            write-userinfo
         } else {
            Write-Host "FEHLER: Admin-Kennwort konnte nicht geändert werden." -F Red
            $global:errorcount = $global:errorcount + 1
        }
    }


# Passwortliste

    if ($global:kindof -eq "privat") {
        del $scriptpath\hostname.tmp

        if ($pwdfile -eq 1) {

            # Prüfe, ob Firefox installiert ist: installire oder starte Firefox
            check-firefox
            if ($script:firefox -eq 0) {
                Write-Host "Ohne Firefox kann die Passwort-Datei nicht in die Nextcloud hochgeladen werden" -F Red
                write-Host "Offensichtlich ist noch keine Software installiert worden. Das ist nicht gut..." -F Yellow
                $question =  "Möchtest du das jetzt nachholen?"
                ask-yesno $question
                if ($doit -eq 1) {
                    & $Global:scriptpath/install-apps.ps1
                } else {
                    Write-Host "Achtung: Die Passwortliste wird NICHT in die Nextcloud hochgeladen." -F Red
                    Write-Host "Sorge dafür, dass du das Admin-Passwort kennst!" -F Red
                }
            } else {
                Write-Host "
                Nextcloud wird per Firefox gestartet. Bitte lade hier die gerade erstellte Benutzerliste hoch.
                " -F Yellow
                $script:firefox = "done"
                & $mypath\firefox.exe https://cloud.fa-netz.de/index.php/s/wQcTEbFGkaQgMNw
            }
        }
    }

    if (($global:kindof -eq "privat") -and ($pwdfile -eq 1) -and ($script:firefox -ne "done")) {
        check-firefox
        Write-Host "
        Nextcloud wird per Firefox gestartet. Bitte lade hier die gerade erstellte Benutzerliste hoch.
        " -F Yellow
        & $mypath\firefox.exe https://cloud.fa-netz.de/index.php/s/wQcTEbFGkaQgMNw
    }

# E N D E

Write-Host "FERTIG: Konfiguration von Benutzern und Kennwörtern abgeschlossen" -F Green
