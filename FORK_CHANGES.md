# WinGlass: Änderungen gegenüber ShaderGlass

Basis: **ShaderGlass v1.3.2** von mausimus (Tag `v1.3.2`, Commit `c9001490`).

WinGlass ist ein inoffizieller, umbenannter Fork. Er fügt genau zwei Funktionen hinzu:

1. **Bilinear Filter**: Schalter unter *Processing*
2. **Custom Pixel Size**: freie Pixel Size mit 2 Nachkommastellen unter *Input → Pixel Size → Custom...*

Dazu kommt die Umbenennung zu WinGlass (Abschnitt 3), wie von mausimus für öffentliche Forks gewünscht. Alles andere ist Original-ShaderGlass. Die Datei beschreibt die Änderungen so genau, dass man sie in eine neuere ShaderGlass-Version wieder einbauen kann.

---

## Neue ShaderGlass-Version übernehmen (Anleitung, auch für eine KI)

**Ziel:** Neuerungen von mausimus übernehmen, ohne die beiden WinGlass-Funktionen und die Umbenennung zu verlieren. Die WinGlass-Funktionen haben Vorrang. Was mausimus neu baut, wird übernommen, solange es nicht mit ihnen kollidiert.

### Weg A (empfohlen): Git-Merge

Die WinGlass-Historie enthält die Original-Historie von ShaderGlass bis v1.3.2 (Commit `c9001490`). Ein neuer ShaderGlass-Tag lässt sich deshalb direkt mergen. Git kennt die gemeinsame Basis und muss nur die Unterschiede zusammenführen.

```bash
git remote add upstream https://github.com/mausimus/ShaderGlass
```

```bash
git fetch upstream --tags
```

```bash
git checkout -b update-shaderglass-X main
```

```bash
git merge vX.Y.Z
```

`vX.Y.Z` ist der neue Tag von mausimus.

**Konflikte so auflösen:**

| Datei | Regel |
|---|---|
| `ShaderGlass/ShaderGlass.rc` | UTF-16, Git kann sie **nicht** zusammenführen. Die Version von mausimus nehmen (`git checkout --theirs ShaderGlass/ShaderGlass.rc`) und dann alle WinGlass-Änderungen aus Abschnitt 1, 2 und 3 erneut eintragen, Textvergleich mit `iconv -f UTF-16 -t UTF-8`. Beim Schreiben UTF-16 LE mit BOM und CRLF beibehalten. |
| `ShaderGlass/ShaderWindow.cpp`, `ShaderGlass.cpp`, `ShaderPass.cpp`, `CaptureManager.*`, `InputDialog.*`, `resource.h` | Beide Seiten behalten: Neuerungen von mausimus übernehmen, WinGlass-Code laut Abschnitt 1–3 erhalten. |
| `README.md`, `Misc/README.txt`, `.github/workflows/*` | **Immer die WinGlass-Version behalten.** Upstream-Workflows `build.yml` und `build-winecap.yml` nicht wieder hinzufügen. |
| Von WinGlass gelöscht (`images/`, `FAQ.md`, `Misc/MANUAL.*`, `.github/FUNDING.yml`, `.github/CONTRIBUTING.md`, `ShaderGlass.ico`, `small.ico`) | **Gelöscht lassen** (`git rm`), auch wenn mausimus sie geändert hat. |
| Neue Dateien von mausimus | Übernehmen. Wenn sie sichtbare Texte, Links oder Doku von ihm enthalten, nach Abschnitt 3 umbenennen oder weglassen. |

### Weg B (Notlösung): Patches

Im Ordner `fork-patches/` liegen die beiden Funktionen als Patch gegen v1.3.2:

| Datei | Inhalt |
|---|---|
| `1-bilinear-filter.patch` | Bilinear Filter (inklusive Korrektur der Menüpositionen) |
| `2-custom-pixel-size.patch` | Custom Pixel Size (setzt Patch 1 voraus, wegen `resource.h`) |

```bash
git apply --3way fork-patches/1-bilinear-filter.patch
```

