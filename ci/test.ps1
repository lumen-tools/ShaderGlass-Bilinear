param([string]$Exe, [string]$Cat = "general", [string]$Shader = "none", [string]$Px = "8", [string]$Tag = "none")
$ErrorActionPreference = 'Continue'
Add-Type -AssemblyName System.Drawing
Add-Type @"
using System; using System.Runtime.InteropServices;
public static class W {
  [DllImport("user32.dll")] public static extern IntPtr FindWindow(string c, string t);
  [DllImport("user32.dll")] public static extern bool PostMessage(IntPtr h, uint m, IntPtr w, IntPtr l);
  [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr h, out RECT r);
  [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr h);
  [DllImport("user32.dll")] public static extern bool SetWindowPos(IntPtr h, IntPtr a, int x, int y, int cx, int cy, uint f);
  [DllImport("user32.dll")] public static extern bool SetProcessDPIAware();
  [StructLayout(LayoutKind.Sequential)] public struct RECT { public int L, T, R, B; }
}
"@
[W]::SetProcessDPIAware() | Out-Null
New-Item -ItemType Directory -Force out | Out-Null
$script:imgs = @{}
function Compare-Shots($a, $b) { $x1 = $script:imgs[$a]; $x2 = $script:imgs[$b]; $sum = 0; $n = 0
  for ($y = [int]($x1.Height*0.2); $y -lt [int]($x1.Height*0.8); $y += 3) { for ($x = [int]($x1.Width*0.2); $x -lt [int]($x1.Width*0.8); $x += 3) { $p = $x1.GetPixel($x,$y); $q = $x2.GetPixel($x,$y); $sum += [math]::Abs($p.R-$q.R) + [math]::Abs($p.G-$q.G) + [math]::Abs($p.B-$q.B); $n++ } }
  "[$Tag] mean abs diff $a vs $b = $([math]::Round($sum / $n, 2))" | Tee-Object -Append out\result.txt }

function Shot($name) {
  $h = $script:h
  $r = New-Object W+RECT; [W]::GetWindowRect($h, [ref]$r) | Out-Null
  $w = $r.R - $r.L; $hh = $r.B - $r.T
  $bmp = New-Object System.Drawing.Bitmap $w, $hh
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.CopyFromScreen($r.L, $r.T, 0, 0, $bmp.Size)
  $bmp.Save("out\$Tag-$name.png"); $script:imgs[$name] = $bmp
  $full = New-Object System.Drawing.Bitmap 1920, 1080
  [System.Drawing.Graphics]::FromImage($full).CopyFromScreen(0, 0, 0, 0, $full.Size)
  $full.Save("out\$name-full.png")
  # count distinct colours in centre region
  $set = @{}
  for ($y = [int]($hh*0.3); $y -lt [int]($hh*0.7); $y += 2) { for ($x = [int]($w*0.2); $x -lt [int]($w*0.8); $x += 2) { $set[$bmp.GetPixel($x,$y).ToArgb()] = 1 } }
  "[$Tag] $name : window ${w}x${hh}, distinct colours in centre = $($set.Count)" | Tee-Object -Append out\result.txt
}

Start-Process powershell -ArgumentList '-NoProfile','-ExecutionPolicy','Bypass','-File',"$PWD\ci\pattern.ps1"
Start-Sleep 8
@"
ProfileVersion "1.1"
PixelSize "$Px"
AspectRatio "1"
ShaderCategory "$Cat"
ShaderName "$Shader"
OutputScale "100"
CaptureWindow "SGTestPattern"
"@ | Set-Content -Encoding ascii test.sgp
Start-Process $Exe -ArgumentList "`"$PWD\test.sgp`""
Start-Sleep 12
$proc = Get-Process WinGlass -ErrorAction SilentlyContinue
"WinGlass process: $($proc.Id) title='$($proc.MainWindowTitle)' hwnd=$($proc.MainWindowHandle)" | Tee-Object -Append out\result.txt
Get-Process | Where-Object { $_.MainWindowTitle } | ForEach-Object { "window: $($_.ProcessName) '$($_.MainWindowTitle)'" } | Tee-Object -Append out\result.txt
$script:h = $proc.MainWindowHandle
$h = $script:h
[W]::SetWindowPos($h, [IntPtr]::Zero, 600, 0, 800, 600, 0x4) | Out-Null
Start-Sleep 4
Shot "1-off"
[W]::PostMessage($h, 0x111, [IntPtr]32942, [IntPtr]::Zero) | Out-Null
Start-Sleep 4
Shot "2-on"
[W]::PostMessage($h, 0x111, [IntPtr]32942, [IntPtr]::Zero) | Out-Null
Start-Sleep 4
Shot "3-off"
Compare-Shots "1-off" "3-off"
Compare-Shots "1-off" "2-on"
Get-Process WinGlass -ErrorAction SilentlyContinue | Stop-Process -Force
Get-Process powershell -ErrorAction SilentlyContinue | Where-Object { $_.MainWindowTitle -eq "SGTestPattern" } | Stop-Process -Force
Start-Sleep 2
