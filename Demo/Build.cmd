@echo off
rem ============================================================================
rem  Build.cmd - Generic build script for the SVGIconImageList demos
rem ----------------------------------------------------------------------------
rem  Builds a demo project (Release configuration) for the platform chosen
rem  interactively: Win64 (default), Win32, or Both.
rem
rem  Output:
rem     Win32 executable  ->  Demo\Bin
rem     Win64 executable  ->  Demo\Bin64
rem
rem  Usage:
rem     Build.cmd <ProjectName> [DelphiPath]
rem
rem        <ProjectName>  name of the demo (folder and .dproj share this name),
rem                       e.g. SVGExplorer, SvgViewer, Benchmark
rem        [DelphiPath]   optional RAD Studio install folder. If omitted the
rem                       DELPHI_PATH environment variable is used, otherwise
rem                       the default below.
rem
rem  The Delphi path and the target platform are proposed and asked
rem  interactively. The default Delphi path can also be changed by editing the
rem  line below or by setting the DELPHI_PATH environment variable.
rem ============================================================================
setlocal enableextensions

rem ---- Default Delphi (RAD Studio) installation path -------------------------
set "DEFAULT_DELPHI_PATH=C:\BDS\Studio\37.0"

rem ---- Resolve the proposed Delphi path: arg 2 > DELPHI_PATH env var > default
set "RSPATH=%~2"
if "%RSPATH%"=="" set "RSPATH=%DELPHI_PATH%"
if "%RSPATH%"=="" set "RSPATH=%DEFAULT_DELPHI_PATH%"

rem ---- Ask the user to confirm or change the Delphi path ---------------------
rem  (the proposed value is shown; press ENTER to accept it or type another one)
echo.
echo Delphi (RAD Studio) installation path - press ENTER to accept the proposal.
set /p "RSPATH=Delphi path [%RSPATH%]: "

rem ---- Ask the user for the target platform ----------------------------------
echo.
echo Target platform:
echo   [1] Win64  (default)
echo   [2] Win32
echo   [3] Both (Win32 + Win64)
set "PLATFORMCHOICE=1"
set /p "PLATFORMCHOICE=Choose 1-3 [1]: "

set "DO32="
set "DO64="
set "PLATFORMLABEL="
if "%PLATFORMCHOICE%"=="1" set "PLATFORMLABEL=Win64"
if "%PLATFORMCHOICE%"=="2" set "PLATFORMLABEL=Win32"
if "%PLATFORMCHOICE%"=="3" set "PLATFORMLABEL=Win32 + Win64"
if not defined PLATFORMLABEL (
    echo ERROR: invalid platform choice "%PLATFORMCHOICE%" ^(expected 1, 2 or 3^).
    exit /b 1
)
if "%PLATFORMCHOICE%"=="1" set "DO64=1"
if "%PLATFORMCHOICE%"=="2" set "DO32=1"
if "%PLATFORMCHOICE%"=="3" set "DO32=1"
if "%PLATFORMCHOICE%"=="3" set "DO64=1"

rem ---- Resolve the project ---------------------------------------------------
set "PROJECTNAME=%~1"
if "%PROJECTNAME%"=="" (
    echo ERROR: missing project name.
    echo Usage: Build.cmd ^<ProjectName^> [DelphiPath]
    exit /b 1
)

set "DEMOROOT=%~dp0"
set "DPROJ=%DEMOROOT%%PROJECTNAME%\%PROJECTNAME%.dproj"

if not exist "%DPROJ%" (
    echo ERROR: project not found: %DPROJ%
    exit /b 1
)

if not exist "%RSPATH%\bin\rsvars.bat" (
    echo ERROR: rsvars.bat not found in "%RSPATH%\bin"
    echo Check the Delphi path ^(default %DEFAULT_DELPHI_PATH%^).
    exit /b 1
)

rem ---- Setup the RAD Studio command-line environment -------------------------
call "%RSPATH%\bin\rsvars.bat"

echo ============================================================
echo  Building %PROJECTNAME%  (Release, %PLATFORMLABEL%)
echo  Delphi : %RSPATH%
echo ============================================================

if defined DO32 call :build Win32 "%DEMOROOT%Bin" || exit /b 1
if defined DO64 call :build Win64 "%DEMOROOT%Bin64" || exit /b 1

echo.
echo === DONE: %PROJECTNAME% built for %PLATFORMLABEL% ===
endlocal
goto :eof

rem ============================================================================
rem  :build  <Platform>  "<OutputDir>"
rem ----------------------------------------------------------------------------
rem  Compiles the project for one platform, writing the executable to OutputDir.
rem ============================================================================
:build
echo.
echo --- %~1 -^> %~2 ---
msbuild "%DPROJ%" /t:Build /p:Config=Release /p:Platform=%~1 /p:DCC_ExeOutput="%~2" /nologo /v:minimal
if errorlevel 1 (
    echo.
    echo *** BUILD FAILED: %PROJECTNAME% %~1 ***
    exit /b 1
)
exit /b 0
