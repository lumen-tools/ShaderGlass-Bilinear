# WinGlass

> **Unofficial fork.** WinGlass is based on [ShaderGlass](https://github.com/mausimus/ShaderGlass) 1.3.2 by mausimus, but it is **not** ShaderGlass and is not affiliated with, endorsed or supported by ShaderGlass or its author. Please report problems with WinGlass **only here** ([Issues](https://github.com/lumen-tools/WinGlass/issues)), never to ShaderGlass.

WinGlass is an overlay for running RetroArch (slang) shaders on top of the Windows desktop, a window or a capture device, with two additions:

- **Bilinear Filter** (*Processing > Bilinear Filter*): when the captured image is scaled down to the shader input (*Pixel Size*), WinGlass averages the whole area of each source pixel (n×n bilinear taps, n = 2–8 depending on the scale) instead of reading a single point. With an emulator that scales up without filtering, this gives a result close to "bilinear filtering in the emulator" and removes the mosaic pattern at non-integer pixel sizes. The shader chain itself is unchanged. With the toggle off, WinGlass processes the image like ShaderGlass 1.3.2.
- **Custom Pixel Size** (*Input > Pixel Size > Custom...*): any pixel size from 1.00 to 20.00 with two decimals (e.g. 4.65; comma or dot). It is shown in the title bar and saved in profiles.

Everything else works like ShaderGlass 1.3.2.

## Download

Get `WinGlass-<version>-win-x64.zip` from [Releases](https://github.com/lumen-tools/WinGlass/releases), unzip it and run `WinGlass.exe`. Windows 10 (2004 or newer) or Windows 11 is recommended.

WinGlass keeps its own settings (registry key `HKEY_CURRENT_USER\Software\WinGlass`) and its own default profile (`WinGlassDefault.sgp`), so it does not change the settings of an installed ShaderGlass.

## Basic use

1. **Input:** choose the desktop, a window or a capture device (*Input* menu).
2. **Pixel Size** (*Input > Pixel Size*): how many captured pixels make up one pixel of the shader input. For an emulator that shows a game at 4× choose x4; for other factors use *Custom...*.
3. **Shader:** *Shader > Choose from Library...*, or import your own `.slangp`/`.slang` with *Shader > Import custom...*.
4. **Bilinear Filter:** turn it on under *Processing* and turn bilinear filtering **off** in the emulator, otherwise the image is smoothed twice.
5. **Profiles** (*Processing > Save profile as... / Load profile...*) store input, pixel size, shader and parameters. Imported shaders are not kept in the shader list after a restart; a profile or *Shader > Recent imports* brings them back.

## Building

Visual Studio 2022 (C++ desktop workload), open `ShaderGlass.sln` and build *Release | x64*. The output is `x64\Release\WinGlass.exe`.

Releases are built by GitHub Actions (`.github/workflows/release.yml`): raising `VERSION` on `main` builds `WinGlass.exe` and `WineCap.dll` (Linux capture library for Wine/Proton) and publishes `WinGlass-<version>-win-x64.zip`.

The changes compared to ShaderGlass 1.3.2 are documented in [FORK_CHANGES.md](FORK_CHANGES.md). Source files that were changed carry a note at the top that they are not the original ShaderGlass source. Internal names (project, folder and class names such as `ShaderGlass.sln`, `ShaderGlass/`, `ShaderGlass::`) were kept to make it easier to compare with the original source.

## Credits and license

- **ShaderGlass** by mausimus, Copyright (C) 2021-2025 mausimus, GPL-3.0: WinGlass is a modified version of ShaderGlass 1.3.2. All original code, the user interface and the shader library integration are his work.
- **RetroArch / libretro slang-shaders** ([libretro/slang-shaders](https://github.com/libretro/slang-shaders)): the bundled shaders, licensed by their respective authors.
- **glslang** and **SPIRV-Cross** (Khronos Group): shader compilation.

Modifications (C) 2026 lumen-tools. WinGlass was developed with the help of Claude (AI); the modifications are provided as-is, without warranty.

Licensed under the GNU General Public License v3.0, see [LICENSE](LICENSE).
