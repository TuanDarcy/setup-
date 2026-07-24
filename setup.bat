@echo off
setlocal EnableDelayedExpansion
title KAITUN SETUP - One-Click Installer
set "SCRIPT_BUILD=2026-07-24"

:: ===== Self-elevate to admin if needed =====
net session >nul 2>&1
if %errorLevel% neq 0 (
    powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

set "DESKTOP=%USERPROFILE%\Desktop"
set "DOWNLOADS=%USERPROFILE%\Downloads"
set "STARTUP=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup"
set "REPO_RAW=https://raw.githubusercontent.com/TuanDarcy/setup-/main"

:: Pre-define paths needed for early checks
set "VOLTX_DIR=%DOWNLOADS%\VoltX"
set "VOLTX_CONFIG=%VOLTX_DIR%\config.json"

echo.
echo  ==========================================
echo    KAITUN SETUP - One-Click Installer
echo    Build: %SCRIPT_BUILD%
echo  ==========================================
echo.

:: ===== [1] Check and Install FarmSync =====
echo [*] Checking FarmSync status...
set "FARMSYNC_KEY="
if exist "%DESKTOP%\FarmSync" (
    echo [+] FarmSync already installed - skip
) else (
    echo.
    set /p "FARMSYNC_KEY=  [>] Enter FarmSync Key (leave blank to skip): "
    if "!FARMSYNC_KEY!"=="" (
        echo [!] No key entered - FarmSync skipped
    ) else (
        echo [1/6] Installing FarmSync...
        set "FS_TEMP=%TEMP%\farmsync_install_%RANDOM%.cmd"
        (
            echo @echo off
            echo set FARMSYNC_KEY=!FARMSYNC_KEY!
            echo set FARMSYNC_URL=https://downloads.farmsync.cloud/client_web.exe
            echo set FARMSYNC_CLIENT=client_web
            echo powershell -NoProfile -ExecutionPolicy Bypass -Command "irm 'https://files.farmsync.cloud/files/install.ps1' | iex"
        ) > "!FS_TEMP!"
        start "FarmSync Install" cmd /c "!FS_TEMP!"
        echo [+] FarmSync installing in separate window...
    )
)

:: ===== [2] Ask for VoltX Credentials (skip if config already has them) =====
echo.
echo [*] Checking VoltX config...

set "VOLT_USER="
set "VOLT_PASS="

:: Check if config.json already has user/pass filled
set "CONFIG_HAS_CREDS=0"
if exist "!VOLTX_DIR!\config.json" (
    for /f "tokens=*" %%v in ('powershell -NoProfile -ExecutionPolicy Bypass -Command "$j=Get-Content '!VOLTX_DIR!\config.json' -Raw | ConvertFrom-Json; if($j.voltUser -and $j.voltPass){'YES'}else{'NO'}" 2^>nul') do if "%%v"=="YES" set "CONFIG_HAS_CREDS=1"
)
if "!CONFIG_HAS_CREDS!"=="1" (
    for /f "tokens=*" %%u in ('powershell -NoProfile -ExecutionPolicy Bypass -Command "$j=Get-Content '!VOLTX_DIR!\config.json' -Raw | ConvertFrom-Json; $j.voltUser" 2^>nul') do set "VOLT_USER=%%u"
    for /f "tokens=*" %%p in ('powershell -NoProfile -ExecutionPolicy Bypass -Command "$j=Get-Content '!VOLTX_DIR!\config.json' -Raw | ConvertFrom-Json; $j.voltPass" 2^>nul') do set "VOLT_PASS=%%p"
    echo [+] Config already has voltUser/voltPass - skip asking
) else (
    echo [*] VoltX Configuration:
    set /p "VOLT_USER=  [>] Enter VoltX Username (voltUser): "
    set /p "VOLT_PASS=  [>] Enter VoltX Password (voltPass): "
    echo [+] VoltX credentials saved
)

:: ===== [3] Download and Install SET RAM =====
echo.
echo [2/6] Checking SET RAM (monitor_ram)...

set "SETRAM_DIR=%DOWNLOADS%\SET_RAM"
set "SETRAM_EXE=%SETRAM_DIR%\dist\monitor_ram.exe"
set "SETRAM_DESKTOP_SHORTCUT=%DESKTOP%\monitor_ram.lnk"
set "SETRAM_STARTUP_SHORTCUT=%STARTUP%\monitor_ram.lnk"

if exist "!SETRAM_EXE!" (
    echo [+] monitor_ram.exe already exists - skip download
    :: Still ensure shortcuts and launch
    if not exist "!SETRAM_DESKTOP_SHORTCUT!" (
        powershell -NoProfile -ExecutionPolicy Bypass -Command "$ws=New-Object -ComObject WScript.Shell; $s=$ws.CreateShortcut('!SETRAM_DESKTOP_SHORTCUT!'); $s.TargetPath='!SETRAM_EXE!'; $s.WorkingDirectory='!SETRAM_DIR!'; $s.Description='Monitor RAM'; $s.Save()"
        echo [+] Desktop shortcut created: monitor_ram.lnk
    )
    if not exist "!SETRAM_STARTUP_SHORTCUT!" (
        powershell -NoProfile -ExecutionPolicy Bypass -Command "$ws=New-Object -ComObject WScript.Shell; $s=$ws.CreateShortcut('!SETRAM_STARTUP_SHORTCUT!'); $s.TargetPath='!SETRAM_EXE!'; $s.WorkingDirectory='!SETRAM_DIR!'; $s.Description='Monitor RAM AutoStart'; $s.Save()"
        echo [+] Startup shortcut added: monitor_ram.lnk
    )
    tasklist /fi "imagename eq monitor_ram.exe" 2>nul | find /I "monitor_ram.exe" >nul
    if errorlevel 1 (
        start "" "!SETRAM_EXE!"
        echo [+] monitor_ram.exe launched
    ) else (
        echo [+] monitor_ram.exe already running
    )
) else (
    set "SETRAM_ZIP=%DOWNLOADS%\SET_RAM.zip"
    if exist "!SETRAM_ZIP!" del /f /q "!SETRAM_ZIP!" >nul 2>&1
    echo [*] Downloading SET_RAM.zip...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Invoke-WebRequest '%REPO_RAW%/SET_RAM.zip' -OutFile '!SETRAM_ZIP!' -UseBasicParsing" 2>nul

    if exist "!SETRAM_ZIP!" (
        if exist "!SETRAM_DIR!" rmdir /s /q "!SETRAM_DIR!" >nul 2>&1
        powershell -NoProfile -ExecutionPolicy Bypass -Command "Expand-Archive -Path '!SETRAM_ZIP!' -DestinationPath '!SETRAM_DIR!' -Force"
        if exist "!SETRAM_EXE!" (
            powershell -NoProfile -ExecutionPolicy Bypass -Command "$ws=New-Object -ComObject WScript.Shell; $s=$ws.CreateShortcut('!SETRAM_DESKTOP_SHORTCUT!'); $s.TargetPath='!SETRAM_EXE!'; $s.WorkingDirectory='!SETRAM_DIR!'; $s.Description='Monitor RAM'; $s.Save()"
            echo [+] Desktop shortcut created: monitor_ram.lnk
            powershell -NoProfile -ExecutionPolicy Bypass -Command "$ws=New-Object -ComObject WScript.Shell; $s=$ws.CreateShortcut('!SETRAM_STARTUP_SHORTCUT!'); $s.TargetPath='!SETRAM_EXE!'; $s.WorkingDirectory='!SETRAM_DIR!'; $s.Description='Monitor RAM AutoStart'; $s.Save()"
            echo [+] Startup shortcut added: monitor_ram.lnk
            tasklist /fi "imagename eq monitor_ram.exe" 2>nul | find /I "monitor_ram.exe" >nul
            if errorlevel 1 (
                start "" "!SETRAM_EXE!"
                echo [+] monitor_ram.exe launched
            ) else (
                echo [+] monitor_ram.exe already running - skip
            )
        ) else (
            echo [-] monitor_ram.exe not found after extract
        )
        del /f /q "!SETRAM_ZIP!" >nul 2>&1
    ) else (
        echo [-] SET_RAM.zip download FAILED
    )
)

:: ===== [4] Download and Install VoltX =====
echo.
echo [3/6] Checking VoltX...

set "VOLTX_DIR=%DOWNLOADS%\VoltX"
set "VOLTX_HEADLESS=%VOLTX_DIR%\volt-headless-p2.exe"
set "VOLTX_CONFIG=%VOLTX_DIR%\config.json"
set "VOLTX_DESKTOP_SHORTCUT=%DESKTOP%\volt-headless-p2.lnk"
set "VOLTX_STARTUP_SHORTCUT=%STARTUP%\volt-headless-p2.lnk"

if exist "!VOLTX_HEADLESS!" (
    echo [+] volt-headless-p2.exe already exists - skip download
    :: Update config.json with credentials
    if exist "!VOLTX_CONFIG!" (
        powershell -NoProfile -ExecutionPolicy Bypass -Command "$json=Get-Content '!VOLTX_CONFIG!' -Raw | ConvertFrom-Json; $json.voltUser='!VOLT_USER!'; $json.voltPass='!VOLT_PASS!'; $json | ConvertTo-Json -Depth 4 | Set-Content '!VOLTX_CONFIG!' -Encoding UTF8"
        echo [+] config.json updated with voltUser/voltPass
    )
    :: Ensure shortcuts
    if not exist "!VOLTX_DESKTOP_SHORTCUT!" (
        powershell -NoProfile -ExecutionPolicy Bypass -Command "$ws=New-Object -ComObject WScript.Shell; $s=$ws.CreateShortcut('!VOLTX_DESKTOP_SHORTCUT!'); $s.TargetPath='!VOLTX_HEADLESS!'; $s.WorkingDirectory='!VOLTX_DIR!'; $s.Description='VoltX Headless'; $s.Save()"
        echo [+] Desktop shortcut created: volt-headless-p2.lnk
    )
    if not exist "!VOLTX_STARTUP_SHORTCUT!" (
        powershell -NoProfile -ExecutionPolicy Bypass -Command "$ws=New-Object -ComObject WScript.Shell; $s=$ws.CreateShortcut('!VOLTX_STARTUP_SHORTCUT!'); $s.TargetPath='!VOLTX_HEADLESS!'; $s.WorkingDirectory='!VOLTX_DIR!'; $s.Description='VoltX Headless AutoStart'; $s.Save()"
        echo [+] Startup shortcut added: volt-headless-p2.lnk
    )
    tasklist /fi "imagename eq volt-headless-p2.exe" 2>nul | find /I "volt-headless-p2.exe" >nul
    if errorlevel 1 (
        start "" "!VOLTX_HEADLESS!"
        echo [+] volt-headless-p2.exe launched
    ) else (
        echo [+] volt-headless-p2.exe already running
    )
) else (
    set "VOLTX_ZIP=%DOWNLOADS%\VoltX.zip"
    if exist "!VOLTX_ZIP!" del /f /q "!VOLTX_ZIP!" >nul 2>&1
    echo [*] Downloading VoltX.zip...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Invoke-WebRequest '%REPO_RAW%/VoltX.zip' -OutFile '!VOLTX_ZIP!' -UseBasicParsing" 2>nul

    if exist "!VOLTX_ZIP!" (
        if exist "!VOLTX_DIR!" rmdir /s /q "!VOLTX_DIR!" >nul 2>&1
        powershell -NoProfile -ExecutionPolicy Bypass -Command "Expand-Archive -Path '!VOLTX_ZIP!' -DestinationPath '!VOLTX_DIR!' -Force"
        if exist "!VOLTX_HEADLESS!" (
            if exist "!VOLTX_CONFIG!" (
                powershell -NoProfile -ExecutionPolicy Bypass -Command "$json=Get-Content '!VOLTX_CONFIG!' -Raw | ConvertFrom-Json; $json.voltUser='!VOLT_USER!'; $json.voltPass='!VOLT_PASS!'; $json | ConvertTo-Json -Depth 4 | Set-Content '!VOLTX_CONFIG!' -Encoding UTF8"
                echo [+] config.json updated with voltUser/voltPass
            )
            powershell -NoProfile -ExecutionPolicy Bypass -Command "$ws=New-Object -ComObject WScript.Shell; $s=$ws.CreateShortcut('!VOLTX_DESKTOP_SHORTCUT!'); $s.TargetPath='!VOLTX_HEADLESS!'; $s.WorkingDirectory='!VOLTX_DIR!'; $s.Description='VoltX Headless'; $s.Save()"
            echo [+] Desktop shortcut created: volt-headless-p2.lnk
            powershell -NoProfile -ExecutionPolicy Bypass -Command "$ws=New-Object -ComObject WScript.Shell; $s=$ws.CreateShortcut('!VOLTX_STARTUP_SHORTCUT!'); $s.TargetPath='!VOLTX_HEADLESS!'; $s.WorkingDirectory='!VOLTX_DIR!'; $s.Description='VoltX Headless AutoStart'; $s.Save()"
            echo [+] Startup shortcut added: volt-headless-p2.lnk
            tasklist /fi "imagename eq volt-headless-p2.exe" 2>nul | find /I "volt-headless-p2.exe" >nul
            if errorlevel 1 (
                start "" "!VOLTX_HEADLESS!"
                echo [+] volt-headless-p2.exe launched
            ) else (
                echo [+] volt-headless-p2.exe already running - skip
            )
        ) else (
            echo [-] volt-headless-p2.exe not found after extract
        )
        del /f /q "!VOLTX_ZIP!" >nul 2>&1
    ) else (
        echo [-] VoltX.zip download FAILED
    )
)

:: ===== [5] Download volt.exe to Desktop =====
echo.
echo [4/6] Checking volt.exe...

set "VOLT_EXE=%DESKTOP%\volt.exe"
if exist "!VOLT_EXE!" (
    echo [+] volt.exe already on Desktop - skip download
) else (
    echo [*] Downloading volt.exe...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Invoke-WebRequest '%REPO_RAW%/volt.exe' -OutFile '!VOLT_EXE!' -UseBasicParsing" 2>nul
    if exist "!VOLT_EXE!" (
        echo [+] volt.exe saved to Desktop
    ) else (
        echo [-] volt.exe download FAILED
    )
)

:: ===== [6] Download 1.1.1.1 WARP to Desktop =====
echo.
echo [5/6] Checking 1.1.1.1 WARP...

set "WARP_MSI=%DESKTOP%\Cloudflare_WARP.msi"
if exist "!WARP_MSI!" (
    echo [+] Cloudflare WARP already on Desktop - skip download
) else (
    echo [*] Downloading 1.1.1.1 WARP...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Invoke-WebRequest 'https://1111-releases.cloudflareclient.com/windows/Cloudflare_WARP_Release-x64.msi' -OutFile '!WARP_MSI!' -UseBasicParsing" 2>nul
    if exist "!WARP_MSI!" (
        echo [+] Cloudflare WARP saved to Desktop
        echo [*] Installing Cloudflare WARP silently...
        msiexec /i "!WARP_MSI!" /quiet /norestart 2>nul
        if not errorlevel 1 (
            echo [+] Cloudflare WARP installed successfully
        ) else (
            echo [!] Silent install failed - run Cloudflare_WARP.msi manually on Desktop
        )
    ) else (
        echo [!] 1.1.1.1 download FAILED - install manually later
    )
)

:: ===== [7] Wait for FarmSync (if installing) =====
echo.
echo [6/6] Checking FarmSync install status...
if not "!FARMSYNC_KEY!"=="" (
    if not exist "%DESKTOP%\FarmSync" (
        echo [*] Waiting for FarmSync installation to complete...
        set "FS_WAIT=0"
        set "FS_AUTOSTART="
        :WAIT_FARMSYNC
        powershell -NoProfile -Command "Start-Sleep -Seconds 3" >nul 2>&1
        set /a FS_WAIT+=3
        for /f "tokens=*" %%f in ('powershell -NoProfile -Command "Get-ChildItem -Path '%DESKTOP%' -Filter FarmSync_AutoStart* -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty FullName" 2^>nul') do set "FS_AUTOSTART=%%f"
        if "!FS_AUTOSTART!"=="" (
            if !FS_WAIT! LSS 300 (goto :WAIT_FARMSYNC) else (echo [!] FarmSync install timeout)
        )
        if not "!FS_AUTOSTART!"=="" (
            tasklist /fi "imagename eq client_web.exe" 2>nul | find "client_web.exe" >nul
            if not errorlevel 1 (
                echo [+] FarmSync client already running
            ) else (
                start "" "!FS_AUTOSTART!"
                echo [+] FarmSync launched
            )
        )
    ) else (
        echo [+] FarmSync already installed
    )
)

:: ===== DONE =====
echo.
echo  ==========================================
echo    KAITUN SETUP COMPLETE!
echo  ==========================================
echo.
echo  Da cai dat:
echo    [x] SET RAM (monitor_ram.exe) - Desktop + Startup + Running
echo    [x] VoltX (volt-headless-p2.exe) - Desktop + Startup + Running
echo    [x] volt.exe - Desktop
echo    [x] Cloudflare WARP - Desktop
if not "!FARMSYNC_KEY!"=="" echo    [x] FarmSync - Installed
echo.
echo  Vui long khoi dong lai may de hoan tat cai dat.
echo.
pause
exit /b 0
