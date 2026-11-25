#!/usr/bin/env bash
# Tests de los scripts de Mac/Linux con un 'claude' falso (no toca la configuración real).
# Uso: bash perfiles/tests/test-scripts.sh
set -u
PERFILES="$(cd "$(dirname "$0")/.." && pwd)"
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
PASA=0; FALLA=0
ok()   { PASA=$((PASA+1)); echo "  ✓ $1"; }
mal()  { FALLA=$((FALLA+1)); echo "  ✗ $1"; }
check(){ if eval "$2"; then ok "$1"; else mal "$1"; fi; }

# --- claude falso: plugins como los del iMac del equipo ---
mkdir -p "$TMP/stub"
cat > "$TMP/stub/claude" <<'STUB'
#!/usr/bin/env bash
case "$1 $2" in
  "plugin list") cat <<'J'
[{"id":"design@synced","enabled":true},{"id":"figma@synced","enabled":true},
 {"id":"impeccable@impeccable","enabled":false},{"id":"ponytail@ponytail","enabled":true},
 {"id":"taste-skill@taste-skill","enabled":true},{"id":"marketing@synced","enabled":true},
 {"id":"wp-dev-skills@synced","enabled":false,"errorDetails":[{"type":"dependency-unsatisfied","dependency":"wordpress-official-agent-skills@wordpress-official-agent-skills"}]},
 {"id":"document-skills@x","enabled":false,"errorDetails":[{"type":"dependency-unsatisfied","dependency":"desconocida@nadie"}]},
 {"id":"otro-plugin@x","enabled":true}]
J
  ;;
  "plugin enable"|"plugin disable"|"plugin install") echo "$2 $3 $4 $5" >> "$CALLS" ;;
  "plugin marketplace") echo "marketplace $3 $4" >> "$CALLS" ;;
  "plugin details") echo "  Always-on:   ~123 tok   added to every session" ;;
  "mcp list") echo "No MCP servers configured." ;;
esac
STUB
chmod +x "$TMP/stub/claude"

nuevo_home() { export HOME="$TMP/home-$1"; mkdir -p "$HOME"; export CALLS="$TMP/calls-$1"; : > "$CALLS"; }
export PATH="$TMP/stub:$PATH"

echo "1. Simulación (director-creativo)"
nuevo_home 1
OUT="$(bash "$PERFILES/aplicar-perfil.sh" director-creativo --dry-run)"
check "activa impeccable"        'grep -q "enable impeccable@impeccable" <<<"$OUT"'
check "apaga ponytail"           'grep -q "disable ponytail@ponytail" <<<"$OUT"'
check "apaga taste-skill"        'grep -q "disable taste-skill@taste-skill" <<<"$OUT"'
check "mantiene marketing"       'grep -q "enable marketing@synced" <<<"$OUT"'
check "no cambia nada"           '[ ! -s "$CALLS" ]'
check "no toca plugins ajenos"   '! grep -q "otro-plugin" <<<"$OUT"'
check "simula instalar la dependencia aprobada" 'grep -q "instalar dependencia wordpress-official-agent-skills" <<<"$OUT"'
check "no instala dependencias no aprobadas" 'grep -q "desconocida@nadie y no está en dependencias.json" <<<"$OUT"'
check "mensaje de simulación"    'grep -q "no se ha cambiado nada" <<<"$OUT"'

echo "2. Aplicar de verdad (diseno)"
nuevo_home 2
OUT="$(bash "$PERFILES/aplicar-perfil.sh" diseno)"
check "avisa si algo sigue apagado" 'grep -q "wp-dev-skills@synced sigue desactivado" <<<"$OUT"'
check "añade el marketplace de la dependencia" 'grep -q "marketplace add mralaminahamed/wordpress-official-agent-skills" "$CALLS"'
check "instala la dependencia aprobada" 'grep -q "install wordpress-official-agent-skills@wordpress-official-agent-skills --scope user" "$CALLS"'
check "nunca instala la no aprobada" '! grep -q "desconocida" "$CALLS"'
check "desactiva marketing"      'grep -q "disable marketing@synced --scope user" "$CALLS"'
check "activa wp-dev-skills"     'grep -q "enable wp-dev-skills@synced --scope user" "$CALLS"'
check "copia skills del equipo"  '[ -f "$HOME/.claude/skills/revision-diseno/SKILL.md" ]'

echo "3. Perfil inválido"
nuevo_home 3
bash "$PERFILES/aplicar-perfil.sh" jefe >/dev/null 2>&1; RC=$?
check "sale con error"           '[ $RC -ne 0 ]'

