# Muestra la configuracion de Claude Code de ESTA mesa Windows (sin gastar tokens, sin claves).
# Uso: powershell -ExecutionPolicy Bypass -File perfiles\ver-mesa.ps1
$dirC = Join-Path $HOME '.claude'
"=== Mesa: $env:COMPUTERNAME - $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
''; '=== Perfil guardado'
$conf = Join-Path $dirC 'perfil-equipo.json'
if (Test-Path $conf) { Get-Content $conf -Raw -Encoding UTF8 } else { '(ninguno: esta mesa no se ha configurado con instalar-mesa.ps1)' }
''; '=== Plugins (ON/OFF) y tokens por sesion'
foreach ($p in (claude plugin list --json | Out-String | ConvertFrom-Json)) {
  if ($p.enabled) { "ON  $($p.id)  " + ((claude plugin details $p.id | Select-String 'Always-on') -replace '\s+', ' ') }
  else { "OFF $($p.id)" }
}
''; '=== Ajustes de usuario (solo plugins, hooks y modelo)'
$ruta = Join-Path $dirC 'settings.json'
if (Test-Path $ruta) { Get-Content $ruta -Raw -Encoding UTF8 | ConvertFrom-Json | Select-Object model, enabledPlugins, hooks | ConvertTo-Json -Depth 8 } else { '(sin settings.json)' }
''; '=== Skills personales'
$sk = Join-Path $dirC 'skills'
if (Test-Path $sk) { Get-ChildItem $sk -Name } else { '(ninguna)' }
''; '=== Conectores (solo los anadidos en Claude Code; los de la cuenta estan en la app)'
claude mcp list
