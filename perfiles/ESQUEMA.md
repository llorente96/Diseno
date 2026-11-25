# Esquema rápido: perfiles Claude del estudio

Ninguno de estos pasos gasta tokens: son comandos de terminal y ajustes manuales.

## 1. Cuenta compartida (una sola vez, en claude.ai)

- Reconectar **html.to.design** (la sesión expiró).
- Se pueden desactivar para todos: **Sales**, **Human Resources**, **Taste skill**.

## 2. Cada ordenador (terminal, una vez)

```bash
git clone https://github.com/llorente96/Diseno.git
cd Diseno
git checkout claude/upbeat-einstein-sa9u96
bash perfiles/aplicar-perfil.sh <perfil> --dry-run
bash perfiles/aplicar-perfil.sh <perfil>
```

`<perfil>` = `diseno` · `ingenieria` · `direccion`. Reinicia Claude Code al acabar.

## 3. Cada proyecto

Copia `perfiles/<perfil>/.claude/` a la raíz del proyecto.

## Qué queda activo

| | Diseño (3) | Ingeniería (tú) | Dirección (Rubén) |
|---|---|---|---|
| Design, Figma, Impeccable | ✅ | ✅ | ✅ |
| Skills del equipo | ✅ | ✅ | ✅ |
| Document skills, PDF Viewer | ✅ | ✅ | ✅ |
| Marketing | ❌ | ❌ | ✅ |
| Ponytail | ❌ | ✅ | ❌ |
| ECC | ❌ | Selección de 17 skills (carpeta) | ❌ |
| WordPress Dev Skills, Claude api | ❌ | ✅ | ❌ |
| Superpowers, Taste, Sales, HR | ❌ | ❌ | ❌ |

## Conectores por perfil

- **Diseño:** Canva, Figma, Adobe, Magnific, Higgsfield, Drive, html.to.design
- **Ingeniería:** Canva, Figma, Magnific, Higgsfield, n8n, GitHub, servidores MCP locales de WordPress
- **Dirección:** Canva, Figma, Adobe, Magnific, Higgsfield, Drive, Klaviyo, Slack

## Skills del equipo

| Skill | Para qué |
|---|---|
| `mejorar-prompt-imagen` | Antes de generar en Higgsfield o Magnific |
| `revision-diseno` | Revisar antes de entregar (tabla de máximo 10 puntos) |
| `wp-betheme-wpbakery` | Pasar un diseño a Betheme o WPBakery |

## 6 reglas para gastar menos tokens

1. Solo los plugins de tu perfil. social-media-skills, por sí solo, añade unos 35.500 tokens a cada sesión.
2. Una tarea por conversación: `/clear` al cambiar de tarea.
3. Enlace exacto: frame de Figma con node-id o enlace de Canva.
4. Nombra la skill: "usa revision-diseno con…".
5. Sonnet para el día a día; Opus solo para lo complejo (`/model`).
6. Mejora el prompt antes de generar imagen o vídeo y confirma el coste.
