# Configurar una mesa Mac (una sola vez)

Abre **Terminal** y pega estos comandos en orden.

**1. Comprobar que Claude Code y Git están instalados**
```bash
claude --version
```
```bash
git --version
```
Si `git` no existe, macOS ofrece instalarlo: acepta y repite.

**2. Descargar el repositorio** (solo la primera vez)
```bash
cd ~ && git clone https://github.com/llorente96/Diseno.git
```
```bash
cd ~/Diseno && git checkout claude/upbeat-einstein-sa9u96
```

**3. Simular** (no cambia nada). Cambia `diseno` por `ingenieria` o `director-creativo`.
```bash
bash perfiles/aplicar-perfil.sh diseno --dry-run
```

**4. Configurar la mesa**
```bash
bash perfiles/instalar-mesa.sh diseno
```

**5. Reiniciar Claude Code.** A partir de aquí, los cambios de perfil que se suban al repositorio llegan solos (como mucho una vez al día).

## Ver la configuración de la mesa
```bash
bash ~/Diseno/perfiles/ver-mesa.sh > ~/Desktop/mesa.txt && open ~/Desktop/mesa.txt
```

## Buscar plugins (sin gastar tokens)
```bash
bash ~/Diseno/perfiles/buscar-plugins.sh wordpress woocommerce
```
