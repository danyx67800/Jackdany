# Jack Dany — ecosistema mobile + Umbrel OS

Mono-repo dell'ecosistema **Jack Dany**:

- `/mobile` — app Flutter (iOS + Android): notizie Tech/Spazio/Aerei/F1, dashboard F1 (OpenF1 + fallback Jolpica), Liquid Glass su iOS, splash con hero-animation del logo verso la top bar, easter egg a 5 tap sul logo con PIN/biometria.
- `/jackdany-app` — app per **Umbrel OS** (Community App Store): backend Node.js/Express + store JSON + dashboard admin web. Gestisce notizie, impostazioni e sezione segreta (foto + messaggi + PIN). API REST per il mobile.
- `umbrel-app-store.yml` — manifest del Community App Store (`jackdany`).

## Scelte architetturali

| Decisione | Scelta | Motivo |
|---|---|---|
| Mobile | **Flutter** | 60/120fps, singola codebase, `BackdropFilter` = Liquid Glass nativo su iOS, Hero animation built-in |
| Backend | **Node.js/Express + JSON store** | zero dipendenze native (funziona su RPi/ARM senza build), singolo container leggero |
| DB | file `db.json` su volume persistente `${APP_DATA_DIR}` | backup = copia file; niente Postgres da mantenere su home server |
| F1 live | **OpenF1** primario, **Jolpica/Ergast** fallback | OpenF1 gratuito senza key (storico dal 2023); realtime a pagamento — fallback gratuito |
| Auth | JWT admin (12h) + secret JWT (24h via PIN) | mobile legge news pubbliche senza auth; segreta solo con PIN |

## Quickstart — Backend (locale, senza Umbrel)

```bash
cd jackdany-app/server
npm install
DATA_DIR=./data PORT=3000 node src/index.js
# Dashboard: http://localhost:3000/admin/  (admin / jackdany-admin — cambia subito!)
# Health:    http://localhost:3000/api/health
```

## Quickstart — Mobile

```bash
cd mobile
flutter pub get
flutter run  # imposta il backend in Impostazioni: http://umbrel.local:3000 o IP Tailscale
```

## Deploy su Umbrel OS

1. Su umbrelOS: App Store → ⋯ → *Add Community App Store* → `https://github.com/danyx67800/Jackdany`
2. Installa **Jack Dany Backend**, apri la dashboard e cambia password + PIN.
3. Nell'app mobile → Impostazioni → inserisci l'URL del backend (IP locale / Tailscale / HTTPS).

Dettagli: `docs/ARCHITECTURE.md`, API: `docs/API.md`.
