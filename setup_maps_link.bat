@echo off
chcp 65001 >nul

set "DEFAULT_PATH=C:\Users\%USERNAME%\Documents\EnergyCityMaps_TRI\maps"

echo ====================================
echo   設定 maps 符號連結
echo ====================================
echo.
echo 預設路徑: %DEFAULT_PATH%
echo.
set /p "MAP_PATH=請輸入 EnergyCityMaps_TRI\maps 的路徑 (按 Enter 使用預設): "

if "%MAP_PATH%"=="" set "MAP_PATH=%DEFAULT_PATH%"

if not exist "%MAP_PATH%" (
    echo.
    echo 錯誤: 路徑不存在 - %MAP_PATH%
    pause
    exit /b 1
)

echo.
echo 將建立符號連結:
echo   maps -^> %MAP_PATH%
echo.
set /p "CONFIRM=確定執行? (Y/N): "

if /i not "%CONFIRM%"=="Y" (
    echo 已取消。
    pause
    exit /b 0
)

cd /d "%~dp0"

if exist "maps" (
    echo 刪除現有的 maps...
    rmdir "maps" 2>nul || del "maps" 2>nul
)

mklink /D "maps" "%MAP_PATH%"

if %errorlevel% equ 0 (
    echo.
    echo 符號連結建立成功！
) else (
    echo.
    echo 建立失敗，請以系統管理員身分執行此腳本。
)

pause
