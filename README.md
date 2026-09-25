# OpenCode Learning

Página estática en español para aprender [OpenCode](https://opencode.ai), el agente de código open source para la terminal: qué es, cómo instalarlo, conceptos clave, una ruta de aprendizaje con checklist y los comandos esenciales.

**Ver en vivo:** _pendiente_

## Correr en local

```bash
python3 -m http.server 8080
```

Abrir <http://localhost:8080>.

## Validar

```bash
npx --yes html-validate index.html   # HTML válido
./scripts/check.sh                   # smoke test local
./scripts/check.sh https://tu-url    # smoke test + cabeceras de seguridad en producción
```

## Desplegar en Vercel

1. Entrar en <https://vercel.com/new> e importar el repositorio `jfcanon/opencode-learning`.
2. Framework Preset: **Other**. Root Directory: `./`. Build Command y Output Directory vacíos.
3. Deploy. Cada push a `main` vuelve a desplegar.

No hay `package.json` a propósito: Vercel sirve la raíz como sitio estático sin build.

## Stack

HTML5, CSS y JavaScript sin build, sin frameworks ni CDN. `vercel.json` añade `cleanUrls` y cabeceras de seguridad.

## Licencia

MIT. Proyecto de aprendizaje independiente, no afiliado al equipo de OpenCode.
