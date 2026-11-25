# Perfiles de Claude del estudio: documentación

Estado a 25-11-2026. Rama `claude/upbeat-einstein-sa9u96` del repositorio `llorente96/Diseno`.

## 1. El problema

- 5 personas (3 diseñadores, ingeniería y director creativo) comparten **un solo usuario** de Claude.
- La cuenta acumulaba plugins que se solapaban (Superpowers, Ponytail, ECC completo, Taste, Impeccable) o que nadie usaba (Sales, Human Resources).
- Cada plugin activo añade tokens **a cada sesión**, antes de escribir nada. Medido con `claude plugin details`:

| Plugin | Tokens por sesión |
|---|---|
| social-media-skills | ~35.500 |
| Adobe (plugin) | ~6.000 |
| wordpress-devkit | ~1.400 |
| Canva | ~1.000 |
| Marketing | ~870 |
| Superpowers | ~850 |
| Ponytail | ~430–640 |
| Design | ~620 |
| Impeccable | ~250 |
| Taste | ~235 |

## 2. La solución

1. **Tres perfiles**, definidos en un único archivo: `perfiles.json` (listas `on` y `off`).
2. **Cada ordenador aplica su perfil** en Claude Code a nivel de usuario (`--scope user`), sin tocar la cuenta compartida. Los plugins que no están en ninguna lista no se tocan.
3. **Actualización automática**: un hook de inicio de sesión baja los cambios del repositorio una vez al día y, si cambió algo en `perfiles/`, reaplica el perfil. Configuras cada mesa una vez; después basta con subir cambios al repositorio.
4. **Skills propias del equipo** en `skills-equipo/`.

### Límite importante: app de Claude vs Claude Code

- Los scripts controlan **Claude Code** (terminal) en cada ordenador.
- En la **app de Claude** (escritorio o web), los plugins y conectores son de la cuenta y los compartís los cinco. No se pueden separar por persona.
- En la app, lo más parecido a un perfil es crear un **Proyecto por perfil**, con el `CLAUDE.md` del perfil como instrucciones.

## 3. Perfiles

| | Diseño (3) | Ingeniería | Director creativo (Rubén) |
|---|---|---|---|
| Design, Figma, Impeccable | ✅ | ✅ | ✅ |
| WordPress Dev Skills (+ su dependencia) | ✅ | ✅ | ✅ |
| Document skills, PDF Viewer | ✅ | ✅ | ✅ |
| Marketing | ❌ | ❌ | ✅ |
| Ponytail | ❌ | ✅ | ❌ (activable a mano) |
| Claude api | ❌ | ✅ | ❌ |
| ECC | ❌ | Selección de 17 skills en `ingenieria/.claude/` | ❌ |
| Superpowers, Taste, Sales, HR, social-media-skills | ❌ | ❌ | ❌ |
| Adobe (plugin) | – | ❌ | – |

Decisiones y motivos:
- **Impeccable** para todos: trae comandos de revisión y pulido (`critique`, `audit`, `polish`).
- **Taste fuera**: genera webs completas desde cero; no encaja con Betheme o WPBakery.
- **Superpowers fuera**: obliga a planificar antes de cada respuesta, choca con Ponytail y se solapa con ECC.
- **Ponytail solo en Ingeniería**: reduce el código escrito, no los tokens del trabajo de diseño. Rubén puede activarlo en temporadas con mucho código (ver `director-creativo/README.md`).
- **ECC completo fuera** (328 skills). En su lugar, una selección de 17 skills de backend (Perl, Laravel, API, MySQL, seguridad, TDD), solo Markdown, que se copia por proyecto.
- **Marketing para Rubén**: ~870 tokens por sesión a cambio de `brand-review`, `seo-audit`, `campaign-plan` y `email-sequence`.

Conectores (de la cuenta, compartidos): Canva, Figma, Adobe, Magnific, Higgsfield, Google Drive, n8n, GitHub, Klaviyo, Slack, html.to.design (sesión caducada: reconectar) y los servidores MCP locales de WordPress.

## 4. Archivos

| Archivo | Para qué |
|---|---|
| `perfiles.json` | **Única fuente** de qué lleva cada perfil |
| `dependencias.json` | Dependencias aprobadas que los scripts instalan solos si faltan (hoy: la de WordPress Dev Skills) |
| `aplicar-perfil.sh` / `.ps1` | Aplica un perfil en ese ordenador (Mac / Windows) |
| `instalar-mesa.sh` / `.ps1` | Configura una mesa una vez: perfil, skills y hook de actualización |
| `actualizar-perfil.sh` / `.ps1` | Lo ejecuta el hook: una vez al día, `git pull` y reaplica si cambió algo |
| `ver-mesa.sh` / `.ps1` | Muestra la configuración de una mesa, sin claves |
| `buscar-plugins.sh` | Busca en el catálogo completo (~3.800 plugins) sin gastar tokens |
| `skills-equipo/` | `mejorar-prompt-imagen`, `revision-diseno`, `wp-betheme-wpbakery`, `asesor-plugins` |
| `diseno/`, `ingenieria/`, `director-creativo/` | `.claude/` para copiar en cada proyecto, más un README |
| `MAC.md`, `WINDOWS.md` | Pasos de instalación por sistema |
| `ESQUEMA.md` | Resumen de una página |
| `PARA-EL-OTRO-CLAUDE.md` | Traspaso para el Claude de la cuenta de empresa |
| `guia-equipo.html` | Guía visual para el equipo |
| `tests/test-scripts.sh` | Tests de los scripts de Mac con un `claude` falso |

En cada mesa:
- `~/.claude/perfil-equipo` (Mac) o `perfil-equipo.json` (Windows): perfil y ruta del repositorio.
- `~/.claude/perfil-equipo.ultimo`: fecha de la última comprobación.
- `~/.claude/perfil-equipo.log`: salida de la última reaplicación automática.

