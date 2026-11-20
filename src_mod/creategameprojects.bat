@echo off
rem ---------------------------------------------------------------------------
rem  HL2 -> games.sln
rem
rem  Only what is needed to build the Half-Life 2 game binaries (client.dll and server.dll):
rem    - Client (HL2), Server (HL2)     (/hl2 only - NOT the SDK template mod)
rem    - vgui_controls (static library that the client links against)
rem  = 3 projects. Same idea as Valve's 2013 "vpc /hl2 /episodic +game /mksln games.sln".
rem
rem  For every SDK project (tools and both games) run createallprojects.bat.
rem ---------------------------------------------------------------------------
pushd "%~dp0"
devtools\bin\vpc.exe /hl2 /2013 +game /mksln games.sln
set VPC_RESULT=%ERRORLEVEL%
popd
if not "%VPC_RESULT%"=="0" echo.
if not "%VPC_RESULT%"=="0" echo *** VPC FAILED ^(error %VPC_RESULT%^). Copy the messages above and send them over. ***
if /i not "%1"=="nopause" pause
exit /b %VPC_RESULT%
