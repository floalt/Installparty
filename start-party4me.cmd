:: Start-Script für configure-me.ps1
:: ver 0.61

@echo off

SET scriptpath=%~dp0

:: ExecutionPolicy Check

powershell "Get-ExecutionPolicy" > %scriptpath%policy.tmp
set /p policy=<%scriptpath%policy.tmp
del %scriptpath%policy.tmp

IF "%policy%" EQU "Unrestricted" (
	echo "OK: ExecutionPolicy ist bereits %policy%"

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

powershell "%scriptpath%configure-me.ps1"
powershell "%scriptpath%firefoxaddon.ps1"

pause