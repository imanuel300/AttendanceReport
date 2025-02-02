@echo off
chcp 65001 > nul
cls
setlocal EnableDelayedExpansion

set "CSV_FILE=%USERPROFILE%\Documents\attendance_log.bat.csv"

if not exist "%CSV_FILE%" (
    echo Date,Time,Action > "%CSV_FILE%"
)

:menu
cls
echo Attendance System:
echo ================
echo 1. Clock In
echo 2. Clock Out
echo 3. Edit Last Record
echo 4. Exit
echo.

set /p choice="Choose option (1-4): "

if "%choice%"=="1" (
    call :log_entry "IN"
    echo Entry recorded successfully!
    timeout /t 2 >nul
    goto menu
)
if "%choice%"=="2" (
    call :log_entry "OUT"
    echo Exit recorded successfully!
    timeout /t 2 >nul
    goto menu
)
if "%choice%"=="3" (
    call :edit_last
    timeout /t 2 >nul
    goto menu
)
if "%choice%"=="4" (
    echo Goodbye!
    timeout /t 2 >nul
    exit
)
echo Invalid option!
timeout /t 2 >nul
goto menu

:log_entry
for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /value') do set datetime=%%I
set "year=%datetime:~0,4%"
set "month=%datetime:~4,2%"
set "day=%datetime:~6,2%"
set "hour=%datetime:~8,2%"
set "minute=%datetime:~10,2%"
set "second=%datetime:~12,2%"

echo %year%-%month%-%day%,%hour%:%minute%:%second%,%~1>> "%CSV_FILE%"
exit /b

:edit_last
set "last_line="
for /f "usebackq delims=" %%a in ("%CSV_FILE%") do set "last_line=%%a"

if "%last_line%"=="" (
    echo No records to edit!
    exit /b
)

echo Last record: %last_line%
set /p new_time="Enter new time (HH:MM:SS): "

echo %new_time%| findstr /r "^[0-2][0-9]:[0-5][0-9]:[0-5][0-9]$" >nul
if errorlevel 1 (
    echo Invalid time format!
    exit /b
)

type nul > "%CSV_FILE%.tmp"
for /f "usebackq delims=" %%a in ("%CSV_FILE%") do (
    set "line=%%a"
    if "!line!"=="!last_line!" (
        for /f "tokens=1,3 delims=," %%b in ("!last_line!") do (
            echo %%b,%new_time%,%%c>> "%CSV_FILE%.tmp"
        )
    ) else (
        echo !line!>> "%CSV_FILE%.tmp"
    )
)

move /y "%CSV_FILE%.tmp" "%CSV_FILE%" >nul
echo Update successful!
exit /b 