const express = require('express');
const { getSetting, setSetting } = require('../db');
const { requireAdmin } = require('../middleware/auth');

const router = express.Router();
const PUBLIC_KEYS = ['app_name', 'backend_base_url', 'f1_provider', 'maintenance_mode'];

// Pubbliche (l'app mobile le legge senza auth)
router.get('/', (req, res) => {
  const out = {};
  for (const k of PUBLIC_KEYS) out[k] = getSetting(k, '');
  res.json(out);
});

// Admin: aggiorna impostazioni
router.put('/', requireAdmin, (req, res) => {
  const allowed = [...PUBLIC_KEYS];
  for (const [k, v] of Object.entries(req.body || {})) {
    if (allowed.includes(k)) setSetting(k, String(v));
  }
  const out = {};
  for (const k of PUBLIC_KEYS) out[k] = getSetting(k, '');
  res.json(out);
});

module.exports = router;