```bash
git apply --3way fork-patches/2-custom-pixel-size.patch
```

`ShaderGlass.rc` ist nicht enthalten (UTF-16) und die Umbenennung auch nicht. Beides von Hand nach Abschnitt 1–3.

### Nach jedem Update prüfen (Checkliste)

1. **Funktionen vollständig:** alle Punkte aus Abschnitt 1 und 2 vorhanden, insbesondere `ApplyBilinear()`/`CreateFootprintShader()` in `ShaderGlass.cpp`, `SetPixelShaderOverride`/`CreateSamplers` in `ShaderPass.cpp`, `IDM_PIXELSIZE_CUSTOM` in `ShaderWindow.cpp`.
2. **Menü-IDs:** `ID_PROCESSING_BILINEARFILTER` und `IDM_PIXELSIZE_CUSTOM` kollidieren nicht mit neuen IDs von mausimus in `resource.h`. Sonst neue freie IDs vergeben und `_APS_NEXT_COMMAND_VALUE` anpassen.
3. **Menüpositionen:** Die Reihenfolge im Processing-Menü der neuen `ShaderGlass.rc` mit den Zahlen in `ShaderWindow::BuildProgramMenu()` abgleichen (`GetSubMenu(m_programMenu, N)`, `InsertMenu(m_programMenu, N, ...)`, `EnableMenuItem(m_programMenu, N, MF_BYPOSITION ...)`). „Bilinear Filter“ verschiebt alles danach um +1. **Häufigste Fehlerquelle**, Symptom: Häkchen bei GPU/FPS/Advanced fehlen, Klicks schalten Optionen aus.
4. **Umbenennung vollständig.** Diese Suchen dürfen außer den erlaubten Stellen nichts finden:
   - sichtbare Texte: `git grep -n '"[^"]*ShaderGlass' -- 'ShaderGlass/*.cpp' 'ShaderGlass/*.h' 'WineCap/*.c'` (Ausnahme `#include "ShaderGlass.h"`)
   - Ressourcen: `iconv -f UTF-16 -t UTF-8 ShaderGlass/ShaderGlass.rc | grep -n -i "shaderglass\|mausimus"` (erlaubt: `IDI_SHADERGLASS`, `IDC_SHADERGLASS`, „Unofficial fork of ShaderGlass … by mausimus“, Copyright in der Versionsinfo)
   - Links: `git grep -n -i "mausimus.github.io\|github.com/mausimus\|itch.io\|steampowered\|ko-fi"` (erlaubt: Copyright-Köpfe der Dateien, README-Credits, `Scripts/DownloadShaders.bat`)
   - Registry: `git grep -n 'Software\\\\ShaderGlass'` muss leer sein, alles unter `Software\\WinGlass`.
5. **Kennzeichnung:** Jede Datei aus `git diff --name-only vX.Y.Z HEAD` (Quellcode, Skripte, Projektdateien) trägt den Hinweis „Modified for WinGlass by lumen-tools …: this file is NOT the original ShaderGlass source.“ Den Copyright-Kopf von mausimus unverändert lassen, auch wenn er die Jahreszahl ändert.
6. **Basisversion nachziehen:** „ShaderGlass 1.3.2“ in Help-Menü (`IDM_ABOUT2`), `Misc/README.txt`, `README.md` und oben in dieser Datei auf die neue Version ändern. `fork-patches/` gegen den neuen Tag neu erzeugen (`git diff vX.Y.Z HEAD -- ShaderGlass/ ':!ShaderGlass/ShaderGlass.rc'`, aufgeteilt nach Funktion).
7. **WinGlass-Version:** `VERSION` erhöhen und in `ShaderGlass.rc` mitziehen: `FILEVERSION`, `PRODUCTVERSION`, `FileVersion`, `ProductVersion` und Help-Menü „WinGlass vX“.
8. **Testen:** GitHub Actions → *Runtime test* → *Run workflow* (`.github/workflows/runtime-test.yml`, Skripte in `ci/`). Er baut WinGlass auf Windows, prüft Menü-Reihenfolge, Häkchen, Bilinear Filter (Bild ändert sich an/aus) und Custom Pixel Size. Im Log müssen `[menu] toggle … : 0 -> 8 -> 0` und bei jedem Test `mean abs diff 1-off vs 3-off = 0` stehen.
9. Auf `main` mergen, dann erzeugt die Änderung an `VERSION` das Release.

