@echo off
chcp 65001 > nul
cls
setlocal EnableDelayedExpansion

:: הגדרת נתיב לקובץ CSV
set "CSV_FILE=%USERPROFILE%\Documents\attendance_log.bat.csv"

:: יצירת קובץ אם לא קיים
if not exist "%CSV_FILE%" (
    echo תאריך,שעה,סוג פעולה > "%CSV_FILE%"
)

:menu
cls
echo מערכת דיווח נוכחות:
echo ==================
echo 1. כניסה לעבודה
echo 2. יציאה מהעבודה
echo 3. תיקון דוח אחרון
echo 4. יציאה מהתוכנה
echo.

set /p choice="בחר אפשרות (1-4): "

if "%choice%"=="1" (
    call :log_entry "כניסה"
    echo כניסה נרשמה בהצלחה!
    timeout /t 2 >nul
    goto menu
)
if "%choice%"=="2" (
    call :log_entry "יציאה"
    echo יציאה נרשמה בהצלחה!
    timeout /t 2 >nul
    goto menu
)
if "%choice%"=="3" (
    call :edit_last
    timeout /t 2 >nul
    goto menu
)
if "%choice%"=="4" (
    echo להתראות!
    timeout /t 2 >nul
    exit
)
echo אפשרות לא תקינה!
timeout /t 2 >nul
goto menu

:log_entry
:: קבלת תאריך ושעה נוכחיים
for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /value') do set datetime=%%I
set "year=%datetime:~0,4%"
set "month=%datetime:~4,2%"
set "day=%datetime:~6,2%"
set "hour=%datetime:~8,2%"
set "minute=%datetime:~10,2%"
set "second=%datetime:~12,2%"

:: הוספת רשומה לקובץ
echo %year%-%month%-%day%,%hour%:%minute%:%second%,%~1>> "%CSV_FILE%"
exit /b

:edit_last
:: קריאת השורה האחרונה
set "last_line="
for /f "delims=" %%a in ('type "%CSV_FILE%"') do set "last_line=%%a"

if "%last_line%"=="" (
    echo אין רשומות לעריכה!
    exit /b
)

:: הצגת הרשומה האחרונה
echo הרשומה האחרונה: %last_line%

:: קבלת שעה חדשה
set /p new_time="הכנס שעה חדשה (בפורמט HH:MM:SS): "

:: בדיקת פורמט השעה
echo %new_time%| findstr /r "^[0-2][0-9]:[0-5][0-9]:[0-5][0-9]$" >nul
if errorlevel 1 (
    echo פורמט שעה לא תקין!
    exit /b
)

:: עדכון הקובץ
set "temp_file=%CSV_FILE%.tmp"
set "skip_last=0"
for /f "delims=" %%a in ('type "%CSV_FILE%"') do (
    set "current_line=%%a"
    if "!skip_last!"=="0" (
        if "!current_line!"=="!last_line!" (
            for /f "tokens=1,3 delims=," %%b in ("!last_line!") do (
                echo %%b,%new_time%,%%c>> "!temp_file!"
            )
            set "skip_last=1"
        ) else (
            echo !current_line!>> "!temp_file!"
        )
    )
)

move /y "%temp_file%" "%CSV_FILE%" >nul
echo העדכון בוצע בהצלחה!
exit /b 