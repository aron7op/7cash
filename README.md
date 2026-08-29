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

## Conectar Supabase (ya está integrado, solo falta configurar)

El HTML ya trae el cliente de Supabase y el autoguardado en la nube. Solo te faltan 3 pasos:

1. **Crea el proyecto**: entra a [supabase.com](https://supabase.com), crea una cuenta y un proyecto nuevo (gratis).
2. **Crea la tabla**: en tu proyecto, ve a **SQL Editor → New query**, pega el contenido de `supabase_setup.sql` (incluido en este repo) y dale **Run**. Eso crea la tabla `estados_7cash`.
3. **Conecta las credenciales**: en tu proyecto de Supabase ve a **Project Settings → API** y copia:
   - **Project URL**
   - **anon public key**

   Luego en `www/index.html` busca estas dos líneas (cerca del final del `<script>`) y reemplázalas:
   ```js
   const SUPABASE_URL = 'TU_SUPABASE_URL';
   const SUPABASE_ANON_KEY = 'TU_SUPABASE_ANON_KEY';
   ```

Sube el cambio (`git add . && git commit -m "conectar supabase" && git push`) y el workflow te genera un nuevo APK con la nube activada.

### Cómo funciona

- Se guarda automáticamente **cuando inicias sesión con Google** (real o demo) en la app.
- Cada vez que registras una venta, un gasto, cambias la distribución, etc., se guarda solo (con un pequeño retraso de ~1 segundo).
- Al volver a abrir la app y loguearte, carga automáticamente lo último guardado en la nube.
- Usa tu **correo de Google como identificador** — todo lo tuyo se guarda en una sola fila de la tabla `estados_7cash`, en la columna `data` (mismo formato que ya usa el botón "Descargar" de respaldo).
- Si cierras sesión, la app sigue funcionando en modo local (sin nube) igual que antes.

### Nota de seguridad

La política SQL incluida deja leer/escribir la tabla a cualquiera que tenga tu `anon key` (que va dentro del APK). Para un uso personal esto es aceptable — nadie más tiene tu APK. Si en algún momento compartes la app con otras personas y quieres que cada quien vea *solo* sus propios datos de forma segura, se puede migrar a un login real de Supabase (Auth) con políticas por usuario; avísame si llegas a ese punto y lo armamos.

## Login con Google

El archivo ya trae la integración con Google Identity Services. Falta reemplazar:
```js
const GOOGLE_CLIENT_ID = 'GOOGLE_CLIENT_ID.apps.googleusercontent.com';
```
por tu Client ID real, generado en https://console.cloud.google.com/apis/credentials. Para que funcione en la app empaquetada (APK), en Google Cloud Console deberás registrar también el paquete Android (`com.sietecash.app`) y su huella SHA-1, según la guía de Google Identity para apps nativas.

## Publicar en Google Play Store (.aab firmado)

Para que GitHub Actions pueda generar el `.aab` firmado con tu llave de producción, sin exponerla en el código, hay que guardarla como **GitHub Secrets** (variables privadas del repo):

1. En tu repo de GitHub: **Settings → Secrets and variables → Actions → New repository secret**.
2. Crea estos 4 secrets (uno por uno):
   - `RELEASE_KEYSTORE_BASE64` → pega el contenido completo del archivo `7cash-release-keystore-base64.txt` que te dio Claude.
   - `RELEASE_KEYSTORE_PASSWORD` → la contraseña que está en `7cash-release-INFO-IMPORTANTE.txt`.
   - `RELEASE_KEY_ALIAS` → `7cash`
   - `RELEASE_KEY_PASSWORD` → la misma contraseña que `RELEASE_KEYSTORE_PASSWORD`.
3. Sube (push) cualquier cambio para disparar el workflow. Ahora, además del APK debug, te va a generar:
   - `7cash-release-aab` → **este es el que subes a Play Store**.
   - `7cash-release-apk` → una copia firmada en .apk, por si la necesitas fuera de Play Store.

**MUY IMPORTANTE:** guarda el archivo `7cash-release.keystore` y su contraseña en un lugar seguro fuera de GitHub (Google Drive, USB, etc.). Es la llave que identifica tu app para siempre ante Play Store — si la pierdes, no podrás subir actualizaciones nunca más, solo publicar la app como si fuera nueva.

Antes de cada nueva subida a Play Store, sube el número de versión en `android/app/build.gradle` (`versionCode` +1 y `versionName` al gusto) — Play Store no acepta subir el mismo número dos veces.

## Cambiar nombre/ícono de la app

- Nombre: `capacitor.config.json` → `appName`.
- ID de paquete: `capacitor.config.json` → `appId` (ya usado: `com.sietecash.app`).
- Ícono/splash: se generan con `npx @capacitor/assets generate` (requiere un logo fuente); puedo ayudarte con esto cuando tengas el diseño.
