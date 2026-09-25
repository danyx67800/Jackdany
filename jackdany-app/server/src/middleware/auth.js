const jwt = require('jsonwebtoken');

const JWT_SECRET = process.env.JWT_SECRET || 'dev-only-change-me';

function sign(payload, expiresIn = '12h') {
  return jwt.sign(payload, JWT_SECRET, { expiresIn });
}

function requireAdmin(req, res, next) {
  const h = req.headers.authorization || '';
  const token = h.startsWith('Bearer ') ? h.slice(7) : null;
  if (!token) return res.status(401).json({ error: 'missing token' });
  try {
    const p = jwt.verify(token, JWT_SECRET);
    if (p.role !== 'admin') return res.status(403).json({ error: 'forbidden' });
    req.user = p;
    next();
  } catch {
    return res.status(401).json({ error: 'invalid token' });
  }
}

function requireSecret(req, res, next) {
  const h = req.headers.authorization || '';
  const token = h.startsWith('Bearer ') ? h.slice(7) : null;
  if (!token) return res.status(401).json({ error: 'missing secret token' });
  try {
    const p = jwt.verify(token, JWT_SECRET);
    if (p.scope !== 'secret' && p.role !== 'admin')
      return res.status(403).json({ error: 'forbidden' });
    req.secret = p;
    next();
  } catch {
    return res.status(401).json({ error: 'invalid secret token' });
  }
}

module.exports = { sign, requireAdmin, requireSecret, JWT_SECRET };
