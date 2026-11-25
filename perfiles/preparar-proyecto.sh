#!/usr/bin/env bash
# Prepara un proyecto para un tipo de trabajo: instrucciones, plugins activos SOLO en ese proyecto
# y, si hace falta, sus dependencias aprobadas. Se puede ejecutar varias veces y combinar tipos.
# Uso: bash perfiles/preparar-proyecto.sh wordpress|diseno-grafico|automatizacion|backend [ruta-del-proyecto]
set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"
TIPO="${1:-}"; DEST="${2:-$PWD}"
TIPOS="$(ls "$DIR/trabajos" | tr '\n' '|' | sed 's/|$//')"
KIT="$DIR/trabajos/$TIPO/.claude"
{ [ -n "$TIPO" ] && [ -d "$KIT" ]; } || { echo "Uso: $0 $TIPOS [ruta-del-proyecto]"; exit 1; }
[ -d "$DEST" ] || { echo "No existe la carpeta del proyecto: $DEST"; exit 1; }
DEST="$(cd "$DEST" && pwd)"
case "$DEST/" in "$(cd "$DIR/.." && pwd)/"*) echo "Eso es el repositorio de perfiles, no un proyecto. Indica la ruta del proyecto."; exit 1 ;; esac
command -v claude >/dev/null || export PATH="$HOME/.local/bin:$PATH"
mkdir -p "$DEST/.claude"

# 1-2. Instrucciones (bloque por tipo) y plugins del proyecto (fusiona, no pisa)
python3 - "$KIT" "$DEST/.claude" "$TIPO" <<'PY'
import json, os, re, sys
kit, dst, tipo = sys.argv[1:4]
if os.path.exists(os.path.join(kit, "CLAUDE.md")):
    ini, fin = f"<!-- trabajo:{tipo}:inicio -->", f"<!-- trabajo:{tipo}:fin -->"
    bloque = ini + "\n" + open(os.path.join(kit, "CLAUDE.md")).read().strip() + "\n" + fin + "\n"
    p = os.path.join(dst, "CLAUDE.md"); s = open(p).read() if os.path.exists(p) else ""
    patron = re.compile(re.escape(ini) + ".*?" + re.escape(fin) + "\n?", re.S)
    s = patron.sub(lambda m: bloque, s) if patron.search(s) else (s.rstrip() + "\n\n" + bloque if s.strip() else bloque)
    open(p, "w").write(s); print("  ✓ instrucciones de", tipo, "en .claude/CLAUDE.md")
if os.path.exists(os.path.join(kit, "settings.json")):
    nuevos = json.load(open(os.path.join(kit, "settings.json"))).get("enabledPlugins", {})
    p = os.path.join(dst, "settings.json")
    s = json.load(open(p)) if os.path.exists(p) and os.path.getsize(p) else {}
    s.setdefault("enabledPlugins", {}).update(nuevos)
    json.dump(s, open(p, "w"), indent=2, ensure_ascii=False)
    for k in nuevos: print("  ✓ activo solo en este proyecto:", k)
PY

# 3. Reglas del tipo (p. ej. backend)
if [ -d "$KIT/rules" ]; then cp -R "$KIT/rules" "$DEST/.claude/" && echo "  ✓ reglas copiadas a .claude/rules"; fi

# 4. Plugins del kit que no están en este ordenador: instalar si están aprobados en dependencias.json,
#    y dejarlos apagados fuera del proyecto (solo los activa el proyecto).
if [ -f "$KIT/settings.json" ]; then
  FALTAN="$(claude plugin list --json | python3 -c '
import json, sys
inst = {p["id"] for p in json.load(sys.stdin)}
kit = json.load(open(sys.argv[1])).get("enabledPlugins", {})
aprob = json.load(open(sys.argv[2]))
for k in kit:
    if k not in inst: print(("instalar " + aprob[k] + " " + k) if k in aprob else ("falta " + k))
' "$KIT/settings.json" "$DIR/dependencias.json")"
  while read -r accion a b; do
    [ -z "$accion" ] && continue
    if [ "$accion" = "falta" ]; then echo "  ⚠ $a no está en este ordenador ni en dependencias.json: no funcionará hasta instalarlo"; continue; fi
    claude plugin marketplace add "$a" >/dev/null 2>&1 || true
    if ERR="$(claude plugin install "$b" --scope user 2>&1)"; then
      claude plugin disable "$b" --scope user >/dev/null 2>&1 || true
      echo "  ✓ instalado $b (activo solo en los proyectos que lo piden)"
    else echo "  ✗ no se pudo instalar $b → $(echo "$ERR" | tail -1)"; fi
  done <<< "$FALTAN"
fi
echo
echo "Proyecto preparado para '$TIPO': $DEST"
echo "Abre Claude Code dentro de esa carpeta. Si el proyecto usa git, sube la carpeta .claude para que la tenga todo el equipo."
