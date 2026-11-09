param([string]$Exe)
Add-Type @"
using System; using System.Runtime.InteropServices; using System.Text;
public static class M {
  [DllImport("user32.dll")] public static extern IntPtr GetMenu(IntPtr h);
  [DllImport("user32.dll")] public static extern IntPtr GetSubMenu(IntPtr m, int p);
  [DllImport("user32.dll")] public static extern uint GetMenuState(IntPtr m, uint id, uint f);
  [DllImport("user32.dll", CharSet=CharSet.Unicode)] public static extern int GetMenuString(IntPtr m, uint id, StringBuilder s, int n, uint f);
  [DllImport("user32.dll")] public static extern int GetMenuItemCount(IntPtr m);
  [DllImport("user32.dll")] public static extern bool SendMessage(IntPtr h, uint m, IntPtr w, IntPtr l);
}
"@
New-Item -ItemType Directory -Force out | Out-Null
$p = Start-Process $Exe -PassThru
Start-Sleep 10
$h = (Get-Process -Id $p.Id).MainWindowHandle
$prog = [M]::GetSubMenu([M]::GetMenu($h), 0)
for ($i = 0; $i -lt [M]::GetMenuItemCount($prog); $i++) {
  $sb = New-Object System.Text.StringBuilder 100
  [M]::GetMenuString($prog, $i, $sb, 100, 0x400) | Out-Null
  "[menu] $i '$($sb.ToString())' popup=$([M]::GetSubMenu($prog, $i) -ne [IntPtr]::Zero)" | Tee-Object -Append out\result.txt
}
$adv = [M]::GetSubMenu($prog, 12)
foreach ($id in 32909, 32942, 32912) {
  $menu = if ($id -eq 32909) { $adv } else { $prog }
  $s0 = [M]::GetMenuState($menu, $id, 0) -band 8
  [M]::SendMessage($h, 0x111, [IntPtr]$id, [IntPtr]::Zero) | Out-Null
  $s1 = [M]::GetMenuState($menu, $id, 0) -band 8
  [M]::SendMessage($h, 0x111, [IntPtr]$id, [IntPtr]::Zero) | Out-Null
  $s2 = [M]::GetMenuState($menu, $id, 0) -band 8
  "[menu] toggle $id : $s0 -> $s1 -> $s2" | Tee-Object -Append out\result.txt
}
[M]::SendMessage($h, 0x111, [IntPtr]32943, [IntPtr]4650) | Out-Null
Start-Sleep 2
"[menu] title after custom 4.65: $((Get-Process -Id $p.Id).MainWindowTitle)" | Tee-Object -Append out\result.txt
Stop-Process -Id $p.Id -Force
Start-Sleep 2
