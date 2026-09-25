const express = require('express');
const cors = require('cors');
const morgan = require('morgan');
const path = require('path');
const fs = require('fs');

const { getSetting } = require('./db');

const app = express();
const PORT = Number(process.env.PORT || 3000);
const DATA_DIR = process.env.DATA_DIR || path.join(__dirname, '..', 'data');

app.use(cors());
app.use(express.json({ limit: '5mb' }));
app.use(morgan('tiny'));

app.use('/uploads', express.static(path.join(DATA_DIR, 'uploads')));
app.use('/admin', express.static(path.join(__dirname, '..', 'public', 'admin')));
app.get('/', (_, res) => res.redirect('/admin/'));

app.get('/api/health', (_, res) =>
  res.json({ ok: true, app: getSetting('app_name', 'Jack Dany'), time: new Date().toISOString() })
);

app.use('/api/auth', require('./routes/auth'));
app.use('/api/news', require('./routes/news'));
app.use('/api/settings', require('./routes/settings'));
app.use('/api/secret', require('./routes/secret'));

// Proxy leggero verso OpenF1 (evita CORS all'app mobile se serve)
app.get('/api/f1/proxy', async (req, res) => {
  const target = req.query.u;
  if (!target || !String(target).startsWith('https://api.openf1.org/'))
    return res.status(400).json({ error: 'url non consentito' });
  try {
    const r = await fetch(target);
    res.status(r.status).json(await r.json());
  } catch (e) {
    res.status(502).json({ error: 'f1 upstream non raggiungibile' });
  }
});

app.use((_, res) => res.status(404).json({ error: 'not found' }));

app.listen(PORT, '0.0.0.0', () => {
  console.log(`[jackdany] backend in ascolto su :${PORT} (DATA_DIR=${DATA_DIR})`);
  if (!fs.existsSync(DATA_DIR)) console.warn('[jackdany] DATA_DIR mancante!');
});
