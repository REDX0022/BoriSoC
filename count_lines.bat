@echo off
setlocal enabledelayedexpansion
set /a total=0

for /r %%f in (*.vhd) do (
    for /f "tokens=3" %%l in ('find /v /c "" "%%f"') do (
        set /a total+=%%l
    )
)
echo Total lines in all .vhd files: !total!
pause
