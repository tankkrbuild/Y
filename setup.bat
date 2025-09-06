@echo off
setlocal enabledelayedexpansion

:: ===== Konfigurasi =====
set VNC_PASSWORD=123456
set VNC_URL=https://www.tightvnc.com/download/2.8.81/tightvnc-2.8.81-gpl-setup-64bit.msi
set NOVNC_URL=https://github.com/novnc/noVNC/archive/refs/heads/master.zip
set WORKDIR=C:\novnc_setup

:: Buat folder kerja
if not exist %WORKDIR% mkdir %WORKDIR%
cd /d %WORKDIR%

echo === [1/6] Download & Install TightVNC ===
if not exist tightvnc.msi (
    curl -L -o tightvnc.msi %VNC_URL%
)
msiexec /i tightvnc.msi /quiet /norestart ADDLOCAL=Server

echo === [2/6] Set Password VNC ===
:: Convert password ke HEX manual (contoh: 123456 -> 313233343536)
:: NOTE: ganti HEX kalau ubah password
reg add "HKLM\SOFTWARE\TightVNC\Server" /v Password /t REG_BINARY /d 313233343536 /f

echo === [3/6] Start VNC Service ===
sc config tvnserver start= auto
sc start tvnserver

echo === [4/6] Install Python pip websockify ===
pip install websockify

echo === [5/6] Download & Extract noVNC ===
if not exist noVNC.zip (
    curl -L -o noVNC.zip %NOVNC_URL%
)
tar -xf noVNC.zip
if exist noVNC-master (
    ren noVNC-master noVNC
)

echo === [6/6] Jalankan noVNC Proxy ===
cd noVNC
start cmd /k python utils\novnc_proxy --vnc localhost:5900

echo.
echo === SETUP SELESAI ===
echo Akses noVNC via: http://%COMPUTERNAME%:6080/vnc.html
echo Password VNC: %VNC_PASSWORD%
pause