---

## 1. Bilinear Filter

### Was er macht

Beim Herunterrechnen des aufgenommenen Bildes auf die Shader-Eingabe (Pixel Size) wird nicht ein einzelner Punkt gelesen, sondern **die ganze Fläche jedes Quellpixels gemittelt**, zentriert auf dessen Mitte. Das geschieht mit n×n bilinearen Abgriffen, wobei n = 2…8 von der Pixel Size abhängt.

- Ergibt dasselbe wie „Bilinear Filtering im Emulator + ShaderGlass darüber“ und verhindert das Mosaik bei krummen Faktoren.
- Gleicher Ansatz wie der Bilinear Filter in DeckGlass.
- Die Shader-Kette selbst bleibt unverändert. Der Filter wirkt nur auf den Preprocess-Pass.
- **Aus** = exakt Original-ShaderGlass.
- Die Einstellung wird in der Registry gespeichert (`HKCU\Software\ShaderGlass`, Wert `Bilinear Filter`).

### Änderungen Datei für Datei

**`ShaderGlass/resource.h`**
```cpp
#define ID_PROCESSING_BILINEARFILTER    32942
```
`_APS_NEXT_COMMAND_VALUE` um eins erhöhen.

**`ShaderGlass/ShaderGlass.rc`** (UTF-16, von Hand) im Menü `IDC_SHADERGLASS`, `POPUP "Processing"`, direkt nach „Keep PC Awake“:
```
        MENUITEM "Keep PC Awake",               ID_PROCESSING_KEEPAWAKE
        MENUITEM "Bilinear Filter",             ID_PROCESSING_BILINEARFILTER
```

**`ShaderGlass/ShaderWindow.h` / `.cpp`**
- `GetBilinearState()` / `SetBilinearState(bool)`: Registry-Wert `Bilinear Filter`, analog zu `GetKeepAwakeState()`.
- In `WndProc` ein `case ID_PROCESSING_BILINEARFILTER`: Häkchen umschalten, Registry speichern, `m_captureOptions.bilinear` setzen, `m_captureManager.UpdateBilinear()` aufrufen.
- In `Create()` nach dem Keep-Awake-Block: wenn `GetBilinearState()`, dann Häkchen setzen und `m_captureOptions.bilinear = true`.
- **Menüpositionen:** `BuildProgramMenu()` holt Untermenüs über ihre **Position** im Processing-Menü. Weil „Bilinear Filter“ davor eingefügt wird, verschiebt sich alles dahinter um +1:

  | Untermenü | Original v1.3.2 | mit Bilinear Filter |
  |---|---|---|
  | FPS (`m_frameSkipMenu`) | 10 | **11** |
  | Recent profiles (`InsertMenu`) | 15 | **16** |
  | GPU (`m_gpuMenu`) | 8 | **9** |
  | Advanced (`m_advancedMenu` und `EnableMenuItem`) | 11 | **12** |

  Ohne diese Korrektur landen die Häkchen von GPU, FPS und Advanced im falschen Menü, und Klicks schalten Optionen immer aus. In einer neuen Version die Zahlen anhand der dortigen Menüreihenfolge neu prüfen.

**`ShaderGlass/CaptureManager.h` / `.cpp`**
- `CaptureOptions`: `bool bilinear {false};`
- `void UpdateBilinear();` ruft `m_shaderGlass->SetBilinear(m_options.bilinear)` auf.
- In `StartSession()` nach `UpdateVertical();` auch `UpdateBilinear();` aufrufen.

