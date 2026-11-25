# Guía de instalación de perfiles de Claude (de principio a fin)

> **Versión recomendada: `guia-instalacion.html`.** Eliges sistema y perfil, y los comandos salen ya rellenos. Esta versión en texto queda como referencia.

Sirve para cualquier mesa del equipo, en Mac o Windows. Se hace **una sola vez por ordenador**; después, los cambios de perfil llegan solos.

Tiempo aproximado: 10–15 minutos por mesa.

---

## 0. Antes de empezar: elige el perfil

| Persona | Perfil | Nombre para los comandos |
|---|---|---|
| Diseñadores (3) | Diseño | `diseno` |
| Ingeniería (backend, n8n) | Ingeniería | `ingenieria` |
| Rubén | Director creativo | `director-creativo` |

### Qué deja activo cada perfil (en Claude Code)

| Plugin | `diseno` | `ingenieria` | `director-creativo` |
|---|---|---|---|
| Design | ✅ | ✅ | ✅ |
| Figma | ✅ | ✅ | ✅ |
| Impeccable | ✅ | ✅ | ✅ |
| WordPress Dev Skills (+ dependencia) | solo en proyectos WordPress | solo en proyectos WordPress | solo en proyectos WordPress |
| Document skills, PDF Viewer | ✅ | ✅ | ✅ |
| Marketing | ❌ | ❌ | ✅ |
| Ponytail | ❌ | ✅ | ❌ (se puede activar a mano) |
| Claude api | ❌ | ✅ | ❌ |
| Superpowers, Taste, ECC completo, Sales, HR, social-media-skills | ❌ | ❌ | ❌ |
| Adobe (plugin) | sin tocar | ❌ | sin tocar |

Además, en todos los perfiles se copian 4 skills del equipo: `mejorar-prompt-imagen`, `revision-diseno`, `wp-betheme-wpbakery` y `asesor-plugins`.

Los plugins que no aparecen en la tabla no se tocan.

---

## 1. Requisitos

Abre la terminal:
- **Mac:** aplicación **Terminal**.
- **Windows:** **PowerShell**. La línea debe empezar por `PS C:\...>`.

### 1.1 Claude Code

Comprueba si ya está instalado:

```
claude --version
```

Si no lo reconoce, instálalo:

- **Mac**
  ```bash
  curl -fsSL https://claude.ai/install.sh | bash
  ```
- **Windows**
  ```powershell
  irm https://claude.ai/install.ps1 | iex
  ```
  Si después `claude` sigue sin reconocerse, añádelo al PATH (una vez). Luego **cierra PowerShell, ábrelo de nuevo** y repite `claude --version`:
  ```powershell
  [Environment]::SetEnvironmentVariable('Path', "$HOME\.local\bin;" + [Environment]::GetEnvironmentVariable('Path','User'), 'User')
  ```

La primera vez, escribe `claude` y entra con la **cuenta de la empresa**. Después sal con `/exit`.

### 1.2 Git

```
git --version
```

Si no existe:
- **Mac:** macOS ofrece instalar las "herramientas de línea de comandos". Acepta y repite. Esas herramientas también incluyen `python3`, que los scripts de Mac necesitan.
- **Windows:**
  ```powershell
  winget install --id Git.Git -e --source winget
  ```
  Después cierra PowerShell y vuelve a abrirlo.

---

## 2. Descargar el repositorio

Solo la primera vez en cada ordenador.

Un solo comando: si la carpeta no existe la descarga, y si existe la actualiza.

**Mac**
```bash
if [ -d ~/Diseno ]; then git -C ~/Diseno pull; else git clone -b claude/upbeat-einstein-sa9u96 https://github.com/llorente96/Diseno.git ~/Diseno; fi
```

**Windows**
```powershell
if (Test-Path $HOME\Diseno) { git -C $HOME\Diseno pull } else { git clone -b claude/upbeat-einstein-sa9u96 https://github.com/llorente96/Diseno.git $HOME\Diseno }
```

---

## 3. Simular (no cambia nada)

Sustituye `PERFIL` por `diseno`, `ingenieria` o `director-creativo`.

**Mac**
```bash
bash ~/Diseno/perfiles/aplicar-perfil.sh PERFIL --dry-run
```

**Windows**
```powershell
powershell -ExecutionPolicy Bypass -File $HOME\Diseno\perfiles\aplicar-perfil.ps1 -Perfil PERFIL -Simular
```

Qué significa cada línea:

| Línea | Significado |
|---|---|
| `[simulacion] enable X` | Lo activará |
| `[simulacion] disable X` | Lo desactivará |
| `[simulacion] instalar dependencia X` | Instalará algo que necesita un plugin del perfil (solo si está aprobado) |
| `= X ya estaba como debe` | No hace falta tocarlo |
| `X: no esta instalado en este equipo` | Normal: ese plugin no está en el Claude Code de este ordenador |
| `Simulacion terminada: no se ha cambiado nada.` | Fin |

Si sale algún error, **para aquí** y revisa el punto 9.

---

## 4. Configurar la mesa

**Mac**
```bash
bash ~/Diseno/perfiles/instalar-mesa.sh PERFIL
```

**Windows**
```powershell
powershell -ExecutionPolicy Bypass -File $HOME\Diseno\perfiles\instalar-mesa.ps1 -Perfil PERFIL
```

Esto hace cuatro cosas:
1. Guarda qué perfil tiene esta mesa.
2. Activa y desactiva los plugins del perfil, e instala las dependencias aprobadas.
3. Copia las skills del equipo.
4. Deja la **actualización automática**: al abrir Claude Code, como mucho una vez al día, baja los cambios del repositorio y, si cambió algún perfil, lo vuelve a aplicar.

Si al final aparece `⚠` o `AVISO … sigue desactivado`, anota el motivo que indica (punto 9).

