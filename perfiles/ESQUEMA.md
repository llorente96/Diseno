# Esquema rápido: perfiles Claude del estudio

Ninguno de estos pasos gasta tokens: son comandos de terminal y ajustes manuales.

## 1. Cuenta compartida (una sola vez, en claude.ai)

- Reconectar **html.to.design** (la sesión expiró).
- Se pueden desactivar para todos: **Sales**, **Human Resources**, **Taste skill**.

## 2. Cada ordenador (una vez)

Pasos detallados: **Mac** → `perfiles/MAC.md` · **Windows** → `perfiles/WINDOWS.md`. Resumen para Mac:

```bash
git clone https://github.com/llorente96/Diseno.git
cd Diseno
git checkout claude/upbeat-einstein-sa9u96
bash perfiles/aplicar-perfil.sh <perfil> --dry-run
bash perfiles/instalar-mesa.sh <perfil>
```

`instalar-mesa.sh` aplica el perfil y deja la mesa actualizándose sola: los cambios que se suban al repo llegan al abrir Claude Code (como mucho una vez al día).

`<perfil>` = `diseno` · `ingenieria` · `director-creativo`. Reinicia Claude Code al acabar.

## 3. Cada proyecto

Copia `perfiles/<perfil>/.claude/` a la raíz del proyecto.

## Qué queda activo

| | Diseño (3) | Ingeniería (tú) | Director creativo (Rubén) |
|---|---|---|---|
| Design, Figma, Impeccable | ✅ | ✅ | ✅ |
| Skills del equipo | ✅ | ✅ | ✅ |
| Document skills, PDF Viewer | ✅ | ✅ | ✅ |
| Marketing | ❌ | ❌ | ✅ |
| Ponytail | ❌ | ✅ | ❌ (se activa en temporadas con mucho código) |
| ECC | ❌ | Selección de 17 skills (carpeta) | ❌ |
| WordPress Dev Skills | ✅ | ✅ | ✅ |
| Claude api | ❌ | ✅ | ❌ |
| Superpowers, Taste, Sales, HR | ❌ | ❌ | ❌ |

## Conectores por perfil

- **Diseño:** Canva, Figma, Adobe, Magnific, Higgsfield, Drive, html.to.design
- **Ingeniería:** Canva, Figma, Magnific, Higgsfield, n8n, GitHub, servidores MCP locales de WordPress
- **Director creativo:** Canva, Figma, Adobe, Magnific, Higgsfield, Drive

## Skills del equipo

| Skill | Para qué |
|---|---|
| `mejorar-prompt-imagen` | Antes de generar en Higgsfield o Magnific |
| `revision-diseno` | Revisar antes de entregar (tabla de máximo 10 puntos) |
| `wp-betheme-wpbakery` | Pasar un diseño a Betheme o WPBakery |
| `asesor-plugins` | Buscar en el catálogo (~3.800 plugins), medir tokens y proponer cambios de perfil |

## 6 reglas para gastar menos tokens

1. Solo los plugins de tu perfil. social-media-skills, por sí solo, añade unos 35.500 tokens a cada sesión.
2. Una tarea por conversación: `/clear` al cambiar de tarea.
3. Enlace exacto: frame de Figma con node-id o enlace de Canva.
4. Nombra la skill: "usa revision-diseno con…".
5. Sonnet para el día a día; Opus solo para lo complejo (`/model`).
6. Mejora el prompt antes de generar imagen o vídeo y confirma el coste.

## Buscar plugins sin gastar tokens

```bash
bash perfiles/buscar-plugins.sh wordpress woocommerce
```

## Ver la configuración de una mesa

```bash
bash perfiles/ver-mesa.sh > mesa.txt
```