**`ShaderGlass/ShaderPass.h` / `.cpp`**
- Die Sampler-Erzeugung aus `Initialize()` in eine eigene Methode `CreateSamplers()` auslagern. Sie leert `m_samplers` zuerst.
- Im Zweig für Nicht-LUT-Texturen: `if(m_shader.m_filterLinear || m_forceLinear)` → `D3D11_FILTER_MIN_MAG_MIP_LINEAR`.
- `void SetForceLinear(bool)`: setzt `m_forceLinear` und erzeugt die Sampler neu.
- `void SetPixelShaderOverride(winrt::com_ptr<ID3D11PixelShader>)`.
- In `Render()`: `PSSetShader(m_pixelShaderOverride ? m_pixelShaderOverride.get() : m_shader.m_pixelShader.get(), ...)`.

**`ShaderGlass/ShaderGlass.h` / `.cpp`**
- Member: `volatile bool m_bilinear`, `volatile bool m_bilinearUpdated`, `winrt::com_ptr<ID3D11PixelShader> m_footprintShader`.
- `SetBilinear(bool)`: setzt beide Flags (wird vom UI-Thread aufgerufen).
- `ApplyBilinear()`: setzt `m_bilinearUpdated = false`, kompiliert bei Bedarf den Footprint-Shader und setzt am **Preprocess-Pass** `SetForceLinear(an)` und `SetPixelShaderOverride(an ? m_footprintShader : nullptr)`.
- Aufrufe: am Ende von `RebuildShaders()` (nach `SGVertical`) und in `Process()` nach dem Block für Preset- und Vertikal-Wechsel: `if(m_bilinearUpdated) ApplyBilinear();`
- `CreateFootprintShader()`: `D3DCompile` (`ps_5_0`, Einstiegspunkt `main`) des folgenden HLSL-Codes, dann `CreatePixelShader`. `d3dcompiler.h` ist über `framework.h` schon eingebunden, `D3DCOMPILER_47.dll` wird verzögert geladen.

```hlsl
Texture2D<float4> Source : register(t2);
SamplerState _Source_sampler : register(s2);

struct PSInput
{
    float2 vTexCoord : TEXCOORD0;
};

float4 main(PSInput input) : SV_Target0
{
    float2 uv = input.vTexCoord;
    float  w, h;
    Source.GetDimensions(w, h);
    float2 texSize = float2(w, h);

    // footprint: captured pixels per shader-input pixel, per texture axis (rotation-safe)
    float2 fp = float2(abs(ddx(uv.x)) + abs(ddy(uv.x)), abs(ddx(uv.y)) + abs(ddy(uv.y))) * texSize;
    fp        = max(fp, 1.0);
    int    n   = clamp((int)ceil(max(fp.x, fp.y)), 2, 8); // taps per axis
    float2 stp = fp / n / texSize;                       // tap spacing in UV

    float4 acc = 0;
    [loop] for(int j = 0; j < n; j++)
    {
        [loop] for(int i = 0; i < n; i++)
        {
            acc += Source.SampleLevel(_Source_sampler, uv + (float2(i, j) + 0.5 - n * 0.5) * stp, 0);
        }
    }
    return acc / (n * n);
}
```

Register `t2`/`s2` entsprechen dem `Source`-Sampler des Preprocess-Shaders (`Shaders/PreprocessShaderDef.h`). Falls mausimus dort die Bindungen ändert, hier anpassen.

---

## 2. Custom Pixel Size

### Was sie macht

Unter **Input → Pixel Size** gibt es zusätzlich zu den festen Stufen den Punkt **„Custom...“**:
- Eingabe von 1,00 bis 20,00 mit 2 Nachkommastellen (z. B. `4,65`), Komma oder Punkt.
- Das Eingabefeld schlägt den aktuellen Wert mit 2 Nachkommastellen vor (`1.00`).
- Danach: Häkchen bei „Custom (x4.65)...“, `4.65px` im Fenstertitel.
- Wird in Profilen gespeichert (`PixelSize "4.65"`) und beim Laden wiederhergestellt.
- „Next“ und „Previous“ (Tasten p/o) wechseln weiter nur zwischen den festen Stufen. Der Pixel-Size-Regler im Shader-Browser bleibt unverändert.

