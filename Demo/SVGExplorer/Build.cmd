@echo off
rem Builds the SVGExplorer demo (Win32 -> Demo\Bin, Win64 -> Demo\Bin64).
rem Optional argument: RAD Studio install path (default C:\BDS\Studio\37.0).
call "%~dp0..\Build.cmd" SVGExplorer %1
