#!/usr/bin/env bash
# Busca en el catálogo completo de plugins (sin gastar tokens).
# Uso: bash perfiles/buscar-plugins.sh wordpress figma imagen ...
[ $# -eq 0 ] && { echo "Uso: $0 palabra [palabra...]"; exit 1; }
claude plugin list --available --json | python3 -c '
import json, sys
palabras = [p.lower() for p in sys.argv[1:]]
d = json.load(sys.stdin)
instalados = {p["id"].split("@")[0] for p in d.get("installed", [])}
hits = []
for p in d.get("available", []):
    texto = (p.get("name","") + " " + (p.get("description") or "")).lower()
    n = sum(w in texto for w in palabras)
    if n: hits.append((n, p))
hits.sort(key=lambda x: -x[0])
print(f"{len(hits)} resultados (máx. 30):")
for n, p in hits[:30]:
    marca = " [INSTALADO]" if p["name"] in instalados else ""
    desc = (p.get("description") or "")[:160]
    print("- " + p["pluginId"] + marca + "\n    " + desc)
' "$@"