---

## 5. Reiniciar y comprobar

1. Cierra Claude Code si estaba abierto y vuelve a abrirlo.
2. Comprueba los plugins:
   ```
   claude plugin list
   ```
   Lo activo debe coincidir con la tabla del punto 0.
3. Informe completo de la mesa (opcional):
   - **Mac**
     ```bash
     bash ~/Diseno/perfiles/ver-mesa.sh > ~/Desktop/mesa.txt && open ~/Desktop/mesa.txt
     ```
   - **Windows**
     ```powershell
     powershell -ExecutionPolicy Bypass -File $HOME\Diseno\perfiles\ver-mesa.ps1 > $HOME\Desktop\mesa.txt; notepad $HOME\Desktop\mesa.txt
     ```

---

## 6. Cada proyecto: tipo de trabajo (Claude Code)

El perfil dice quién eres; el tipo de trabajo dice qué proyecto es. Una vez por proyecto:

1. En la terminal, escribe `cd ` (con espacio), arrastra la carpeta del proyecto a la ventana y pulsa Enter.
2. Ejecuta un comando por tipo (se pueden combinar):
   - **Mac:** `bash ~/Diseno/perfiles/preparar-proyecto.sh wordpress`
   - **Windows:** `powershell -ExecutionPolicy Bypass -File $HOME\Diseno\perfiles\preparar-proyecto.ps1 -Tipo wordpress`

| Tipo | Activa solo en ese proyecto |
|---|---|
| `wordpress` | WordPress Dev Skills y su dependencia, más instrucciones de Betheme/WPBakery |
| `diseno-grafico` | Instrucciones de imagen, vídeo y revisión |
| `automatizacion` | Instrucciones de n8n |
| `backend` | Reglas de código de ECC |

3. Abre Claude Code desde esa carpeta (`claude`). Si el proyecto usa git, sube su carpeta `.claude`.

---

## 7. App de Claude (escritorio o web)

En la app, los plugins y conectores son de la cuenta y los compartís los cinco. Los perfiles se hacen con **Proyectos**:

1. Crea un Proyecto por perfil: "Perfil Diseño", "Perfil Ingeniería", "Perfil Director creativo".
2. En sus instrucciones, pega el contenido de `perfiles/PERFIL/.claude/CLAUDE.md`.
3. Trabaja siempre dentro del Proyecto de tu perfil.

**Conectores que usa cada perfil** (se autorizan una vez en la cuenta):

| Conector | Diseño | Ingeniería | Director creativo |
|---|---|---|---|
| Canva, Figma, Magnific, Higgsfield | ✅ | ✅ | ✅ |
| Adobe, Google Drive | ✅ | – | ✅ |
| html.to.design (reconectar: la sesión caducó) | ✅ | – | – |
| n8n, GitHub, servidores MCP locales de WordPress | – | ✅ | – |

---

## 8. Primeros pasos con cada perfil

| Perfil | Pruébalo con |
|---|---|
| Todos | "Usa revision-diseno con este frame: [enlace de Figma con node-id]" |
| Todos | "Usa mejorar-prompt-imagen: foto de producto para banner 16:9" |
| Todos | "Usa wp-betheme-wpbakery: pasa esta sección a WPBakery: [enlace]" |
| Ingeniería | "Usa laravel-tdd para añadir un endpoint con test" |
| Director creativo | "Usa campaign-plan para el lanzamiento de [cliente]" |
| Cualquiera | "Usa asesor-plugins: ¿hay algo mejor para X?" |

Para gastar menos tokens:
- Una tarea por conversación (`/clear` al cambiar).
- Da el enlace exacto (Figma con node-id, Canva).
- Nombra la skill que quieres usar.
- Sonnet para el día a día; Opus solo para lo complejo (`/model`).

---

## 9. Problemas frecuentes

| Síntoma | Solución |
|---|---|
| `claude` no se reconoce (Windows) | Paso 1.1: añadir `.local\bin` al PATH y reabrir PowerShell |
| `bash` no se reconoce (Windows) | Estás usando un comando de Mac. Usa los de Windows (`.ps1`, `irm …`) |
| `El argumento 'perfiles\…' no existe` | Usa los comandos con ruta completa (`$HOME\Diseno\perfiles\…`) |
| `Falta la cadena en el terminador` (Windows) | Versión antigua de los scripts: `git -C $HOME\Diseno pull` |
| `no such file or directory: Diseno` | Ya estás dentro de la carpeta. Ignóralo |
| `⚠ / AVISO X sigue desactivado: Dependency … not installed` | Falta una dependencia no aprobada. Pide a Claude "usa asesor-plugins" para revisarla y añadirla a `perfiles/dependencias.json` |
| `git pull` pide usuario y contraseña | El repositorio es privado: inicia sesión en GitHub en ese ordenador (en Windows se abre el navegador) |

---

## 10. Mantenimiento

| Quiero… | Cómo |
|---|---|
| Cambiar lo que lleva un perfil | Edita `perfiles/perfiles.json` (o pídeselo a Claude con `asesor-plugins`), pasa los tests (`bash perfiles/tests/test-scripts.sh`) y sube los cambios. Las mesas lo aplican solas |
| Cambiar el perfil de una mesa | Repite el paso 4 con el otro perfil |
| Activar Ponytail en la mesa de Rubén | `claude plugin enable ponytail@ponytail --scope user` (vuelve a apagarse si se reaplica el perfil) |
| Quitar la configuración de una mesa | Borra `~/.claude/perfil-equipo*` (Windows: `$HOME\.claude\perfil-equipo*`). Opcional: quita la entrada `actualizar-perfil` de `hooks.SessionStart` en `settings.json` |

Más detalle: `perfiles/DOCUMENTACION.md`.
