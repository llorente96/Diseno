# Aplica un perfil del equipo en ESTE ordenador Windows (Claude Code). Version de aplicar-perfil.sh.
# Uso: powershell -ExecutionPolicy Bypass -File perfiles\aplicar-perfil.ps1 -Perfil director-creativo [-Simular]
param(
  [Parameter(Mandatory = $true)][ValidateSet('diseno', 'ingenieria', 'director-creativo')][string]$Perfil,
  [switch]$Simular
)
# Continue: en PowerShell 5.1, con 'Stop' cualquier aviso de claude por stderr cortaria el script.
$ErrorActionPreference = 'Continue'
# El instalador de Claude Code deja claude.exe en .local\bin, que a veces no esta en el PATH.
if (-not (Get-Command claude -ErrorAction SilentlyContinue)) { $env:Path = (Join-Path $HOME '.local\bin') + ';' + $env:Path }
if (-not (Get-Command claude -ErrorAction SilentlyContinue)) { Write-Host "No encuentro el comando 'claude'. Instala Claude Code primero."; exit 1 }

$listas  = (Get-Content (Join-Path $PSScriptRoot 'perfiles.json') -Raw -Encoding UTF8 | ConvertFrom-Json).$Perfil
$plugins = claude plugin list --json | Out-String | ConvertFrom-Json
function Normaliza([string]$s) { $s.ToLower().Replace('_', '-').Replace(' ', '-') }

# Dependencias que faltan a plugins del perfil: solo se instalan las aprobadas en dependencias.json
$rutaDeps = Join-Path $PSScriptRoot 'dependencias.json'
$aprobadas = if (Test-Path $rutaDeps) { Get-Content $rutaDeps -Raw -Encoding UTF8 | ConvertFrom-Json } else { New-Object PSObject }
$vistas = @{}
foreach ($p in $plugins) {
  if ($listas.on -notcontains (Normaliza ($p.id -split '@')[0])) { continue }
  foreach ($e in @($p.errorDetails)) {
    if (-not $e -or $e.type -ne 'dependency-unsatisfied' -or $vistas.ContainsKey($e.dependency)) { continue }
    $dep = $e.dependency; $vistas[$dep] = $true
    $origen = $aprobadas.$dep
    if (-not $origen) { Write-Host "  AVISO falta la dependencia $dep y no esta en dependencias.json (no se instala)"; continue }
    if ($Simular) { Write-Host "  [simulacion] instalar dependencia $dep (de $origen)"; continue }
    claude plugin marketplace add $origen *> $null
    claude plugin install $dep --scope user *> $null
    if ($LASTEXITCODE -eq 0) { Write-Host "  OK dependencia instalada: $dep" } else { Write-Host "  ERROR no se pudo instalar la dependencia $dep" }
  }
}

foreach ($par in @(@('enable', $listas.on), @('disable', $listas.off))) {
  $accion = $par[0]
  foreach ($clave in $par[1]) {
    $ids = @($plugins | Where-Object { (Normaliza ($_.id -split '@')[0]) -eq $clave } | ForEach-Object { $_.id })
    if ($ids.Count -eq 0) { Write-Host "  - ${clave}: no esta instalado en este equipo (se ignora)"; continue }
    foreach ($id in $ids) {
      $activo = ($plugins | Where-Object { $_.id -eq $id } | Select-Object -First 1).enabled
      if ([bool]$activo -eq ($accion -eq 'enable')) { Write-Host "  = $id ya estaba como debe"; continue }
      if ($Simular) { Write-Host "  [simulacion] $accion $id"; continue }
      $err = claude plugin $accion $id --scope user 2>&1 | Out-String
      if ($LASTEXITCODE -eq 0) { Write-Host "  OK $accion $id" } else { Write-Host "  ERROR no se pudo: $accion $id -> $(($err.Trim() -split "`n")[-1])" }
    }
  }
}

Write-Host ''
if ($Simular) { Write-Host 'Simulacion terminada: no se ha cambiado nada.'; exit 0 }
# Verificacion: lo que debia quedar activo, lo esta? (p. ej. falta una dependencia)
foreach ($p in (claude plugin list --json | Out-String | ConvertFrom-Json)) {
  if (($listas.on -contains (Normaliza ($p.id -split '@')[0])) -and -not $p.enabled) {
    $motivo = if ($p.errors) { $p.errors -join '; ' } else { 'motivo desconocido' }
    Write-Host "  AVISO $($p.id) sigue desactivado: $motivo"
  }
}
$skills = Join-Path $HOME '.claude\skills'
New-Item -ItemType Directory -Force -Path $skills | Out-Null
Copy-Item (Join-Path $PSScriptRoot 'skills-equipo\*') $skills -Recurse -Force
Write-Host '  OK skills del equipo copiadas a .claude\skills'
# Skills propias del perfil (p. ej. la seleccion de ECC en ingenieria\.claude\skills)
$propias = Join-Path $PSScriptRoot "$Perfil\.claude\skills"
if (Test-Path $propias) {
  Copy-Item (Join-Path $propias '*') $skills -Recurse -Force
  Write-Host "  OK skills del perfil copiadas ($(@(Get-ChildItem $propias -Directory).Count))"
}
Write-Host "Perfil '$Perfil' aplicado. Reinicia Claude Code."
