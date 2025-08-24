@echo off
REM Enables the use of !variable! to get the current value inside a loop
setlocal enabledelayedexpansion

REM ===========================================
REM ==               CHECK IF FIREFOX IS RUNNING                   ==
REM ===========================================
:CHECK_FIREFOX
echo Checking if Firefox is running...
tasklist /FI "IMAGENAME eq firefox.exe" 2>NUL | find /I /N "firefox.exe" > NUL

REM If errorlevel is 0, the process was found
if "%errorlevel%"=="0" (
    echo.
    echo WARNING: Firefox is currently running.
    echo Please close it completely before continuing to avoid corrupting the backup.
    echo.
    set /p "CHOICE=Have you closed Firefox and are ready to proceed? (Y to continue, N to exit): "
    
    REM Check user's choice (case-insensitive)
    if /i "!CHOICE!"=="Y" (
        echo Re-checking...
        goto :CHECK_FIREFOX
    )
    if /i "!CHOICE!"=="N" (
        echo Backup aborted by user.
        pause
        goto :eof
    )
    
    REM Handle invalid input
    echo Invalid choice. Please enter Y or N.
    goto :CHECK_FIREFOX
)

echo Firefox is not running. Proceeding with backup...
echo.

REM ==============================================
REM ==                BACKUP AND CLEANUP LOGIC                     ==
REM ==============================================
REM Backup each Firefox profile separately using PowerShell
REM Keeps only the 2 most recent backups per profile

REM === CONFIGURATION ===
set PROFILEFOLDER=C:\Users\photo\AppData\Roaming\Mozilla\Firefox\Profiles
set BACKUPDIR=D:\Data\Backups\Firefox

REM Create backup directory if it doesn't exist
if not exist "%BACKUPDIR%" mkdir "%BACKUPDIR%"

REM Get date in YYYY-MM-DD format
for /f "tokens=2 delims==" %%I in ('wmic os get LocalDateTime /value ^| find "="') do set dt=%%I
set DATESTR=%dt:~0,4%-%dt:~4,2%-%dt:~6,2%

REM Loop through each profile folder
for /D %%D in ("%PROFILEFOLDER%\*") do (
    REM Set the zip file name for the current profile in the loop
    set "ZIPFILE=%BACKUPDIR%\%%~nD-%DATESTR%.zip"

    REM Use PowerShell to compress the folder
    REM IMPORTANT: Use !ZIPFILE! here instead of %ZIPFILE% to get the updated path for each profile
    powershell -Command "Compress-Archive -Path '%%D\*' -DestinationPath '!ZIPFILE!' -Force"

    REM Delete older backups, keep only 2 most recent per profile
    REM  %%~nD is a loop variable, not an environment variable
    for /f "skip=2 delims=" %%F in ('dir /b /o-d "%BACKUPDIR%\%%~nD-*.zip"') do del "%BACKUPDIR%\%%F"
)

echo All profile backups completed.
pause
