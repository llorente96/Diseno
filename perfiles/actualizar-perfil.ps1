# Lo lanza Claude Code al iniciar (hook). Una vez al dia, en segundo plano: baja cambios del repo y,
# si cambio algo en perfiles/, reaplica el perfil guardado. Nunca bloquea ni falla.
param([switch]$Trabajo)
try {
  $dirC = Join-Path $HOME '.claude'
  $conf = Join-Path $dirC 'perfil-equipo.json'
  if (-not (Test-Path $conf)) { exit 0 }
  $c = Get-Content $conf -Raw -Encoding UTF8 | ConvertFrom-Json
  if (-not $Trabajo) {
    $marca = Join-Path $dirC 'perfil-equipo.ultimo'
    $hoy = Get-Date -Format 'yyyy-MM-dd'
    if ((Test-Path $marca) -and ((Get-Content $marca -Raw -Encoding UTF8).Trim() -eq $hoy)) { exit 0 }
    Set-Content $marca $hoy
    Start-Process powershell -WindowStyle Hidden -ArgumentList '-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', "`"$PSCommandPath`"", '-Trabajo'
    exit 0
  }
  $antes = git -C $c.repo rev-parse HEAD
  git -C $c.repo pull -q --ff-only
  if ($LASTEXITCODE -ne 0) { exit 0 }
  $despues = git -C $c.repo rev-parse HEAD
  if ($antes -ne $despues) {
    git -C $c.repo diff --quiet $antes $despues -- perfiles
    if ($LASTEXITCODE -ne 0) {
      & (Join-Path $c.repo 'perfiles\aplicar-perfil.ps1') -Perfil $c.perfil *> (Join-Path $dirC 'perfil-equipo.log')
    }
  }
} catch { }
exit 0