echo "4. claude fuera del PATH (instalador nativo en ~/.local/bin)"
nuevo_home 4
mkdir -p "$HOME/.local/bin" && cp "$TMP/stub/claude" "$HOME/.local/bin/"
OUT="$(PATH="/usr/bin:/bin" bash "$PERFILES/aplicar-perfil.sh" diseno --dry-run 2>&1)"
check "lo encuentra igualmente"  'grep -q "simulación" <<<"$OUT"'

echo "5. instalar-mesa: hook sin duplicar ni borrar ajustes"
nuevo_home 5
mkdir -p "$HOME/.claude"
echo '{"theme":"dark","hooks":{"SessionStart":[{"hooks":[{"type":"command","command":"echo otro"}]}]}}' > "$HOME/.claude/settings.json"
bash "$PERFILES/instalar-mesa.sh" director-creativo >/dev/null
bash "$PERFILES/instalar-mesa.sh" director-creativo >/dev/null
N=$(python3 -c 'import json,os;s=json.load(open(os.path.expanduser("~/.claude/settings.json")));print(sum("actualizar-perfil" in h["command"] for g in s["hooks"]["SessionStart"] for h in g["hooks"]))')
check "un solo hook tras 2 instalaciones" '[ "$N" = 1 ]'
check "conserva el tema"         'grep -q "\"theme\": \"dark\"" "$HOME/.claude/settings.json"'
check "conserva el hook existente" 'grep -q "echo otro" "$HOME/.claude/settings.json"'
check "guarda el perfil"         'grep -q "PERFIL=director-creativo" "$HOME/.claude/perfil-equipo"'

echo "6. actualizar-perfil: baja cambios y reaplica"
nuevo_home 6
git clone -q "$(cd "$PERFILES/.." && pwd)" "$TMP/origen" && git -C "$TMP/origen" checkout -q -B main
git clone -q "$TMP/origen" "$TMP/mesa"
bash "$TMP/mesa/perfiles/instalar-mesa.sh" diseno >/dev/null; : > "$CALLS"
bash "$TMP/mesa/perfiles/actualizar-perfil.sh"; sleep 2
check "sin cambios no reaplica"  '[ ! -s "$CALLS" ]'
rm -f "$HOME/.claude/perfil-equipo.ultimo"
python3 -c 'import json,sys;p=sys.argv[1];d=json.load(open(p));d["diseno"]["off"].remove("marketing");d["diseno"]["on"].append("marketing");json.dump(d,open(p,"w"),indent=2)' "$TMP/origen/perfiles/perfiles.json"
git -C "$TMP/origen" -c user.name=t -c user.email=t@t commit -qam "cambio de perfil"
bash "$TMP/mesa/perfiles/actualizar-perfil.sh"
for _ in $(seq 20); do [ -s "$CALLS" ] && break; sleep 0.5; done; sleep 1
check "con cambios reaplica"     '[ -s "$CALLS" ]'
: > "$CALLS"; bash "$TMP/mesa/perfiles/actualizar-perfil.sh"; sleep 2
check "solo una vez al día"      '[ ! -s "$CALLS" ]'

echo "7. actualizar-perfil sin mesa configurada"
nuevo_home 7
bash "$PERFILES/actualizar-perfil.sh"; RC=$?
check "no hace nada y no falla"  '[ $RC -eq 0 ] && [ ! -s "$CALLS" ]'

echo "8. ver-mesa"
nuevo_home 8
OUT="$(bash "$PERFILES/ver-mesa.sh" 2>&1)"
check "muestra tokens"           'grep -q "~123 tokens" <<<"$OUT"'

echo "9. perfiles.json"
check "JSON válido con 3 perfiles" 'python3 -c "import json,sys;d=json.load(open(\"$PERFILES/perfiles.json\"));sys.exit(0 if set(d)=={\"diseno\",\"ingenieria\",\"director-creativo\"} else 1)"'
check "ningún plugin en ON y OFF a la vez" 'python3 -c "import json,sys;d=json.load(open(\"$PERFILES/perfiles.json\"));sys.exit(1 if any(set(p[\"on\"])&set(p[\"off\"]) for p in d.values()) else 0)"'
check "scripts .ps1 solo ASCII"  '! LC_ALL=C grep -qP "[^\x00-\x7F]" "$PERFILES"/*.ps1'

echo; echo "Resultado: $PASA pasan, $FALLA fallan"
[ "$FALLA" -eq 0 ]
