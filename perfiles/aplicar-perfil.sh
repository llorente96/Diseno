#!/usr/bin/env bash
# Aplica un perfil del equipo en ESTE ordenador (Claude Code).
# Uso: bash perfiles/aplicar-perfil.sh diseno|ingenieria|director-creativo [--dry-run]
# Activa/desactiva plugins solo en este equipo (scope user): la cuenta compartida no cambia.
# Plugins que no aparecen en ninguna lista del perfil no se tocan.
set -euo pipefail

PERFIL="${1:-}"; DRY="${2:-}"
DIR="$(cd "$(dirname "$0")" && pwd)"

# Listas ON/OFF de cada perfil: perfiles.json (las comparten Mac y Windows).
python3 -c 'import json,sys; sys.exit(0 if sys.argv[2] in json.load(open(sys.argv[1])) else 1)' "$DIR/perfiles.json" "$PERFIL" 2>/dev/null \
  || { echo "Uso: $0 diseno|ingenieria|director-creativo [--dry-run]"; exit 1; }
ON="$(python3 -c 'import json,sys; print(" ".join(json.load(open(sys.argv[1]))[sys.argv[2]]["on"]))' "$DIR/perfiles.json" "$PERFIL")"
OFF="$(python3 -c 'import json,sys; print(" ".join(json.load(open(sys.argv[1]))[sys.argv[2]]["off"]))' "$DIR/perfiles.json" "$PERFIL")"

command -v claude >/dev/null || export PATH="$HOME/.local/bin:$PATH"  # instalador nativo
command -v claude >/dev/null || { echo "No encuentro el comando 'claude'. Instala Claude Code primero."; exit 1; }

# Empareja cada nombre del perfil con el id real (nombre@marketplace) instalado en este equipo.
PLAN="$(claude plugin list --json | ON="$ON" OFF="$OFF" DEPS="$DIR/dependencias.json" python3 -c '
import json, os, sys
plugins = json.load(sys.stdin)
def norm(s): return s.lower().replace("_", "-").replace(" ", "-")
# Dependencias que faltan a plugins del perfil: solo las aprobadas en dependencias.json
aprobadas = json.load(open(os.environ["DEPS"])) if os.path.exists(os.environ["DEPS"]) else {}
vistas = set()
for p in plugins:
    if norm(p["id"].split("@")[0]) not in os.environ["ON"].split(): continue
    for e in p.get("errorDetails") or []:
        dep = e.get("dependency")
        if e.get("type") != "dependency-unsatisfied" or dep in vistas: continue
        vistas.add(dep)
        print(("dep " + aprobadas[dep] + " " + dep) if dep in aprobadas else ("depnoaprobada " + dep))
for accion, var in (("enable", "ON"), ("disable", "OFF")):
    for clave in os.environ[var].split():
        ids = [p["id"] for p in plugins if norm(p["id"].split("@")[0]) == clave]
        if not ids:
            print("falta", clave)
        for i in ids:
            pl = next(p for p in plugins if p["id"] == i)
            # con errores, "enabled" no refleja el ajuste guardado: aplicar siempre
            bien = pl["enabled"] == (accion == "enable") and not pl.get("errors")
            print(("ya " + i) if bien else (accion + " " + i))
')"

while read -r accion id extra; do
  [ -z "$accion" ] && continue
  if [ "$accion" = "depnoaprobada" ]; then echo "  ⚠ falta la dependencia $id y no está en dependencias.json (no se instala)"; continue; fi
  if [ "$accion" = "dep" ]; then
    if [ "$DRY" = "--dry-run" ]; then echo "  [simulación] instalar dependencia $extra (de $id)"; continue; fi
    claude plugin marketplace add "$id" >/dev/null 2>&1 || true  # puede existir ya
    claude plugin install "$extra" --scope user >/dev/null 2>&1 && echo "  ✓ dependencia instalada: $extra" || echo "  ✗ no se pudo instalar la dependencia $extra"
    continue
  fi
  if [ "$accion" = "falta" ]; then echo "  · $id: no está instalado en este equipo (se ignora)"; continue; fi
  if [ "$accion" = "ya" ]; then echo "  = $id ya estaba como debe"; continue; fi
  if [ "$DRY" = "--dry-run" ]; then echo "  [simulación] $accion $id"; continue; fi
  if ERR="$(claude plugin "$accion" "$id" --scope user 2>&1)"; then echo "  ✓ $accion $id"
  else echo "  ✗ no se pudo: $accion $id → $(echo "$ERR" | tail -1)"; fi
done <<< "$PLAN"

# Verificación: lo que debía quedar activo, ¿lo está? (p. ej. falta una dependencia)
if [ "$DRY" != "--dry-run" ]; then
  claude plugin list --json | ON="$ON" python3 -c '
import json, os, sys
on = set(os.environ["ON"].split())
for p in json.load(sys.stdin):
    if p["id"].split("@")[0].lower() in on and not p["enabled"]:
        print("  ⚠ " + p["id"] + " sigue desactivado: " + "; ".join(p.get("errors") or ["motivo desconocido"]))
'
fi

# Skills del equipo
if [ "$DRY" != "--dry-run" ]; then
  mkdir -p "$HOME/.claude/skills"
  cp -R "$DIR/skills-equipo/"* "$HOME/.claude/skills/"
  echo "  ✓ skills del equipo copiadas a ~/.claude/skills"
  # Instrucciones del perfil en ~/.claude/CLAUDE.md, entre marcas (no toca el resto del archivo)
  if [ -f "$DIR/$PERFIL/.claude/CLAUDE.md" ]; then
    python3 - "$DIR/$PERFIL/.claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md" <<'PY'
import os, re, sys
src, dst = sys.argv[1:3]
bloque = "<!-- perfil-equipo:inicio -->\n" + open(src).read().strip() + "\n<!-- perfil-equipo:fin -->\n"
s = open(dst).read() if os.path.exists(dst) else ""
patron = re.compile(r"<!-- perfil-equipo:inicio -->.*?<!-- perfil-equipo:fin -->\n?", re.S)
s = patron.sub(lambda m: bloque, s) if patron.search(s) else (s.rstrip() + "\n\n" + bloque if s.strip() else bloque)
open(dst, "w").write(s)
PY
    echo "  ✓ instrucciones del perfil en ~/.claude/CLAUDE.md"
  fi
  # Skills propias del perfil (p. ej. la selección de ECC en ingenieria/.claude/skills)
  if [ -d "$DIR/$PERFIL/.claude/skills" ]; then
    cp -R "$DIR/$PERFIL/.claude/skills/"* "$HOME/.claude/skills/"
    echo "  ✓ skills del perfil copiadas ($(ls "$DIR/$PERFIL/.claude/skills" | wc -l | tr -d ' '))"
  fi
fi

echo
[ "$DRY" = "--dry-run" ] && { echo "Simulación terminada: no se ha cambiado nada."; exit 0; }
echo "Perfil '$PERFIL' aplicado. Reinicia Claude Code."
echo "Para ver lo que pesa cada plugin: claude plugin details <nombre@marketplace>"
