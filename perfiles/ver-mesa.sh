#!/usr/bin/env bash
# Muestra la configuración de Claude Code de ESTA mesa (sin gastar tokens, sin secretos).
# Uso: bash perfiles/ver-mesa.sh > mesa.txt   (y pega mesa.txt donde haga falta)
C="$HOME/.claude"
echo "=== Mesa: $(scutil --get ComputerName 2>/dev/null || hostname) · $(date '+%F %H:%M')"
echo; echo "=== Perfil guardado"
cat "$C/perfil-equipo" 2>/dev/null || echo "(ninguno: esta mesa no se ha configurado con instalar-mesa.sh)"

echo; echo "=== Plugins (activo / inactivo) y tokens por sesión"
claude plugin list --json 2>/dev/null | python3 -c '
import json, sys, subprocess, re
for p in json.load(sys.stdin):
    tok = ""
    if p["enabled"]:
        out = subprocess.run(["claude", "plugin", "details", p["id"]], capture_output=True, text=True).stdout
        m = re.search(r"Always-on:\s+~([\d,.]+) tok", out)
        tok = f"  ~{m.group(1)} tokens" if m else ""
    print(("✅ " if p["enabled"] else "⬜ ") + p["id"] + tok)
'

echo; echo "=== Ajustes de usuario (solo plugins, hooks y modelo; nada de claves)"
python3 - "$C/settings.json" <<'PY'
import json, sys
try: s = json.load(open(sys.argv[1]))
except Exception: print("(sin settings.json)"); sys.exit()
for k in ("model", "enabledPlugins", "hooks", "statusLine"):
    if k in s: print(k + ":", json.dumps(s[k], indent=2, ensure_ascii=False))
PY

echo; echo "=== Skills personales (~/.claude/skills)"
ls "$C/skills" 2>/dev/null || echo "(ninguna)"

echo; echo "=== Servidores MCP / conectores"
claude mcp list 2>/dev/null | grep -v '^Checking' | sed -E 's#(https?://[^/ ]+)[^ ]*#\1#'
