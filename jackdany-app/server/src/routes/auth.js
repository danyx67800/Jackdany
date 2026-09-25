const express = require('express');
const bcrypt = require('bcryptjs');
const { findUser, updateUserPassword } = require('../db');
const { sign, requireAdmin } = require('../middleware/auth');

const router = express.Router();

// POST /api/auth/login {username, password} -> {token}
router.post('/login', (req, res) => {
  const { username, password } = req.body || {};
  if (!username || !password) return res.status(400).json({ error: 'username e password richiesti' });
  const user = findUser(username);
  if (!user) return res.status(401).json({ error: 'credenziali non valide' });
  if (!bcrypt.compareSync(password, user.password_hash))
    return res.status(401).json({ error: 'credenziali non valide' });
  const token = sign({ role: 'admin', username: user.username, sub: user.id });
  res.json({ token, username: user.username });
});

// POST /api/auth/change-password (admin)
router.post('/change-password', requireAdmin, (req, res) => {
  const { oldPassword, newPassword } = req.body || {};
  if (!newPassword || newPassword.length < 8)
    return res.status(400).json({ error: 'nuova password min 8 caratteri' });
  const user = findUser(req.user.username);
  if (!bcrypt.compareSync(oldPassword || '', user.password_hash))
    return res.status(401).json({ error: 'vecchia password errata' });
  updateUserPassword(user.id, bcrypt.hashSync(newPassword, 10));
  res.json({ ok: true });
});

module.exports = router;
