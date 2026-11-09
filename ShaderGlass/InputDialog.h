/*
ShaderGlass: shader effect overlay
Copyright (C) 2021-2025 mausimus (mausimus.net)
https://github.com/mausimus/ShaderGlass
GNU General Public License v3.0

Modified for WinGlass by lumen-tools, 2026: this file is NOT the original ShaderGlass source.
WinGlass is an unofficial fork of ShaderGlass: https://github.com/lumen-tools/WinGlass
*/

#pragma once

class InputDialog
{
public:
    InputDialog(HINSTANCE hInstance, HWND mainWindow);

    float GetInput(const std::string& label, float existing, int decimals = -1);

private:
    HINSTANCE m_instance;
    HWND      m_mainWindow;
};