# Traspaso: perfiles de Claude del estudio

Este documento resume una conversación larga (25-11-2026) para que otro Claude la continúe sin repetir nada. Primero léelo entero; después, `perfiles/DOCUMENTACION.md` para el detalle técnico.

## 1. Quién y qué

- **Equipo de diseño de 5 personas** que comparte **un solo usuario** de Claude (cuenta de empresa):
  - 3 diseñadores: Adobe, Canva, Figma, imagen y vídeo con IA (Higgsfield, Magnific) y maquetación en WordPress con **Betheme** y **WPBakery**.
  - **Quien te habla** (perfil Ingeniería): todo lo anterior salvo Adobe, más backend (Perl, Laravel, PHP/WordPress) y automatizaciones **n8n**.
  - **Rubén**, director creativo: todo menos backend profundo. Usa Marketing, no usa Klaviyo ni Slack. Su mesa es **Windows**.
- **Objetivo:** que cada persona tenga solo lo que necesita, gaste menos tokens y que configurar sus mesas cueste una sola visita.
- **Repositorio:** `llorente96/Diseno`, rama `claude/upbeat-einstein-sa9u96`, carpeta `perfiles/`.

## 2. Cómo trabaja quien te habla

- En español, directo y por pasos. Comandos **uno por bloque**, en orden, listos para copiar, y **separados para Mac y Windows**.
- Pega salidas de terminal y espera que las interpretes: qué fue bien, qué falló y el siguiente comando.
- Prefiere que las cosas se automaticen ("unificado, que no haga falta hacerlo a mano").
- Antes de instalar, desinstalar, subir cambios o tocar la cuenta: **confirma con la persona**.

## 3. Decisiones tomadas (y por qué)

| Decisión | Motivo |
|---|---|
| **Impeccable** para todos | Comandos de revisión y pulido (`critique`, `audit`, `polish`) |
| **Taste Skill** fuera | Genera webs completas desde cero; no encaja con Betheme o WPBakery |
| **Superpowers** fuera | Obliga a planificar en cada respuesta, choca con Ponytail y se solapa con ECC |
| **Ponytail** solo en Ingeniería | Reduce el código escrito, no los tokens de diseño. Rubén puede activarlo a mano en temporadas con mucho código |
| **ECC completo** fuera (328 skills) | En su lugar, una selección de 17 skills de backend instaladas en la mesa de Ingeniería, más sus reglas por proyecto (tipo `backend`) |
| **Marketing** solo para Rubén | ~870 tokens por sesión a cambio de `brand-review`, `seo-audit`, `campaign-plan` y `email-sequence` |
| **WordPress Dev Skills** solo en proyectos WordPress | Pesa ~9.400 tokens, más ~1.900 de su dependencia. Está apagado en todas las mesas y lo activa el tipo de trabajo `wordpress` |
| **Adobe, Canva e image-generation** solo en proyectos de diseño gráfico | Adobe pesa ~6.000 tokens. Los activa el tipo `diseno-grafico` |
| Sales, Human Resources, social-media-skills fuera | Nadie los usa |

## 4. Cómo funciona (dos niveles)

1. **Perfil = quién eres** → una vez por ordenador con `instalar-mesa` (`.sh` en Mac, `.ps1` en Windows). Hace cuatro cosas:
   - Aplica las listas `on`/`off` de `perfiles.json` a nivel de usuario (`--scope user`), sin tocar la cuenta compartida.
   - Copia las skills del equipo y las del perfil.
   - Escribe las instrucciones del perfil en `~/.claude/CLAUDE.md`, entre marcas.
   - Deja un **hook** de inicio de sesión: una vez al día hace `git pull` y reaplica el perfil si cambió algo en `perfiles/`.
2. **Tipo de trabajo = qué proyecto es** → una vez por proyecto con `preparar-proyecto` (`wordpress`, `diseno-grafico`, `automatizacion`, `backend`, combinables). Escribe en el `.claude/` del proyecto:
   - Sus instrucciones.
   - Los plugins que **solo** se activan ahí (`enabledPlugins` del proyecto, que se impone al perfil; comprobado).
   - Las reglas, en el caso de `backend`.

   Si un plugin del tipo no está en el ordenador y está aprobado en `dependencias.json`, lo instala y lo deja apagado fuera de los proyectos que lo piden.

