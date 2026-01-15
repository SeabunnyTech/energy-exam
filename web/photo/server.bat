@echo off
start "Python HTTP Server" cmd /k "python -m http.server 8000"
start "Ngrok Tunnel" cmd /k "ngrok http 8000"
