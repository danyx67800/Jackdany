# API Jack Dany Backend

Base: `http://umbrel.local:3000` (o IP Tailscale). Auth admin: `Authorization: Bearer <JWT>`.

## Health & settings

- `GET /api/health` → `{ok, app, time}`
- `GET /api/settings` → `{app_name, f1_provider, maintenance_mode, backend_base_url}`
- `PUT /api/settings` (admin) `{app_name?, f1_provider?, maintenance_mode?}`

## Auth

- `POST /api/auth/login` `{username, password}` → `{token, username}`
- `POST /api/auth/change-password` (admin) `{oldPassword, newPassword}`

## News

- `GET /api/news?category=tech|spazio|aerei|f1&limit=50` → `News[]`
- `GET /api/news/:id` → `News`
- `GET /api/news/admin/all` (admin, include bozze)
- `POST /api/news` (admin) `{title, category, excerpt?, body?, image_url?, published?}`
- `PUT /api/news/:id` (admin, patch parziale)
- `DELETE /api/news/:id` (admin)

`News = {id, title, category, excerpt, body, image_url, published, published_at, created_at, updated_at}`

## Sezione segreta

- `POST /api/secret/unlock` `{pin}` → `{token}` (scope secret, 24h)
- `GET /api/secret/photos` (secret JWT) → `[{id, title, image_url, created_at}]`
- `GET /api/secret/messages` (secret JWT) → `[{id, title, body, created_at}]`
- `POST /api/secret/photos` (admin, multipart `photo` + `title`)
- `DELETE /api/secret/photos/:id` (admin)
- `POST /api/secret/messages` (admin) `{title, body}`
- `PUT /api/secret/messages/:id` (admin)
- `DELETE /api/secret/messages/:id` (admin)
- `POST /api/secret/pin` (admin) `{newPin}`

## F1 (esterne, usate dal mobile)

- OpenF1: `GET https://api.openf1.org/v1/sessions?year=2026`, `.../championship_drivers?session_key=X`, `.../drivers?session_key=X`
- Fallback: `GET https://api.jolpi.ca/ergast/f1/2026/driverStandings.json`
- Proxy opzionale via backend: `GET /api/f1/proxy?u=<openf1-url>`
