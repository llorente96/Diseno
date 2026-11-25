# Aplica un perfil del equipo en ESTE ordenador Windows (Claude Code). Version de aplicar-perfil.sh.
# Uso: powershell -ExecutionPolicy Bypass -File perfiles\aplicar-perfil.ps1 -Perfil director-creativo [-Simular]
param(
  [Parameter(Mandatory = $true)][ValidateSet('diseno', 'ingenieria', 'director-creativo')][string]$Perfil,
  [switch]$Simular
)
$ErrorActionPreference = 'Stop'
if (-not (Get-Command claude -ErrorAction SilentlyContinue)) { Write-Host "No encuentro el comando 'claude'. Instala Claude Code primero."; exit 1 }

$listas  = (Get-Content (Join-Path $PSScriptRoot 'perfiles.json') -Raw -Encoding UTF8 | ConvertFrom-Json).$Perfil
$plugins = claude plugin list --json | Out-String | ConvertFrom-Json
function Normaliza([string]$s) { $s.ToLower().Replace('_', '-').Replace(' ', '-') }

foreach ($par in @(@('enable', $listas.on), @('disable', $listas.off))) {
  $accion = $par[0]
  foreach ($clave in $par[1]) {
    $ids = @($plugins | Where-Object { (Normaliza ($_.id -split '@')[0]) -eq $clave } | ForEach-Object { $_.id })
    if ($ids.Count -eq 0) { Write-Host "  - ${clave}: no esta instalado en este equipo (se ignora)"; continue }
    foreach ($id in $ids) {
      if ($Simular) { Write-Host "  [simulacion] $accion $id"; continue }
      claude plugin $accion $id --scope user *> $null
      if ($LASTEXITCODE -eq 0) { Write-Host "  OK $accion $id" } else { Write-Host "  ERROR no se pudo: $accion $id" }
    }
  }
}

Write-Host ''
if ($Simular) { Write-Host 'Simulacion terminada: no se ha cambiado nada.'; exit 0 }
$skills = Join-Path $HOME '.claude\skills'
New-Item -ItemType Directory -Force -Path $skills | Out-Null
Copy-Item (Join-Path $PSScriptRoot 'skills-equipo\*') $skills -Recurse -Force
Write-Host '  OK skills del equipo copiadas a .claude\skills'
Write-Host "Perfil '$Perfil' aplicado. Reinicia Claude Code."
