# Perfil: Ingeniería (backend Perl / Laravel / PHP-WordPress)

Selección de [ECC](https://github.com/affaan-m/ECC) v2.2.3 (licencia MIT, ver `.claude/ECC-LICENSE`).
Solo Markdown: sin hooks, sin scripts, sin agentes.

## Uso

Copia la carpeta `.claude` a la raíz del proyecto:

```bash
cp -r perfiles/ingenieria/.claude /ruta/a/tu-proyecto/
```

## Contenido

- **Skills (17)**: perl-patterns, perl-security, perl-testing, laravel-patterns,
  laravel-security, laravel-tdd, laravel-verification, backend-patterns, api-design,
  database-migrations, mysql-patterns, security-review, tdd-workflow, verification-loop,
  coding-standards, frontend-patterns, frontend-a11y
- **Reglas** (`.claude/rules/ecc/`): common, php, perl, web

Quitado a propósito: `hooks.md` y `common/agents.md`, que remiten a hooks y agentes de ECC no incluidos.
`tdd-workflow` menciona `scripts/setup-package-manager.js`, que no se copia: ignóralo.

## Consejo

En proyectos con este perfil, desactiva `superpowers`: ECC y superpowers cubren lo mismo (plan, TDD, revisión).