- **Solo controla Claude Code.** En la app de Claude (escritorio o web), los plugins son de la cuenta y los compartís todos. Allí, un Proyecto por perfil con su `CLAUDE.md` como instrucciones.
- Skills del equipo (`skills-equipo/`): `mejorar-prompt-imagen`, `revision-diseno`, `wp-betheme-wpbakery` y `asesor-plugins`. Esta última busca en el catálogo (~3.800 plugins) con `buscar-plugins.sh`, mide tokens y propone cambios de perfil.

## 5. Estado de cada mesa

| Mesa | Sistema | Estado |
|---|---|---|
| iMac de quien te habla | Mac | **Configurada** con `ingenieria` (hook instalado, skills de ECC copiadas, dependencia de WordPress instalada). Al abrir Claude Code recibirá los últimos cambios: WordPress Dev Skills pasa a solo proyectos |
| Rubén | Windows | **A medias.** Repositorio clonado y simulación correcta (activará Impeccable y apagará Ponytail y Taste). Falta: añadir `%USERPROFILE%\.local\bin` al PATH, reabrir PowerShell y ejecutar `instalar-mesa.ps1 -Perfil director-creativo`. **Es la primera vez que se ejecutan de verdad los `.ps1` de instalación y del hook** |
| 3 diseñadores | ? | Sin empezar. Perfil `diseno` |

Para ver una mesa: `ver-mesa.sh` (Mac) o `ver-mesa.ps1` (Windows).

## 6. Pendiente

1. Terminar la mesa de Rubén (sección 5) y revisar su salida.
2. Configurar las mesas de los 3 diseñadores con `guia-instalacion.html` o `GUIA-INSTALACION.md`.
3. Primer proyecto WordPress y primero de diseño gráfico con `preparar-proyecto`. Medir el peso real con `claude plugin details adobe@anthropic-plugin-directory`. Si Adobe y Canva se usan a diario, valorar pasarlos al perfil de Diseño.
4. Reconectar **html.to.design** en la cuenta. Opcional: WordPress.com, Microsoft 365 y Gamma, si se usan.
5. Decidir si `productivity` y `slack-by-salesforce` (plugins) se apagan. Ahora los scripts no los tocan.
6. Seguridad: el hook ejecuta código del repositorio, que parece público. Que solo una persona pueda escribir en él y proteger la rama.

## 7. Cómo hacer cambios sin romper nada

- Lo que lleva cada perfil: `perfiles/perfiles.json`. Lo que lleva cada tipo: `perfiles/trabajos/<tipo>/.claude/`. Plugins que se instalan solos: `perfiles/dependencias.json`.
- Mac y Windows: toca **los dos scripts** (`.sh` y `.ps1`). Los `.ps1` deben ser **solo ASCII**, porque Windows PowerShell 5.1 los lee como ANSI.
- Antes de subir: `bash perfiles/tests/test-scripts.sh` (51 tests con un `claude` falso; deben pasar todos).
- Actualiza `DOCUMENTACION.md`, `ESQUEMA.md` y las dos guías HTML si cambia algo visible.
- Commit y push a `claude/upbeat-einstein-sa9u96`. Las mesas lo reciben solas.

## 8. Errores ya vistos (no repetirlos)

- Copiar `PERFIL` tal cual: la guía HTML rellena el perfil sola.
- Repositorio desactualizado: «descargar o actualizar» es un solo comando.
- `cd` a carpetas equivocadas: las guías usan rutas completas.
- `bash` en Windows, PATH de `claude` en Windows y tildes en `.ps1`: ya resueltos.
- Activar algo ya activo daba error: ahora se salta (`= X ya estaba como debe`) y se muestra el error real si lo hay.
- Un plugin apagado por un error podía seguir "activado" en su ajuste: ahora siempre se aplica la orden.
