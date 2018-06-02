@echo off

echo === Compiling documentation ===
echo.

"C:\Program Files (x86)\Natural Docs\NaturalDocs.exe" -p "yainadoc" -i "..\client.Altis" -o HTML "..\docs" -r
pause