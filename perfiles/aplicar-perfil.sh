#!/usr/bin/env bash
# Aplica un perfil del equipo en ESTE ordenador (Claude Code).
# Uso: bash perfiles/aplicar-perfil.sh diseno|ingenieria|direccion [--dry-run]
# Activa/desactiva plugins solo en este equipo (scope user): la cuenta compartida no cambia.
# Plugins que no aparecen en ninguna lista del perfil no se tocan.
set -euo pipefail

PERFIL="${1:-}"; DRY="${2:-}"
DIR="$(cd "$(dirname "$0")" && pwd)"

case "$PERFIL" in
  diseno)
    ON="design figma impeccable document-skills pdf-viewer"
    OFF="ecc ponytail superpowers taste-skill claude-api wordpress-dev-skills marketing sales human-resources social-media-skills wordpress-devkit" ;;
  ingenieria)
    ON="design figma impeccable ponytail wordpress-dev-skills claude-api document-skills pdf-viewer"
    OFF="ecc superpowers taste-skill marketing sales human-resources social-media-skills" ;;
  direccion)
    ON="design figma impeccable marketing document-skills pdf-viewer"
    OFF="ecc ponytail superpowers taste-skill claude-api wordpress-dev-skills sales human-resources social-media-skills wordpress-devkit" ;;
  *) echo "Uso: $0 diseno|ingenieria|direccion [--dry-run]"; exit 1 ;;
esac

command -v claude >/dev/null || { echo "No encuentro el comando 'claude'. Instala Claude Code primero."; exit 1; }

# Empareja cada nombre del perfil con el id real (nombre@marketplace) instalado en este equipo.
PLAN="$(claude plugin list --json | ON="$ON" OFF="$OFF" python3 -c '
import json, os, sys
plugins = json.load(sys.stdin)
def norm(s): return s.lower().replace("_", "-").replace(" ", "-")
for accion, var in (("enable", "ON"), ("disable", "OFF")):
    for clave in os.environ[var].split():
        ids = [p["id"] for p in plugins if norm(p["id"].split("@")[0]) == clave]
        if not ids:
            print("falta", clave)
        for i in ids:
            print(accion, i)
')"

while read -r accion id; do
  [ -z "$accion" ] && continue
  if [ "$accion" = "falta" ]; then echo "  · $id: no está instalado en este equipo (se ignora)"; continue; fi
  if [ "$DRY" = "--dry-run" ]; then echo "  [simulación] $accion $id"; continue; fi
  claude plugin "$accion" "$id" --scope user >/dev/null 2>&1 && echo "  ✓ $accion $id" || echo "  ✗ no se pudo: $accion $id"
done <<< "$PLAN"

# Skills del equipo
if [ "$DRY" != "--dry-run" ]; then
  mkdir -p "$HOME/.claude/skills"
  cp -R "$DIR/skills-equipo/"* "$HOME/.claude/skills/"
  echo "  ✓ skills del equipo copiadas a ~/.claude/skills"
fi

echo
echo "Perfil '$PERFIL' aplicado. Reinicia Claude Code."
echo "Para ver lo que pesa cada plugin: claude plugin details <nombre@marketplace>"
