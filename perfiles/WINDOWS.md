# Configurar una mesa Windows (una sola vez)

Abre **PowerShell** y pega estos comandos en orden.

**1. Comprobar que Claude Code y Git están instalados**
```powershell
claude --version
```
```powershell
git --version
```
Si `git` no existe, instálalo, cierra PowerShell, ábrelo de nuevo y repite:
```powershell
winget install --id Git.Git -e --source winget
```

**2. Descargar el repositorio** (solo la primera vez)
```powershell
cd $HOME; git clone https://github.com/llorente96/Diseno.git
```
```powershell
cd $HOME\Diseno; git checkout claude/upbeat-einstein-sa9u96
```

**3. Simular** (no cambia nada). Cambia `director-creativo` por `diseno` o `ingenieria`.
```powershell
powershell -ExecutionPolicy Bypass -File perfiles\aplicar-perfil.ps1 -Perfil director-creativo -Simular
```

**4. Configurar la mesa**
```powershell
powershell -ExecutionPolicy Bypass -File perfiles\instalar-mesa.ps1 -Perfil director-creativo
```

**5. Reiniciar Claude Code.** A partir de aquí, los cambios de perfil que se suban al repositorio llegan solos (como mucho una vez al día).

## Ver la configuración de la mesa
```powershell
powershell -ExecutionPolicy Bypass -File $HOME\Diseno\perfiles\ver-mesa.ps1 > $HOME\Desktop\mesa.txt; notepad $HOME\Desktop\mesa.txt
```

`-ExecutionPolicy Bypass` permite ejecutar solo ese script sin cambiar la seguridad de Windows.
