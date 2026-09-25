const express = require('express');
const bcrypt = require('bcryptjs');
const multer = require('multer');
const fs = require('fs');
const path = require('path');
const {
  DATA_DIR, getSetting, setSetting,
  listPhotos, addPhoto, deletePhoto,
  listMessages, addMessage, updateMessage, deleteMessage,
} = require('../db');
const { sign, requireAdmin, requireSecret } = require('../middleware/auth');

const router = express.Router();
const UPLOAD_DIR = path.join(DATA_DIR, 'uploads');
if (!fs.existsSync(UPLOAD_DIR)) fs.mkdirSync(UPLOAD_DIR, { recursive: true });

const storage = multer.diskStorage({
  destination: (_, __, cb) => cb(null, UPLOAD_DIR),
  filename: (_, file, cb) => {
    const ext = path.extname(file.originalname || '.jpg');
    cb(null, `secret-${Date.now()}${ext}`);
  },
});
const upload = multer({ storage, limits: { fileSize: 15 * 1024 * 1024 } });

// --- Mobile: sblocco con PIN -> secret token (scope: secret, 24h) ---
// POST /api/secret/unlock {pin}
router.post('/unlock', (req, res) => {
  const { pin } = req.body || {};
  const hash = getSetting('secret_pin_hash', '');
  if (!hash) return res.status(500).json({ error: 'PIN non configurato' });
  if (!pin || !bcrypt.compareSync(String(pin), hash))
    return res.status(401).json({ error: 'PIN errato' });
  res.json({ token: sign({ scope: 'secret' }, '24h') });
});

// --- Lettura riservata (secret token o admin) ---
router.get('/photos', requireSecret, (req, res) => {
  res.json(listPhotos().map((r) => ({ ...r, image_url: `/uploads/${path.basename(r.image_path)}` })));
});
router.get('/messages', requireSecret, (req, res) => {
  res.json(listMessages());
});

// --- Admin CRUD foto ---
router.post('/photos', requireAdmin, upload.single('photo'), (req, res) => {
  if (!req.file) return res.status(400).json({ error: 'file photo richiesto (multipart)' });
  const { title = '' } = req.body || {};
  res.status(201).json(addPhoto({ title, image_path: req.file.path }));
});
router.delete('/photos/:id', requireAdmin, (req, res) => {
  const row = deletePhoto(req.params.id);
  if (row) { try { fs.unlinkSync(row.image_path); } catch {} }
  res.json({ ok: true });
});

// --- Admin CRUD messaggi ---
router.post('/messages', requireAdmin, (req, res) => {
  const { title, body } = req.body || {};
  if (!title || !body) return res.status(400).json({ error: 'title e body richiesti' });
  res.status(201).json(addMessage({ title, body }));
});
router.put('/messages/:id', requireAdmin, (req, res) => {
  const v = updateMessage(req.params.id, { title: req.body.title, body: req.body.body });
  if (!v) return res.status(404).json({ error: 'messaggio non trovato' });
  res.json(v);
});
router.delete('/messages/:id', requireAdmin, (req, res) => {
  deleteMessage(req.params.id);
  res.json({ ok: true });
});

// --- Admin: cambia PIN sezione segreta ---
router.post('/pin', requireAdmin, (req, res) => {
  const { newPin } = req.body || {};
  if (!newPin || String(newPin).length < 4)
    return res.status(400).json({ error: 'PIN min 4 cifre' });
  setSetting('secret_pin_hash', bcrypt.hashSync(String(newPin), 10));
  res.json({ ok: true });
});

module.exports = router;