### Änderungen Datei für Datei

**`ShaderGlass/resource.h`**
```cpp
#define IDM_PIXELSIZE_CUSTOM            32943
```
`_APS_NEXT_COMMAND_VALUE` um eins erhöhen.

**`ShaderGlass/ShaderWindow.h`**
- Member: `bool m_customPixelSizeActive {false};` und `float m_customPixelSize {1.0f};`
- Methoden: `void SetCustomPixelSize(float value);` und `std::string PixelSizeMnemonic() const;`

**`ShaderGlass/ShaderWindow.cpp`**
- Menü: nach der Schleife `for(const auto& px : pixelSizes) AppendMenu(...)` folgt `AppendMenu(m_pixelSizeMenu, MF_STRING, IDM_PIXELSIZE_CUSTOM, L"Custom...");`
- Feste Stufe gewählt (Block `pixelSizes.find(wmId)`): `m_customPixelSizeActive = false;` und Custom-Häkchen entfernen.
- `case IDM_PIXELSIZE_CUSTOM`:
  - `lParam != 0` (aus einem Profil): Wert = `lParam / CUSTOM_PARAM_SCALE` (1000).
  - Sonst Dialog: `m_inputDialog->GetInput("Pixel Size (1.00 - 20.00):", m_customPixelSize, 2)`, umrahmt von `StartDialog()`/`EndDialog()`.
  - Werte außerhalb von 1–20 ablehnen (Meldung), sonst `SetCustomPixelSize(value)`.
- `SetCustomPixelSize`: auf 2 Stellen runden, alle festen Stufen abhaken, Custom abhaken und als `Custom (x…)...` beschriften, `m_captureOptions.pixelWidth/pixelHeight` setzen, `UpdatePixelSize()`, `UpdateWindowState()`.
- `PixelSizeMnemonic()`: bei fester Stufe deren `mnemonic`, sonst der Custom-Wert mit `%.2f` ohne Nullen am Ende (4.50 → 4.5).
- **Profil speichern:** `PixelSize` mit `PixelSizeMnemonic()` statt `pixelSize.mnemonic`. Die dann ungenutzte lokale Variable `pixelSize` entfernen.
- **Profil laden:** Passt `PixelSize` zu keiner festen Stufe, den Wert mit `std::stof` lesen und, wenn er zwischen 1 und 20 liegt, `IDM_PIXELSIZE_CUSTOM` mit `lParam = roundf(wert * CUSTOM_PARAM_SCALE)` senden.
- **Fenstertitel (`UpdateTitle`):** `PixelSizeMnemonic().c_str()` statt `pixelSize.mnemonic`.

**`ShaderGlass/InputDialog.h` / `.cpp`**
- `float GetInput(const std::string& label, float existing, int decimals = -1);`
- Bei `decimals >= 0` den Startwert mit `snprintf("%.*f", decimals, value)` anzeigen, sonst wie bisher (`std::to_string`, das betrifft die Eingabe für das Seitenverhältnis).
- Vor `std::stof` jedes `,` in der Eingabe durch `.` ersetzen.

---

## 3. Umbenennung zu WinGlass (Wünsche von mausimus)

mausimus hat für öffentliche Forks gebeten: Projekt überall umbenennen, keine Links auf seine Doku/Issues/Downloads, Original-Copyright behalten, klar machen, dass es nicht das Original ist, und geänderte Quelldateien kennzeichnen. Umgesetzt (nicht in den Patches enthalten, bei einer neuen Version erneut durchgehen):

