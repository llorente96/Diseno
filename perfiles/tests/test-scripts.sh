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
[{"id":"design@synced","enabled":true},{"id":"figma@synced","enabled":true,"errorDetails":[{"type":"dependency-unsatisfied","dependency":"wordpress-official-agent-skills@wordpress-official-agent-skills"}]},
 {"id":"impeccable@impeccable","enabled":false},{"id":"ponytail@ponytail","enabled":true},
 {"id":"taste-skill@taste-skill","enabled":true},{"id":"marketing@synced","enabled":true},
 {"id":"wp-dev-skills@synced","enabled":false,"errors":["Dependency missing"],"errorDetails":[{"type":"dependency-unsatisfied","dependency":"wordpress-official-agent-skills@wordpress-official-agent-skills"}]},
 {"id":"document-skills@x","enabled":false,"errorDetails":[{"type":"dependency-unsatisfied","dependency":"desconocida@nadie"}]},
 {"id":"otro-plugin@x","enabled":true}]
J
  ;;
  "plugin enable"|"plugin disable"|"plugin install")
    if [ "$3" = "impeccable@impeccable" ]; then echo "Error: simulated failure" >&2; exit 1; fi
    echo "$2 $3 $4 $5" >> "$CALLS" ;;
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
check "no toca lo que ya está bien" 'grep -q "marketing@synced ya estaba como debe" <<<"$OUT"'
check "no cambia nada"           '[ ! -s "$CALLS" ]'
check "no toca plugins ajenos"   '! grep -q "otro-plugin" <<<"$OUT"'
check "simula instalar la dependencia aprobada" 'grep -q "instalar dependencia wordpress-official-agent-skills" <<<"$OUT"'
check "no instala dependencias no aprobadas" 'grep -q "desconocida@nadie y no está en dependencias.json" <<<"$OUT"'
check "mensaje de simulación"    'grep -q "no se ha cambiado nada" <<<"$OUT"'

echo "2. Aplicar de verdad (diseno)"
nuevo_home 2
OUT="$(bash "$PERFILES/aplicar-perfil.sh" diseno)"
check "avisa si algo sigue apagado" 'grep -q "document-skills@x sigue desactivado" <<<"$OUT"'
check "WordPress Dev Skills apagado en el ordenador" '! grep -q "enable wp-dev-skills" "$CALLS"'
check "apaga de verdad un plugin con errores" 'grep -q "disable wp-dev-skills@synced --scope user" "$CALLS"'
check "muestra el error real si algo falla" 'grep -q "no se pudo: enable impeccable@impeccable → Error: simulated failure" <<<"$OUT"'
check "añade el marketplace de la dependencia" 'grep -q "marketplace add mralaminahamed/wordpress-official-agent-skills" "$CALLS"'
check "instala la dependencia aprobada" 'grep -q "install wordpress-official-agent-skills@wordpress-official-agent-skills --scope user" "$CALLS"'
check "nunca instala la no aprobada" '! grep -q "desconocida" "$CALLS"'
check "desactiva marketing"      'grep -q "disable marketing@synced --scope user" "$CALLS"'
check "copia skills del equipo"  '[ -f "$HOME/.claude/skills/revision-diseno/SKILL.md" ]'

echo "2b. Ingeniería instala la selección de ECC"
nuevo_home 2b
bash "$PERFILES/aplicar-perfil.sh" ingenieria >/dev/null
check "laravel-tdd instalada"    '[ -f "$HOME/.claude/skills/laravel-tdd/SKILL.md" ]'
check "perl-patterns instalada"  '[ -f "$HOME/.claude/skills/perl-patterns/SKILL.md" ]'
check "17 skills de ECC + 4 del equipo" '[ "$(ls "$HOME/.claude/skills" | wc -l | tr -d " ")" = 21 ]'

