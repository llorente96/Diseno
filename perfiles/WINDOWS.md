# Configurar una mesa Windows (una sola vez)

Abre **PowerShell** y pega estos comandos en orden.

Los comandos usan rutas completas: funcionan desde cualquier carpeta.

**1. Comprobar Claude Code y Git**
```powershell
claude --version
```
```powershell
git --version
```
- Si `claude` no se reconoce, instálalo:
  ```powershell
  irm https://claude.ai/install.ps1 | iex
  ```
- Si después sigue sin reconocerse, añade su carpeta al PATH (una vez), cierra PowerShell, ábrelo de nuevo y repite `claude --version`:
  ```powershell
  [Environment]::SetEnvironmentVariable('Path', "$HOME\.local\bin;" + [Environment]::GetEnvironmentVariable('Path','User'), 'User')
  ```
- Si `git` no existe:
  ```powershell
  winget install --id Git.Git -e --source winget
  ```

**2. Descargar el repositorio** (solo la primera vez)
```powershell
git clone https://github.com/llorente96/Diseno.git $HOME\Diseno
```
```powershell
git -C $HOME\Diseno checkout claude/upbeat-einstein-sa9u96
```

**3. Simular** (no cambia nada). Cambia `director-creativo` por `diseno` o `ingenieria`.
```powershell
powershell -ExecutionPolicy Bypass -File $HOME\Diseno\perfiles\aplicar-perfil.ps1 -Perfil director-creativo -Simular
```

**4. Configurar la mesa**
```powershell
powershell -ExecutionPolicy Bypass -File $HOME\Diseno\perfiles\instalar-mesa.ps1 -Perfil director-creativo
```

**5. Reiniciar Claude Code.** A partir de aquí, los cambios de perfil que se suban al repositorio llegan solos (como mucho una vez al día).

## Cada proyecto: tipo de trabajo

Una vez por proyecto, desde su carpeta (`cd` + arrastrar la carpeta a la ventana): ver `GUIA-INSTALACION.md`, punto 6, o la sección «Cada proyecto» de `guia-instalacion.html`.

## Ver la configuración de la mesa
```powershell
powershell -ExecutionPolicy Bypass -File $HOME\Diseno\perfiles\ver-mesa.ps1 > $HOME\Desktop\mesa.txt; notepad $HOME\Desktop\mesa.txt
```

`-ExecutionPolicy Bypass` permite ejecutar solo ese script sin cambiar la seguridad de Windows.
