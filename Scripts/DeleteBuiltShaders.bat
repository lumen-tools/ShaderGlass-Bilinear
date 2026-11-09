@echo off
rem Modified for WinGlass by lumen-tools, 2026: this file is NOT the original ShaderGlass source.
rem WinGlass is an unofficial fork of ShaderGlass: https://github.com/lumen-tools/WinGlass
echo This script will delete all prebuilt shaders from WinGlass.
echo,
pause
del /q ..\ShaderGlass\Shaders\RetroArch.h
rmdir /s /q ..\ShaderGlass\Shaders\RetroArch
rmdir /s /q temp
