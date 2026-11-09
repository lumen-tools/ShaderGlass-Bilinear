Add-Type -AssemblyName System.Windows.Forms, System.Drawing
$bmp = New-Object System.Drawing.Bitmap 480, 320
$colors = @([System.Drawing.Color]::Red, [System.Drawing.Color]::Lime, [System.Drawing.Color]::Blue, [System.Drawing.Color]::White, [System.Drawing.Color]::Black, [System.Drawing.Color]::Yellow)
for ($y = 0; $y -lt 320; $y++) { for ($x = 0; $x -lt 480; $x++) {
  $i = ([math]::Floor($x / 13) + [math]::Floor($y / 7)) % 6
  if ((($x + $y) % 40) -lt 3 -or ($x % 9) -eq 0) { $i = 4 }
  $bmp.SetPixel($x, $y, $colors[$i]) } }
$form = New-Object System.Windows.Forms.Form
$form.Text = "SGTestPattern"
$form.FormBorderStyle = 'FixedSingle'
$form.ClientSize = New-Object System.Drawing.Size 480, 320
$form.StartPosition = 'Manual'
$form.Location = New-Object System.Drawing.Point 0, 0
$pb = New-Object System.Windows.Forms.PictureBox
$pb.Dock = 'Fill'; $pb.Image = $bmp
$form.Controls.Add($pb)
[System.Windows.Forms.Application]::Run($form)
