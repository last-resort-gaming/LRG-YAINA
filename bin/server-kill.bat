@ECHO OFF

taskkill /im arma3server.exe /f
taskkill /im arma3server_x64.exe /f
timeout /t 10
