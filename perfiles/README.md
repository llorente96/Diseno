# Perfiles de Claude del equipo

| Perfil | Quién | Carpeta |
|---|---|---|
| Diseño | 3 diseñadores | `diseno/` |
| Ingeniería | Diseño (sin Adobe) + backend (Perl, Laravel, PHP/WordPress) + n8n | `ingenieria/` |
| Dirección creativa | Rubén: todo menos backend profundo | `direccion/` |

## Base común (los 5)

| Pieza | Para quién | Por qué |
|---|---|---|
| **Impeccable** | Todos | Comandos de revisión y pulido de diseño (`critique`, `audit`, `polish`, `bolder`, `quieter`...). |
| Skills del equipo (`skills-equipo/`) | Todos | `mejorar-prompt-imagen`, `revision-diseno`, `wp-betheme-wpbakery` |
| **Ponytail** | Solo Ingeniería | Reduce el código que se escribe, no los tokens de diseño. Además añade instrucciones al inicio de cada sesión. |
| **ECC (selección)** | Solo Ingeniería | Ya preparado en `ingenieria/.claude/`. |

Descartados:
- **Taste Skill**: genera webs completas desde cero con scripts de Node y Chrome. No encaja con maquetar en Betheme o WPBakery.
- **Superpowers**: obliga a planificar antes de cada respuesta, lo que gasta tokens en tareas de diseño. Además choca con Ponytail y se solapa con ECC.

## Instalación en Claude Code

Plugins oficiales (`design`, `canva`, `figma`, `frontend-design`, Adobe): instálalos con `/plugin` en Claude Code o desde el apartado de Plugins de claude.ai.

Impeccable (todos):

```
/plugin marketplace add pbakaus/impeccable
```

Después abre `/plugin` e instala Impeccable. Si su instalador ofrece el "design hook", los diseñadores pueden rechazarlo.

Ponytail (solo Ingeniería):

```
/plugin marketplace add DietrichGebert/ponytail
/plugin install ponytail@ponytail
```

Skills del equipo: copia cada carpeta de `skills-equipo/` a `~/.claude/skills/`. En claude.ai, súbelas comprimidas en `.zip` en el apartado de Skills.

Perfil del proyecto: copia la carpeta `.claude/` del perfil a la raíz de cada proyecto.

## Ahorrar tokens

- Activa solo lo de tu perfil: cada plugin y conector suma contexto a cada mensaje.
- Una tarea por conversación (`/clear` al cambiar de tarea).
- Da el enlace exacto (frame de Figma con node-id, diseño de Canva).
- Nombra la skill que quieres usar.
- Sonnet para el día a día; Opus solo para lo complejo.