## 5. Cómo se hace cada cosa

- **Configurar una mesa:** `MAC.md` o `WINDOWS.md`.
- **Cambiar un perfil:**
  1. Pide a Claude "usa asesor-plugins: …".
  2. Edita `perfiles.json`, más `ESQUEMA.md` y la guía.
  3. Pasa los tests: `bash perfiles/tests/test-scripts.sh`.
  4. Haz commit y push. Las mesas lo aplican solas al abrir Claude Code.
- **Cambiar de perfil una mesa:** vuelve a ejecutar `instalar-mesa` con el nuevo perfil.
- **Ver una mesa:** `ver-mesa.sh` (Mac) o `ver-mesa.ps1` (Windows).
- **Desinstalar de una mesa:**
  1. Borra `~/.claude/perfil-equipo*`. Sin ese archivo, el hook no hace nada.
  2. Opcional: quita la entrada `actualizar-perfil` de `hooks.SessionStart` en `~/.claude/settings.json`.

## 6. Problemas encontrados y su solución

| Síntoma | Causa | Solución |
|---|---|---|
| Windows: `Falta la cadena en el terminador` | PowerShell 5.1 lee los scripts como ANSI y "✓" rompía las comillas | Scripts `.ps1` solo con ASCII (hay un test que lo vigila) |
| Windows: `No encuentro el comando 'claude'` | El instalador deja `claude.exe` en `%USERPROFILE%\.local\bin`, fuera del PATH | Los scripts lo buscan ahí solos. Para la terminal, añadirlo al PATH (ver `WINDOWS.md`) |
| `El argumento 'perfiles\…' no existe` | Ejecutado desde otra carpeta | Los comandos de `WINDOWS.md` usan rutas completas |
| `curl … \| bash`: bash no se reconoce | Es el instalador de Mac/Linux | En Windows: `irm https://claude.ai/install.ps1 \| iex` |
| WordPress Dev Skills sigue desactivado tras activarlo | Depende de `wordpress-official-agent-skills`, que no estaba instalado | **Automático**: el script instala la dependencia porque está aprobada en `dependencias.json`. Si un plugin pide otra no aprobada, solo avisa |
| Windows: el script se corta a mitad sin motivo claro | Con `ErrorActionPreference = Stop`, PowerShell 5.1 trata cualquier aviso de `claude` como error | `aplicar-perfil.ps1` usa `Continue` |
| `cd Diseno`: no existe | Ya estabas dentro de `Diseno` | Ignorarlo |

## 7. Pendientes

1. ~~Instalar la dependencia de WordPress Dev Skills~~: ahora la instala el script automáticamente.
2. **Mesa de Rubén (Windows):** añadir `.local\bin` al PATH, reiniciar PowerShell y ejecutar `instalar-mesa.ps1 -Perfil director-creativo`.
3. **Reconectar html.to.design** en la cuenta.
4. **Probar `instalar-mesa.ps1` y el hook en Windows**: no se han podido probar fuera de una mesa real.
5. Decidir si Productivity y Slack (plugin) se quedan; ahora el script no los toca.

## 8. Seguridad

- **Dependencias:** solo se instalan automáticamente las que figuran en `dependencias.json`. Añadir una ahí equivale a aprobar ese plugin de terceros para todas las mesas.

- **El hook ejecuta código del repositorio.** Quien pueda hacer push a `llorente96/Diseno` puede ejecutar código en las 5 mesas la próxima vez que abran Claude Code. Medidas:
  - Que solo una persona tenga permiso de escritura.
  - Proteger la rama `claude/upbeat-einstein-sa9u96` en GitHub.
  - Revisar cada cambio en `perfiles/*.sh` y `*.ps1`.
- **El repositorio parece público**, porque se clonó sin pedir credenciales: cualquiera puede leerlo. No contiene claves, pero sí nombres y la organización del equipo. Si se hace privado, cada mesa necesita credenciales de GitHub guardadas para que funcione el `git pull` automático.
- **`ver-mesa` no muestra claves**: de `settings.json` solo saca plugins, hooks y modelo.
- **Plugins de comunidad** (Ponytail, Impeccable, Taste, ECC, WordPress Dev Skills): revisa sus hooks antes de activarlos. Impeccable consulta impeccable.style al empezar un diseño nuevo, aunque se desactive la telemetría.
- **Cuenta compartida**: las condiciones de Anthropic normalmente no permiten compartir el inicio de sesión. Además, se mezclan historial, memoria y conectores. Con el plan Team cada persona tendría su propio usuario y un administrador compartiría los plugins.

## 9. Verificación (método ECC: verification-loop)

| Fase | Resultado |
|---|---|
| Sintaxis bash (`bash -n`) | OK |
| Tests (`tests/test-scripts.sh`) | 30/30 pasan: simulación, aplicación real, perfil inválido, `claude` fuera del PATH, hook sin duplicados y sin borrar ajustes, actualización con y sin cambios, límite diario, `ver-mesa`, coherencia de `perfiles.json`, `.ps1` en ASCII, aviso de plugins que siguen apagados, instalación de dependencias aprobadas y bloqueo de las no aprobadas |
| Búsqueda de claves | Ninguna en scripts ni JSON |
| PowerShell | **Sin probar** (no hay PowerShell en este entorno). Validado en la mesa de Rubén: `aplicar-perfil.ps1 -Simular` funciona |
| Aplicado en el Claude Code de esta sesión (perfil Ingeniería) | OK. La dependencia de WordPress Dev Skills no se pudo instalar aquí (el entorno bloquea plugins de terceros); en las mesas la instala el script |
