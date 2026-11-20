@echo off
rem ---------------------------------------------------------------------------
rem  EVERYTHING -> everything.sln
rem
rem  Every project of the original 2004 SDK solutions (Everything_SDK.sln, Game_HL2.sln, Game_SDK.sln):
rem    - the SDK tools: glview, height2normal, serverplugin_empty, studiomdl, tgadiff, vbsp, vice,
rem      vprojtomake, vrad, vrad_launcher, vtf2tga, vtfdiff, vvis, vvis_launcher, xwad
rem    - vgui_controls (static library)
rem    - Client + Server for BOTH games: HL2 and the SDK template mod   (/hl2 /sdk)
rem  = 20 projects. Same idea as Valve's 2013 "vpc /hl2 /episodic +everything /mksln everything.sln".
rem
rem  For only the projects needed to build the HL2 game binaries run creategameprojects.bat.
rem ---------------------------------------------------------------------------
pushd "%~dp0"
devtools\bin\vpc.exe /hl2 /sdk /2013 +everything /mksln everything.sln
set VPC_RESULT=%ERRORLEVEL%
popd
if not "%VPC_RESULT%"=="0" echo.
if not "%VPC_RESULT%"=="0" echo *** VPC FAILED ^(error %VPC_RESULT%^). Copy the messages above and send them over. ***
if /i not "%1"=="nopause" pause
exit /b %VPC_RESULT%