- **Sichtbare Namen:** Fenstertitel (`WinGlass (...)`, `WinGlass (stopped)`, `WinGlass (no input selected)`), alle `MessageBox`-Titel, Dialogtitel (`CAPTION "WinGlass"` in `ShaderGlass.rc`), `IDS_APP_TITLE`, Profil-Dateifilter `WinGlass Profiles (*.sgp)`, Fehlermeldung beim Import („import into WinGlass“).
- **Programmdatei:** `<TargetName>WinGlass</TargetName>` in allen vier Konfigurationen von `ShaderGlass.vcxproj`, also `WinGlass.exe`.
- **Versionsinfo** in `ShaderGlass.rc` (`VS_VERSION_INFO`): Produktname WinGlass, Version, Copyright „Based on ShaderGlass (C) 2021-2025 mausimus; modifications (C) 2026 lumen-tools; GPL-3.0“. **Bei jedem Release `FILEVERSION`, `PRODUCTVERSION`, `FileVersion`, `ProductVersion` und den Menüpunkt „WinGlass vX“ im Help-Menü von Hand mit `VERSION` abgleichen.**
- **Help-Menü:** „WinGlass v1.2“, „Unofficial fork of ShaderGlass 1.3.2 by mausimus“ (`IDM_ABOUT2`, inaktiv), Link `github.com/lumen-tools/WinGlass`. „Online Manual“ und FAQ öffnen das WinGlass-README.
- **Einstellungen und Standardprofil:** Registry `HKCU\Software\WinGlass` statt `Software\ShaderGlass` (`ShaderWindow.cpp`, `BrowserWindow.cpp`), Standardprofil `WinGlassDefault.sgp`, damit sich WinGlass und ShaderGlass nicht gegenseitig verstellen.
- **Fensterklasse:** String `IDC_SHADERGLASS` = `"WINGLASS"`.
- **WineCap:** PipeWire-Streamname „WinGlass Input“ und Portal-Tokens `WinGlass%u` (`pipewire.c`, `portal.c`), `Makefile` startet `WinGlass.exe`.
- **Hilfsskripte** (`Scripts/`), `Misc/CustomShader.slang`, `WineCap/README.md`: Programmname WinGlass. Der Download-Link auf mausimus' `slang-shaders`-Fork in `DownloadShaders.bat` bleibt, weil er nur die Shader-Quellen für einen Neubau liefert.
- **Entfernt:** `images/`, `FAQ.md`, `Misc/MANUAL.html`, `Misc/MANUAL.pdf` (Doku und Links von mausimus), `.github/FUNDING.yml`, `.github/CONTRIBUTING.md`, die Original-Workflows `build.yml` und `build-winecap.yml`.
- **README.md** komplett neu, `Misc/README.txt` (kommt als README.txt ins ZIP) neu.
- **Kennzeichnung:** Jede gegenüber v1.3.2 geänderte Datei trägt oben den Hinweis „Modified for WinGlass by lumen-tools, 2026: this file is NOT the original ShaderGlass source.“ Der Original-Copyright-Kopf von mausimus bleibt unverändert darüber.
- **Bewusst nicht umbenannt (intern, nicht sichtbar):** Projekt-, Ordner-, Datei- und Klassennamen (`ShaderGlass.sln`, `ShaderGlass/`, `class ShaderGlass`, `IDC_SHADERGLASS` usw.), damit Vergleiche mit dem Original einfach bleiben.
- **Eigenes Programmsymbol:** `ShaderGlass/WinGlass.ico` (Fenster mit Röhrenbildschirm) ersetzt `ShaderGlass.ico` und `small.ico` von mausimus (`ShaderGlass.rc`, `.vcxproj`, `.vcxproj.filters`).

## Weitere Fork-spezifische Dinge (keine Funktionen)

Diese gehören nicht zu den beiden Funktionen, gehören aber zum Fork:
- `.github/workflows/release.yml`: Baut `WinGlass.exe` (Windows) und `WineCap.dll` (Linux/Wine) und packt `WinGlass-<version>-win-x64.zip` (WinGlass.exe, WineCap.dll, README.txt, LICENSE, CustomShader.slang). Ausgelöst wird ein Release durch eine Änderung an `VERSION` auf `main`.
- `VERSION`: Versionsnummer des Forks.
- `.github/workflows/runtime-test.yml` + `ci/`: manueller Laufzeittest auf Windows (Bilinear Filter, Menü, Custom Pixel Size), siehe Checkliste Punkt 8.
- `CLAUDE.md`: Kurzanleitung für KI-Assistenten, verweist auf diese Datei.
