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

## Dos niveles

- **Perfil** por ordenador (`instalar-mesa`).
- **Tipo de trabajo** por proyecto (`preparar-proyecto`): `wordpress`, `diseno-grafico`, `automatizacion`, `backend`. Kits en `perfiles/trabajos/`.

## Configurar una mesa (una sola vez por ordenador)

Guía de principio a fin: `perfiles/GUIA-INSTALACION.md`. Pasos por sistema: `perfiles/MAC.md` y `perfiles/WINDOWS.md` (mesa de Rubén: Windows). Resumen para Mac:

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

## Ver la configuración de una mesa

```bash
bash perfiles/ver-mesa.sh > mesa.txt
```

Muestra el perfil guardado, los plugins activos con su coste en tokens, los hooks, las skills y los conectores. No muestra claves.

## Para cambiar un perfil

1. Usa la skill `asesor-plugins`: busca en el catálogo, mide tokens y propone.
2. Edita las listas ON/OFF de `perfiles/perfiles.json`, más `ESQUEMA.md` y `guia-equipo.html`.
3. Haz commit y push a `claude/upbeat-einstein-sa9u96`. Las mesas lo aplican al abrir Claude Code.

## Pendiente

Lista completa y actualizada: `perfiles/DOCUMENTACION.md`, punto 7.

- WordPress Dev Skills necesita `wordpress-official-agent-skills`: el script la instala solo porque está en `dependencias.json`.

- WordPress Dev Skills (`wp-dev-skills@synced`) está apagado en todas las mesas y solo se activa en proyectos preparados con `preparar-proyecto … wordpress`.
- Reconectar **html.to.design** en la cuenta.
- Al reaplicar un perfil, Ponytail vuelve a apagarse en la mesa de Rubén si lo había encendido a mano.
