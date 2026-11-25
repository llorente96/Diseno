---
name: wp-betheme-wpbakery
description: Lleva un diseño (Figma, Canva, imagen o PDF) a WordPress con Betheme (BeBuilder) o WPBakery. Úsala cuando pidan maquetar, implementar o "pasar a WordPress" un diseño, o generar secciones, shortcodes o CSS para Betheme o WPBakery.
---

# Del diseño a Betheme / WPBakery

1. **Obtén el diseño una sola vez.**
   - Figma: enlace con `node-id` del frame concreto, no del archivo entero.
   - Canva: enlace del diseño.
   - Imagen: adjunta la captura.
   Pregunta qué builder usa la web: BeBuilder de Betheme o WPBakery.
2. **Descompón** el diseño en secciones, luego filas y luego columnas. Anota en cada una: fondo, espaciado, ancho de columnas y cómo cambia en móvil.
3. **Usa primero lo nativo:**
   - Colores, tipografías y botones globales en las opciones del tema, no repetidos elemento a elemento.
   - Elementos propios del builder antes que HTML a mano.
4. **CSS solo cuando haga falta:**
   - Clases con prefijo del proyecto (p. ej. `.est-hero`), nunca IDs autogenerados.
   - En el CSS personalizado del tema o en un tema hijo. Nunca se edita el tema padre.
   - Unidades relativas y `clamp()` para tipografía.
5. **WPBakery:** entrega el bloque listo para pegar en el editor de código:
   `[vc_row][vc_column width="1/2"][vc_column_text]...[/vc_column_text][/vc_column][vc_column width="1/2"]...[/vc_column][/vc_row]`
6. **Entrega:**
   - Lista de secciones con los ajustes de cada elemento.
   - Shortcodes o pasos en BeBuilder.
   - CSS.
   - Checklist: móvil y tablet, imágenes en WebP con `alt`, contraste AA, enlaces y botones funcionando.

Ahorro de tokens: trabaja sección por sección y no pidas el contexto completo de Figma si basta una captura.
