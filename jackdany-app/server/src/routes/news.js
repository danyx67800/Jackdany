const express = require('express');
const { listNews, listAllNews, getNews, createNews, updateNews, deleteNews } = require('../db');
const { requireAdmin } = require('../middleware/auth');

const router = express.Router();
const CATS = ['tech', 'spazio', 'aerei', 'f1'];

// Pubblica: GET /api/news?category=tech&limit=20
router.get('/', (req, res) => {
  const { category, limit = 50 } = req.query;
  const cat = category && CATS.includes(category) ? category : undefined;
  res.json(listNews({ category: cat, publishedOnly: true, limit: Number(limit) || 50 }));
});

// Admin: GET /api/news/admin/all (include bozze) — prima di /:id!
router.get('/admin/all', requireAdmin, (req, res) => {
  res.json(listAllNews());
});

// Pubblica: GET /api/news/:id
router.get('/:id', (req, res) => {
  const row = getNews(req.params.id, true);
  if (!row) return res.status(404).json({ error: 'notizia non trovata' });
  res.json(row);
});

// Admin: POST /api/news
router.post('/', requireAdmin, (req, res) => {
  const { title, category, excerpt = '', body = '', image_url = '', published = 1 } = req.body || {};
  if (!title || !CATS.includes(category))
    return res.status(400).json({ error: 'title e category (tech|spazio|aerei|f1) richiesti' });
  res.status(201).json(createNews({ title, category, excerpt, body, image_url, published: published ? 1 : 0 }));
});

// Admin: PUT /api/news/:id
router.put('/:id', requireAdmin, (req, res) => {
  const cur = getNews(req.params.id, false);
  if (!cur) return res.status(404).json({ error: 'notizia non trovata' });
  const patch = { ...req.body };
  if (patch.category && !CATS.includes(patch.category))
    return res.status(400).json({ error: 'category non valida' });
  if (patch.published !== undefined) patch.published = patch.published ? 1 : 0;
  delete patch.id;
  res.json(updateNews(req.params.id, patch));
});

// Admin: DELETE /api/news/:id
router.delete('/:id', requireAdmin, (req, res) => {
  deleteNews(req.params.id);
  res.json({ ok: true });
});

module.exports = router;
