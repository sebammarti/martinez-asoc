# Sitio web + Portal de Clientes – Martinez & Asoc.

| Archivo | Para qué sirve |
|---|---|
| `index.html` | Página del estudio. |
| `portal.html` | Portal de Clientes con usuario y contraseña. |
| `config.js` | Conexión del portal al servidor (vacío = modo demo). |
| `supabase-setup.sql` | Crea la base de datos y las reglas de seguridad. |
| `assets/` | Logos, fotos y estilos. |
| `.nojekyll` | Necesario para GitHub Pages. No borrar. |

## PASO 1 – Publicar en GitHub Pages
1. En github.com: **New repository** → nombre (ej. `martinezyasoc`) → *Public* → **Create**.
2. **Add file → Upload files** → arrastrar TODO el contenido de esta carpeta (incluida `assets`) → **Commit changes**.
   Si `.nojekyll` no aparece (archivo oculto): **Add file → Create new file**, nombre `.nojekyll`, vacío.
3. **Settings → Pages** → *Deploy from a branch* → `main` / `(root)` → **Save**.
4. En 1-2 minutos: `https://USUARIO.github.io/martinezyasoc/` (portal en `/portal.html`).

En este punto el portal funciona en MODO DEMO (`demo`/`Demo2026!` y `estudio`/`Estudio2026!`): sirve para mostrarlo, no para clientes reales.

## PASO 2 – Activar el portal real (Supabase, plan gratuito)
1. Crear proyecto en https://supabase.com (región São Paulo).
2. **SQL Editor → New query** → pegar `supabase-setup.sql` → **Run**.
3. **Authentication → Sign In / Providers → Email**: desactivar *Confirm email*.
4. **Authentication → Users → Add user**: crear el usuario del estudio (e-mail y contraseña).
5. En **SQL Editor**, ejecutar con ese e-mail:
   `update public.profiles set role = 'admin', name = 'Estudio Martinez & Asoc.' where email = 'CORREO@ejemplo.com';`
6. **Authentication → URL Configuration → Site URL**: la dirección del portal (hace funcionar “¿Olvidaste tu contraseña?”).
7. **Project Settings → API**: copiar *Project URL* y clave **anon public** en `config.js` (nunca `service_role`) y subirlo a GitHub.

## Seguridad
- Cada cliente solo ve su carpeta (lo controla el servidor).
- Archivos privados; los links de descarga vencen a los 60 segundos.
- Sumar aviso de privacidad (Ley 25.326), validado con un asesor legal.
- Revisar límites del plan gratuito de Supabase antes de cargar todos los clientes.
