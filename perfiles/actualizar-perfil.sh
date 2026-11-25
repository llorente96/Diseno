#!/usr/bin/env bash
# Lo lanza Claude Code al iniciar (hook). Una vez al día: baja cambios del repo y,
# si cambió algo en perfiles/, reaplica el perfil guardado de esta mesa. Nunca bloquea ni falla.
CONF="$HOME/.claude/perfil-equipo"; STAMP="$HOME/.claude/perfil-equipo.ultimo"
[ -f "$CONF" ] || exit 0
. "$CONF"   # define PERFIL y REPO
[ "$(cat "$STAMP" 2>/dev/null)" = "$(date +%F)" ] && exit 0
date +%F > "$STAMP"
(
  ANTES=$(git -C "$REPO" rev-parse HEAD 2>/dev/null)
  git -C "$REPO" pull -q --ff-only 2>/dev/null || exit 0
  DESPUES=$(git -C "$REPO" rev-parse HEAD)
  if [ "$ANTES" != "$DESPUES" ] && ! git -C "$REPO" diff --quiet "$ANTES" "$DESPUES" -- perfiles; then
    bash "$REPO/perfiles/aplicar-perfil.sh" "$PERFIL" > "$HOME/.claude/perfil-equipo.log" 2>&1
  fi
) >/dev/null 2>&1 &
exit 0
