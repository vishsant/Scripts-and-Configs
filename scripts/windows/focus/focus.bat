@echo off
REM ─────────────────────────────────────────────────────────────────────────────
REM   focus.bat
REM   Usage: focus.bat "YourFocusText"
REM   If no argument is given, prompts you.
REM   Updates HKCU\Control Panel\International\sShortTime
REM   Broadcasts WM_SETTINGCHANGE so the tray clock updates instantly.
REM ─────────────────────────────────────────────────────────────────────────────

setlocal EnableExtensions EnableDelayedExpansion

:: 1) Get your focus
if "%~1"=="" (
    set /p "FOCUS=What's your current focus? "
) else (
    set "FOCUS=%~1"
)

:: 2) Build the NEW_FMT string:
::    - h:mm tt         → 12-hour clock + AM/PM
::    - ' Focus: …'     → literal text in single quotes
if defined FOCUS (
    set "NEW_FMT=h:mm tt ' Focus: !FOCUS!'"
) else (
    set "NEW_FMT=h:mm tt"
)

:: 3) Verify the registry key exists
reg query "HKCU\Control Panel\International" /v sShortTime >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Could not find registry key. Aborting.
    goto :EOF
)

:: 4) Write the new format
reg add "HKCU\Control Panel\International" /v sShortTime /t REG_SZ /d "%NEW_FMT%" /f >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Failed to update registry. Aborting.
    goto :EOF
)

echo [OK] Focus set to: %FOCUS%

:: 5) Build the tiny PowerShell broadcaster script
set "PSFILE=%TEMP%\FocusBroadcast.ps1"

rem — overwrite with the P/Invoke signature
> "%PSFILE%" echo Add-Type -Name NativeMethods -Namespace Win32 -MemberDefinition "[System.Runtime.InteropServices.DllImport(\"user32.dll\",SetLastError=true)] public static extern System.IntPtr SendMessageTimeout(System.IntPtr hWnd, uint Msg, System.UIntPtr wParam, string lParam, uint Flags, uint Timeout, out System.UIntPtr result);"

rem — append the call into the same file
>> "%PSFILE%" echo [void][Win32.NativeMethods]::SendMessageTimeout([System.IntPtr]::Zero,0x001A,[System.UIntPtr]::Zero,'intl',0x0002,100,[ref]([System.UIntPtr]::Zero))

:: 6) Run it
powershell -NoProfile -ExecutionPolicy Bypass -File "%PSFILE%" >nul 2>&1
if errorlevel 1 (
    echo [WARN] Could not broadcast WM_SETTINGCHANGE. You may need to restart Explorer.
) else (
    echo [DONE] Broadcast sent. Your taskbar clock should refresh momentarily.
)

:: 7) Clean up
del "%PSFILE%" >nul 2>&1

endlocal
