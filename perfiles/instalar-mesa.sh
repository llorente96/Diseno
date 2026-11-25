#!/usr/bin/env bash
# Configura una mesa UNA SOLA VEZ: guarda el perfil, lo aplica y deja la actualización automática.
# Uso: bash perfiles/instalar-mesa.sh diseno|ingenieria|director-creativo
set -euo pipefail
PERFIL="${1:-}"
case "$PERFIL" in diseno|ingenieria|director-creativo) ;; *) echo "Uso: $0 diseno|ingenieria|director-creativo"; exit 1 ;; esac
REPO="$(cd "$(dirname "$0")/.." && pwd)"
mkdir -p "$HOME/.claude"

printf 'PERFIL=%q\nREPO=%q\n' "$PERFIL" "$REPO" > "$HOME/.claude/perfil-equipo"
bash "$REPO/perfiles/aplicar-perfil.sh" "$PERFIL"

# Hook de inicio de sesión que llama a actualizar-perfil.sh (sin duplicar ni borrar otros hooks).
CMD="bash \"$REPO/perfiles/actualizar-perfil.sh\""
SETTINGS="$HOME/.claude/settings.json" CMD="$CMD" python3 - <<'PY'
import json, os
p, cmd = os.environ["SETTINGS"], os.environ["CMD"]
s = json.load(open(p)) if os.path.exists(p) and os.path.getsize(p) else {}
grupos = s.setdefault("hooks", {}).setdefault("SessionStart", [])
if not any(h.get("command") == cmd for g in grupos for h in g.get("hooks", [])):
    grupos.append({"hooks": [{"type": "command", "command": cmd}]})
json.dump(s, open(p, "w"), indent=2, ensure_ascii=False)
PY

echo "✓ Mesa configurada con el perfil '$PERFIL'."
echo "  Los cambios que subas al repo se aplicarán solos (como mucho una vez al día, al abrir Claude Code)."
echo "  Para cambiar de perfil: vuelve a ejecutar este script con otro perfil."
