@echo off
setlocal enabledelayedexpansion

:: Input and output files
set "INPUT=input.m3u"
set "OUTPUT=output.m3u"

:: Remove output file if it exists
if exist "%OUTPUT%" del "%OUTPUT%"

:: Write M3U header
echo #EXTM3U > "%OUTPUT%"

:: Initialize variables
set "currentLine="
set "group="

:: Loop through each line in input file
for /f "usebackq delims=" %%A in ("%INPUT%") do (
    set "currentLine=%%A"

    :: Skip empty lines
    if not "!currentLine!"=="" (

        :: If line is an EXTINF line
        if "!currentLine:~0,7!"=="#EXTINF:" (
            :: Extract group-title if present
            set "group=!currentLine!"
            for /f "tokens=1,2 delims=," %%B in ("!group!") do (
                set "linePart=%%B"
                set "titlePart=%%C"
                :: Search for group-title attribute
                set "grp=!linePart:*group-title=!"
                if "!grp!"=="!linePart!" (
                    :: No group-title, assign default
                    set "grp=Undefined"
                ) else (
                    :: Clean quotes and comma
                    set "grp=!grp:~1!"
                    for /f "tokens=1 delims=""" %%D in ("!grp!") do set "grp=%%D"
                )
            )

            :: Replace original group-title or add one
            if "!currentLine!"=="!linePart!,!titlePart!" (
                set "currentLine=#EXTINF:-1 group-title=\"!grp!\",!titlePart!"
            )
        )

        :: Write line to output
        >> "%OUTPUT%" echo !currentLine!
    )
)

echo Categorization complete! Output saved to %OUTPUT%
pause
