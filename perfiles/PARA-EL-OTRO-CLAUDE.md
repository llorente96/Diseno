# Traspaso: perfiles de Claude del estudio

Pega esto en Claude Code (cuenta de empresa), dentro de la carpeta `Diseno`:

> Lee `perfiles/PARA-EL-OTRO-CLAUDE.md` y `perfiles/ESQUEMA.md`. A partir de ahora gestionas los perfiles de Claude del equipo con la skill `asesor-plugins`.

## Contexto

- 5 personas comparten **un solo usuario** de Claude. Los plugins de la cuenta los ve todo el mundo.
- Cada mesa (iMac) activa solo lo de su perfil con `perfiles/aplicar-perfil.sh`, a nivel de usuario de ese ordenador (`--scope user`).
- Perfiles:
  - `diseno`: 3 diseñadores (Adobe, Canva, Figma, imagen y vídeo, WordPress con Betheme y WPBakery).
  - `ingenieria`: diseño sin Adobe, más backend (Perl, Laravel, PHP), n8n y la selección de ECC.
  - `director-creativo`: Rubén. Todo menos backend profundo, con Marketing. Ponytail apagado por defecto.

## Configurar una mesa (una sola vez por ordenador)

```bash
git clone https://github.com/llorente96/Diseno.git
cd Diseno && git checkout claude/upbeat-einstein-sa9u96
bash perfiles/aplicar-perfil.sh <perfil> --dry-run
bash perfiles/instalar-mesa.sh <perfil>
```

`instalar-mesa.sh`:
- Guarda el perfil en `~/.claude/perfil-equipo`.
- Lo aplica y copia las skills del equipo.
- Añade un hook de inicio de sesión. Una vez al día, ese hook hace `git pull` y, si cambió algo en `perfiles/`, reaplica el perfil.

**Resultado: cualquier cambio de perfil subido al repo llega solo a todas las mesas.**

## Para cambiar un perfil

1. Usa la skill `asesor-plugins`: busca en el catálogo, mide tokens y propone.
2. Edita las listas ON/OFF de `perfiles/aplicar-perfil.sh`, más `ESQUEMA.md` y `guia-equipo.html`.
3. Haz commit y push a `claude/upbeat-einstein-sa9u96`. Las mesas lo aplican al abrir Claude Code.

## Pendiente

- El nombre real de **WordPress Dev Skills** en `claude plugin list`. Actualízalo en `aplicar-perfil.sh` (ahora pone `wordpress-dev-skills`).
- Reconectar **html.to.design** en la cuenta.
- Al reaplicar un perfil, Ponytail vuelve a apagarse en la mesa de Rubén si lo había encendido a mano.
