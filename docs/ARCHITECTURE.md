# Architettura Jack Dany

```
┌──────────────┐      HTTPS/LAN/Tailscale       ┌─────────────────────┐
│  mobile/     │ ─────────────────────────────▶ │  jackdany-app/      │
│  Flutter     │   /api/news  (pubblico)        │  Node.js :3000      │
│  iOS+Android │   /api/settings (pubblico)     │  Express            │
│              │   /api/secret/* (PIN->JWT)     │  db.json + uploads/ │
│  OpenF1 API  │ ◀── diretto dal mobile ─────── │  /admin dashboard   │
│  (pubblica)  │   fallback Jolpica             │  volume ${APP_DATA_DIR}/data │
└──────────────┘                                └─────────────────────┘
                                                          │ Umbrel
                                              umbrel-app.yml + docker-compose.yml
                                              store: danyx67800/Jackdany (id: jackdany)
```

## Backend — routes

- `GET /api/health`, `GET /admin/` (dashboard statica)
- Auth admin: `POST /api/auth/login`, `POST /api/auth/change-password`
- News pubbliche: `GET /api/news?category=`, `GET /api/news/:id`
- News admin (JWT): `GET /api/news/admin/all`, `POST/PUT/DELETE /api/news...`
- Settings: `GET /api/settings` (pubblico), `PUT /api/settings` (admin)
- Segreta: `POST /api/secret/unlock {pin}` → secret JWT; `GET /api/secret/photos|messages` (secret JWT); admin CRUD foto (multipart `photo`) e messaggi + `POST /api/secret/pin`
- `GET /api/f1/proxy?u=https://api.openf1.org/...` (proxy CORS opzionale)

## Mobile — navigazione

`/` (Splash, logo center→top-left Hero) → `/home` (Tab Tech/Spazio/Aerei + BottomNav News/F1)
→ `/secret` (5 tap sul logo → PIN/biometria → foto+messaggi) · `/settings` (base URL backend)

## Sicurezza

- Admin JWT 12h (`JWT_SECRET=${APP_SEED}` di Umbrel — unico per nodo).
- PIN segreto salvato come bcrypt hash in settings; unlock emette JWT scope `secret` 24h.
- Foto segrete su disco (`uploads/`), servite solo con path noto + token per le API (gli URL statici restano non indicizzati).
- TODO produzione: rate-limit su `/unlock` e `/login`, HTTPS obbligatorio via Tailscale/reverse proxy.
