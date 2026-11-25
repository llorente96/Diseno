# Prepara un proyecto para un tipo de trabajo: instrucciones, plugins activos SOLO en ese proyecto
# y, si hace falta, sus dependencias aprobadas. Version de preparar-proyecto.sh.
# Uso: powershell -ExecutionPolicy Bypass -File perfiles\preparar-proyecto.ps1 -Tipo wordpress -Ruta C:\ruta\proyecto
param(
  [Parameter(Mandatory = $true)][ValidateSet('wordpress', 'diseno-grafico', 'automatizacion', 'backend')][string]$Tipo,
  [string]$Ruta = (Get-Location).Path
)
$ErrorActionPreference = 'Continue'
if (-not (Get-Command claude -ErrorAction SilentlyContinue)) { $env:Path = (Join-Path $HOME '.local\bin') + ';' + $env:Path }
$utf8 = New-Object System.Text.UTF8Encoding($false)
$kit = Join-Path $PSScriptRoot "trabajos\$Tipo\.claude"
if (-not (Test-Path $Ruta)) { Write-Host "No existe la carpeta del proyecto: $Ruta"; exit 1 }
$Ruta = (Resolve-Path $Ruta).Path
$repo = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
if ($Ruta.StartsWith($repo, [StringComparison]::OrdinalIgnoreCase)) { Write-Host 'Eso es el repositorio de perfiles, no un proyecto. Indica la ruta del proyecto.'; exit 1 }
$dst = Join-Path $Ruta '.claude'
New-Item -ItemType Directory -Force -Path $dst | Out-Null

# 1. Instrucciones del tipo, en un bloque con marcas
$srcMd = Join-Path $kit 'CLAUDE.md'
if (Test-Path $srcMd) {
  $ini = "<!-- trabajo:${Tipo}:inicio -->"; $fin = "<!-- trabajo:${Tipo}:fin -->"
  $bloque = "$ini`n" + (Get-Content $srcMd -Raw -Encoding UTF8).Trim() + "`n$fin`n"
  $dstMd = Join-Path $dst 'CLAUDE.md'
  $actual = if (Test-Path $dstMd) { Get-Content $dstMd -Raw -Encoding UTF8 } else { '' }
  if ($null -eq $actual) { $actual = '' }
  $patron = '(?s)' + [regex]::Escape($ini) + '.*?' + [regex]::Escape($fin) + '\r?\n?'
  if ($actual -match $patron) { $nuevo = [regex]::Replace($actual, $patron, { param($m) $bloque }) }
  elseif ($actual.Trim()) { $nuevo = $actual.TrimEnd() + "`n`n" + $bloque } else { $nuevo = $bloque }
  [IO.File]::WriteAllText($dstMd, $nuevo, $utf8)
  Write-Host "  OK instrucciones de $Tipo en .claude\CLAUDE.md"
}

# 2. Plugins activos solo en este proyecto (fusiona con lo que ya hubiera)
$srcSet = Join-Path $kit 'settings.json'
if (Test-Path $srcSet) {
  $nuevos = (Get-Content $srcSet -Raw -Encoding UTF8 | ConvertFrom-Json).enabledPlugins
  $dstSet = Join-Path $dst 'settings.json'
  $s = if ((Test-Path $dstSet) -and (Get-Item $dstSet).Length -gt 0) { Get-Content $dstSet -Raw -Encoding UTF8 | ConvertFrom-Json } else { New-Object PSObject }
  if (-not $s.PSObject.Properties['enabledPlugins']) { $s | Add-Member -NotePropertyName enabledPlugins -NotePropertyValue (New-Object PSObject) }
  foreach ($prop in $nuevos.PSObject.Properties) {
    $s.enabledPlugins | Add-Member -NotePropertyName $prop.Name -NotePropertyValue $prop.Value -Force
    Write-Host "  OK activo solo en este proyecto: $($prop.Name)"
  }
  [IO.File]::WriteAllText($dstSet, (ConvertTo-Json -InputObject $s -Depth 20), $utf8)

  # 4. Plugins del kit que no estan en este ordenador: instalar si estan aprobados y dejarlos apagados fuera
  $instalados = @((claude plugin list --json | Out-String | ConvertFrom-Json) | ForEach-Object { $_.id })
  $aprobadas = Get-Content (Join-Path $PSScriptRoot 'dependencias.json') -Raw -Encoding UTF8 | ConvertFrom-Json
  foreach ($prop in $nuevos.PSObject.Properties) {
    $id = $prop.Name
    if ($instalados -contains $id) { continue }
    $origen = $aprobadas.$id
    if (-not $origen) { Write-Host "  AVISO $id no esta en este ordenador ni en dependencias.json: no funcionara hasta instalarlo"; continue }
    claude plugin marketplace add $origen *> $null
    $err = claude plugin install $id --scope user 2>&1 | Out-String
    if ($LASTEXITCODE -eq 0) {
      claude plugin disable $id --scope user *> $null
      Write-Host "  OK instalado $id (activo solo en los proyectos que lo piden)"
    } else { Write-Host "  ERROR no se pudo instalar $id -> $(($err.Trim() -split "`n")[-1])" }
  }
}

# 3. Reglas del tipo (p. ej. backend)
$reglas = Join-Path $kit 'rules'
if (Test-Path $reglas) { Copy-Item $reglas $dst -Recurse -Force; Write-Host '  OK reglas copiadas a .claude\rules' }

Write-Host ''
Write-Host "Proyecto preparado para '$Tipo': $Ruta"
Write-Host 'Abre Claude Code dentro de esa carpeta. Si el proyecto usa git, sube la carpeta .claude para que la tenga todo el equipo.'
