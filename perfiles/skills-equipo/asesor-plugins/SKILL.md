---
name: asesor-plugins
description: Asesor de plugins, skills y conectores de Claude para los perfiles del equipo. Úsala cuando pregunten "¿hay algún plugin para X?", "¿merece la pena instalar Y?", "¿qué sobra?", o quieran añadir o quitar algo de un perfil (diseno, ingenieria, director-creativo).
---

# Asesor de plugins del equipo

Las decisiones se toman con datos, no de memoria: el catálogo y los perfiles cambian cada semana.

1. **Situación actual.** Lee `perfiles/ESQUEMA.md` y las listas ON/OFF de `perfiles/perfiles.json`.
2. **Buscar candidatos sin gastar tokens.** Lanza `bash perfiles/buscar-plugins.sh <palabras>`: filtra en local el catálogo completo de plugins (unos 3.800) y marca los ya instalados. Prueba sinónimos en inglés (p. ej. `wordpress woocommerce`, `image upscale`, `video edit`). Si tienes las herramientas SearchPlugins, SearchSkills o SearchMcpRegistry, úsalas también para skills sueltas y conectores.
3. **Medir antes de recomendar.** `claude plugin details <id>` da skills, hooks y **tokens que añade a cada sesión**. Solo funciona con plugins instalados. Para medir uno nuevo: pide permiso, instálalo, mídelo y desinstálalo si no se queda.
4. **Criterios.**
   - Si se solapa con algo que ya está, gana lo que ya está, salvo que el nuevo sea claramente mejor.
   - Más de 5.000 tokens por sesión: solo si ese perfil lo usa a diario.
   - Hooks: explica qué hacen. Los que inyectan texto al inicio cuestan en cada sesión.
   - Editor: Anthropic o partner antes que comunidad. Mira la fecha de la última versión.
   - Si da acceso a cuentas o datos de clientes, avisa.
5. **Responde con una tabla:** Candidato · Qué aporta · Tokens por sesión · Solapa con · Perfil · Veredicto (Añadir / Probar / Descartar). Máximo 5 filas.
6. **Si se acepta un cambio:**
   - Edita las listas ON/OFF del perfil en `perfiles/perfiles.json` (las usan los scripts de Mac y de Windows).
   - Actualiza `perfiles/ESQUEMA.md` y `perfiles/guia-equipo.html`.
   - Haz commit y push. Cada mesa lo aplica sola al abrir Claude Code (como mucho una vez al día).

Nunca instales, desinstales ni hagas push sin confirmación.
