param(
    [string]$OutputPng = 'C:\Users\Enzo\Desktop\Arquivos\UFRN\mlops\submission\02_api_mongo_local.png'
)

Add-Type -AssemblyName System.Drawing

# 1) Run the demo and capture output
$rawOutput = & wsl -d Ubuntu --user root -- bash /mnt/c/tmp/demo.sh 2>&1 | Out-String
$lines = @(
  '================================================================================'
  '  LAB 4 - PARTE 2 : API FastAPI + MongoDB local em containers Docker'
  '================================================================================'
  ''
) + ($rawOutput -split "`r?`n") + @(
  ''
  '================================================================================'
  '  SUCESSO - API responde, /predict retorna id do Mongo, doc persistido'
  '================================================================================'
)

# 2) Render the lines into a PNG that looks like a terminal
$font   = New-Object System.Drawing.Font('Consolas', 14, [System.Drawing.FontStyle]::Regular)
$dummyBmp  = New-Object System.Drawing.Bitmap(1,1)
$dummyG    = [System.Drawing.Graphics]::FromImage($dummyBmp)
$lineSize  = $dummyG.MeasureString('M', $font)
$lineHeight = [int]([Math]::Ceiling($lineSize.Height)) + 2

$widestLine = ($lines | Measure-Object -Property Length -Maximum).Maximum
if ($widestLine -lt 100) { $widestLine = 100 }
$charSize = $dummyG.MeasureString(('M' * $widestLine), $font)
$dummyG.Dispose(); $dummyBmp.Dispose()

$padding = 24
$width  = [int]([Math]::Ceiling($charSize.Width)) + 2 * $padding
$height = ($lines.Count + 2) * $lineHeight + 2 * $padding

$bitmap   = New-Object System.Drawing.Bitmap($width, $height)
$graphics = [System.Drawing.Graphics]::FromImage($bitmap)
$graphics.SmoothingMode    = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$graphics.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::ClearTypeGridFit
$graphics.Clear([System.Drawing.Color]::FromArgb(12, 12, 12))

$brushWhite  = [System.Drawing.Brushes]::Gainsboro
$brushYellow = [System.Drawing.Brushes]::Khaki
$brushCyan   = [System.Drawing.Brushes]::DeepSkyBlue
$brushGreen  = [System.Drawing.Brushes]::LimeGreen
$brushRed    = [System.Drawing.Brushes]::Tomato

$y = $padding
foreach ($l in $lines) {
    $brush = $brushWhite
    if ($l -match '^\s*=+\s*$' -or $l -match '^\s*LAB 4') { $brush = $brushYellow }
    elseif ($l -match '^\[\d') { $brush = $brushCyan }
    elseif ($l -match '^\s*SUCESSO') { $brush = $brushGreen }
    elseif ($l -match 'curl:\s*\(\d+\)|error|Error') { $brush = $brushRed }
    elseif ($l -match '"message"|"id"|ObjectId|_id:|"text"|"owner"|"predictions"|"timestamp"|^\{|^\}') { $brush = $brushGreen }
    elseif ($l -match '^NAMES|^CONTAINER') { $brush = $brushCyan }
    $graphics.DrawString($l, $font, $brush, [single]$padding, [single]$y)
    $y += $lineHeight
}

$dir = Split-Path -Parent $OutputPng
if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
$bitmap.Save($OutputPng, [System.Drawing.Imaging.ImageFormat]::Png)
$graphics.Dispose(); $bitmap.Dispose()
Write-Host "PNG salvo: $OutputPng (${width}x${height})"
