# 7Cash — Proyecto Capacitor + GitHub Actions

Este repo convierte `www/index.html` (la app 7Cash) en un APK de Android automáticamente cada vez que subes cambios a `main`, usando GitHub Actions (sin necesidad de compilar en tu PC).

## Cómo subir esto a GitHub

1. Crea un repositorio nuevo en GitHub (vacío, sin README).
2. En tu PC, dentro de esta carpeta:
   ```bash
   git init
   git add .
   git commit -m "Proyecto inicial 7Cash + Capacitor"
   git branch -M main
   git remote add origin https://github.com/TU_USUARIO/TU_REPO.git
   git push -u origin main
   ```
3. Ve a la pestaña **Actions** de tu repo en GitHub. El workflow "Build APK" se ejecutará solo.
4. Cuando termine (2-4 min), entra al run y descarga el **artifact** `7cash-debug-apk` — ahí está tu `.apk` listo para instalar.

## Para subir una nueva versión del APK

Cada vez que quieras generar un nuevo APK:
1. Edita `www/index.html` con los cambios.
2. `git add . && git commit -m "cambios" && git push`
3. GitHub Actions genera automáticamente el nuevo APK.

### Publicar como Release (opcional, para tener varios APKs versionados)

Si además quieres que quede como un "Release" descargable con versión (v1.0.0, v1.0.1, etc.):
```bash
git tag v1.0.0
git push origin v1.0.0
```
Esto crea automáticamente un Release en GitHub con el APK adjunto.

## Conectar Supabase

Este proyecto no incluye aún el cliente de Supabase. Cuando quieras integrarlo:
1. Agrega el SDK de Supabase JS en `www/index.html` (via CDN o npm).
2. Guarda tu URL y anon key de Supabase — puedes dejarlas directo en el HTML (son públicas por diseño) o usarlas como variables si prefieres.
3. No afecta el build del APK: Supabase es un servicio que la app consume en tiempo de ejecución, no algo que se compile.

## Login con Google

El archivo ya trae la integración con Google Identity Services. Falta reemplazar:
```js
const GOOGLE_CLIENT_ID = 'GOOGLE_CLIENT_ID.apps.googleusercontent.com';
```
por tu Client ID real, generado en https://console.cloud.google.com/apis/credentials. Para que funcione en la app empaquetada (APK), en Google Cloud Console deberás registrar también el paquete Android (`com.sietecash.app`) y su huella SHA-1, según la guía de Google Identity para apps nativas.

## Cambiar nombre/ícono de la app

- Nombre: `capacitor.config.json` → `appName`.
- ID de paquete: `capacitor.config.json` → `appId` (ya usado: `com.sietecash.app`).
- Ícono/splash: se generan con `npx @capacitor/assets generate` (requiere un logo fuente); puedo ayudarte con esto cuando tengas el diseño.
