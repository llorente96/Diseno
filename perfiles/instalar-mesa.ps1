# Configura una mesa Windows UNA SOLA VEZ: guarda el perfil, lo aplica y deja la actualizacion automatica.
# Uso: powershell -ExecutionPolicy Bypass -File perfiles\instalar-mesa.ps1 -Perfil director-creativo
param([Parameter(Mandatory = $true)][ValidateSet('diseno', 'ingenieria', 'director-creativo')][string]$Perfil)
$ErrorActionPreference = 'Stop'
$repo  = Split-Path $PSScriptRoot -Parent
$dirC  = Join-Path $HOME '.claude'
New-Item -ItemType Directory -Force -Path $dirC | Out-Null

# Sin BOM: Claude Code lee estos JSON.
$utf8 = New-Object System.Text.UTF8Encoding($false)
[IO.File]::WriteAllText((Join-Path $dirC 'perfil-equipo.json'), (ConvertTo-Json -InputObject @{ perfil = $Perfil; repo = $repo }), $utf8)

& (Join-Path $PSScriptRoot 'aplicar-perfil.ps1') -Perfil $Perfil

# Hook de inicio de sesion que llama a actualizar-perfil.ps1 (sin duplicar ni borrar otros hooks).
$script = (Join-Path $PSScriptRoot 'actualizar-perfil.ps1') -replace '\\', '/'
$cmd = "powershell -NoProfile -ExecutionPolicy Bypass -File `"$script`""
$ruta = Join-Path $dirC 'settings.json'
$s = if ((Test-Path $ruta) -and (Get-Item $ruta).Length -gt 0) { Get-Content $ruta -Raw -Encoding UTF8 | ConvertFrom-Json } else { New-Object PSObject }
if (-not $s.PSObject.Properties['hooks']) { $s | Add-Member -NotePropertyName hooks -NotePropertyValue (New-Object PSObject) }
if (-not $s.hooks.PSObject.Properties['SessionStart']) { $s.hooks | Add-Member -NotePropertyName SessionStart -NotePropertyValue @() }
$ya = @($s.hooks.SessionStart | ForEach-Object { $_.hooks } | Where-Object { $_.command -eq $cmd }).Count -gt 0
if (-not $ya) {
  $s.hooks.SessionStart = @($s.hooks.SessionStart) + @([PSCustomObject]@{ hooks = @([PSCustomObject]@{ type = 'command'; command = $cmd }) })
}
[IO.File]::WriteAllText($ruta, (ConvertTo-Json -InputObject $s -Depth 20), $utf8)

Write-Host "OK Mesa configurada con el perfil '$Perfil'."
Write-Host '  Los cambios que subas al repo se aplicaran solos (como mucho una vez al dia, al abrir Claude Code).'