echo "2c. Instrucciones del perfil en ~/.claude/CLAUDE.md"
nuevo_home 2c
mkdir -p "$HOME/.claude"; echo "Mis notas personales" > "$HOME/.claude/CLAUDE.md"
bash "$PERFILES/aplicar-perfil.sh" director-creativo >/dev/null
bash "$PERFILES/aplicar-perfil.sh" director-creativo >/dev/null
check "conserva lo que ya había"  'grep -q "Mis notas personales" "$HOME/.claude/CLAUDE.md"'
check "añade el perfil una sola vez" '[ "$(grep -c "perfil-equipo:inicio" "$HOME/.claude/CLAUDE.md")" = 1 ]'
check "contenido del perfil"      'grep -q "Perfil: Director creativo" "$HOME/.claude/CLAUDE.md"'
bash "$PERFILES/aplicar-perfil.sh" diseno >/dev/null
check "cambiar de perfil sustituye el bloque" 'grep -q "Perfil: Diseño" "$HOME/.claude/CLAUDE.md" && ! grep -q "Director creativo" "$HOME/.claude/CLAUDE.md"'

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

echo "10. preparar-proyecto"
nuevo_home 10
PROY="$TMP/proyecto-web"; mkdir -p "$PROY/.claude"
echo '{"model":"sonnet","enabledPlugins":{"otro@x":true}}' > "$PROY/.claude/settings.json"
echo "Notas del proyecto" > "$PROY/.claude/CLAUDE.md"
OUT="$(bash "$PERFILES/preparar-proyecto.sh" wordpress "$PROY")"
bash "$PERFILES/preparar-proyecto.sh" wordpress "$PROY" >/dev/null
bash "$PERFILES/preparar-proyecto.sh" diseno-grafico "$PROY" >/dev/null
J="$PROY/.claude/settings.json"
check "activa WP Dev Skills solo en el proyecto" 'grep -q "\"wp-dev-skills@synced\": true" "$J"'
check "conserva ajustes del proyecto" 'grep -q "\"model\": \"sonnet\"" "$J" && grep -q "otro@x" "$J"'
check "conserva notas del proyecto"   'grep -q "Notas del proyecto" "$PROY/.claude/CLAUDE.md"'
check "bloque WordPress una sola vez" '[ "$(grep -c "trabajo:wordpress:inicio" "$PROY/.claude/CLAUDE.md")" = 1 ]'
check "combina tipos (WordPress + gráfico)" 'grep -q "trabajo:diseno-grafico:inicio" "$PROY/.claude/CLAUDE.md"'
check "instala la dependencia aprobada que falta" 'grep -q "install wordpress-official-agent-skills@wordpress-official-agent-skills --scope user" "$CALLS"'
check "y la deja apagada fuera del proyecto" 'grep -q "disable wordpress-official-agent-skills@wordpress-official-agent-skills --scope user" "$CALLS"'
PROY2="$TMP/proyecto-api"; mkdir -p "$PROY2"
bash "$PERFILES/preparar-proyecto.sh" backend "$PROY2" >/dev/null
check "diseño gráfico activa Adobe y Canva en el proyecto" 'grep -q "adobe@anthropic-plugin-directory" "$J" && grep -q "canva@anthropic-plugin-directory" "$J"'
check "instala Canva si falta y lo deja apagado fuera" 'grep -q "install canva@anthropic-plugin-directory --scope user" "$CALLS" && grep -q "disable canva@anthropic-plugin-directory --scope user" "$CALLS"'
check "backend copia las reglas de ECC" '[ -f "$PROY2/.claude/rules/ecc/php/security.md" ]'
bash "$PERFILES/preparar-proyecto.sh" jardineria "$PROY2" >/dev/null 2>&1; RC=$?
check "tipo inválido da error" '[ $RC -ne 0 ]'
bash "$PERFILES/preparar-proyecto.sh" wordpress "$PERFILES/.." >/dev/null 2>&1; RC=$?
check "no prepara el propio repositorio" '[ $RC -ne 0 ]'

echo; echo "Resultado: $PASA pasan, $FALLA fallan"
[ "$FALLA" -eq 0 ]
