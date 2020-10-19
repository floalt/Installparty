:: Start-Script für die Konfiguration des Benutzerprofils
:: author: flo.alt@fa-netz.de
:: https://github.com/floalt/installparty
:: ver 0.62

@echo off

SET scriptpath=%~dp0

:: ExecutionPolicy Check

powershell "Get-ExecutionPolicy" > %scriptpath%policy.tmp
set /p policy=<%scriptpath%policy.tmp
del %scriptpath%policy.tmp

IF "%policy%" EQU "Unrestricted" (
	echo "OK: ExecutionPolicy ist %policy%"

) ELSE (
	echo.
	echo "FEHLER: ExecutionPolicy muss auf Unrestricted geaendert werden..."
	echo "Dazu bitte zuerst >> party4pc.cmd << starten"
	echo "Mit rechter Maustaste => Als Administrator ausfuehren anklicken"
	echo.
	pause
	exit
)

:: Start Scripts

powershell "%scriptpath%scripts\configure-me.ps1"
powershell "%scriptpath%scripts\firefoxaddon.ps1"

pause
