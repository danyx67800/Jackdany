// Store JSON puro (zero dipendenze native) — ideale per Umbrel/RPi.
// File: $DATA_DIR/db.json + $DATA_DIR/uploads/
const fs = require('fs');
const path = require('path');
const bcrypt = require('bcryptjs');

const DATA_DIR = process.env.DATA_DIR || path.join(__dirname, '..', 'data');
if (!fs.existsSync(DATA_DIR)) fs.mkdirSync(DATA_DIR, { recursive: true });

const DB_FILE = path.join(DATA_DIR, 'db.json');

function now() { return new Date().toISOString(); }

function load() {
  try {
    return JSON.parse(fs.readFileSync(DB_FILE, 'utf8'));
  } catch {
    return null;
  }
}
function save(state) {
  fs.writeFileSync(DB_FILE, JSON.stringify(state, null, 2));
}

let state = load();
if (!state) {
  const adminUser = process.env.ADMIN_USER || 'admin';
  const adminPass = process.env.ADMIN_PASSWORD || 'jackdany-admin';
  state = {
    seq: { news: 5, photos: 1, messages: 1 },
    users: [{ id: 1, username: adminUser, password_hash: bcrypt.hashSync(adminPass, 10), created_at: now() }],
    news: [
      { id: 1, title: 'Starship: nuovo test orbitale riuscito', category: 'spazio', excerpt: 'SpaceX completa un nuovo volo di Starship.', body: 'Corpo demo...', image_url: '', published: 1, published_at: now(), created_at: now(), updated_at: now() },
      { id: 2, title: 'Nuovo chip AI da record', category: 'tech', excerpt: 'Presentato un SoC con NPU da 100 TOPS.', body: 'Corpo demo...', image_url: '', published: 1, published_at: now(), created_at: now(), updated_at: now() },
      { id: 3, title: 'A350: consegne in crescita', category: 'aerei', excerpt: 'Airbus accelera le consegne del wide-body.', body: 'Corpo demo...', image_url: '', published: 1, published_at: now(), created_at: now(), updated_at: now() },
      { id: 4, title: 'F1: anteprima GP di Monza', category: 'f1', excerpt: 'Orari, strategie e favoriti del weekend.', body: 'Corpo demo...', image_url: '', published: 1, published_at: now(), created_at: now(), updated_at: now() },
    ],
    settings: {
      app_name: 'Jack Dany',
      backend_base_url: '',
      secret_pin_hash: bcrypt.hashSync(process.env.SECRET_PIN || '1234', 10),
      f1_provider: 'openf1',
      maintenance_mode: 'false',
    },
    secret_photos: [],
    secret_messages: [],
  };
  // Se admin custom via env e seed già con altro nome, garantisci presenza
  save(state);
  console.log(`[db] inizializzato ${DB_FILE} (admin: ${state.users[0].username})`);
}

function persist() { save(state); }

// ---- Settings ----
function getSetting(key, fallback = '') {
  return state.settings[key] ?? fallback;
}
function setSetting(key, value) {
  state.settings[key] = value;
  persist();
}

// ---- Users ----
function findUser(username) {
  return state.users.find((u) => u.username === username);
}
function updateUserPassword(id, hash) {
  const u = state.users.find((x) => x.id === id);
  if (u) { u.password_hash = hash; persist(); }
}

// ---- News ----
function listNews({ category, publishedOnly = true, limit = 50 } = {}) {
  let rows = [...state.news].sort((a, b) => (b.published_at || '').localeCompare(a.published_at || ''));
  if (category) rows = rows.filter((r) => r.category === category);
  if (publishedOnly) rows = rows.filter((r) => r.published === 1);
  return rows.slice(0, Math.min(limit, 200));
}
function listAllNews() {
  return [...state.news].sort((a, b) => (b.created_at || '').localeCompare(a.created_at || ''));
}
function getNews(id, publishedOnly = true) {
  const r = state.news.find((x) => String(x.id) === String(id));
  if (!r) return null;
  if (publishedOnly && r.published !== 1) return null;
  return r;
}
function createNews(v) {
  const id = state.seq.news++;
  const row = { id, published_at: now(), created_at: now(), updated_at: now(), ...v };
  state.news.push(row);
  persist();
  return row;
}
function updateNews(id, patch) {
  const r = state.news.find((x) => String(x.id) === String(id));
  if (!r) return null;
  Object.assign(r, patch, { updated_at: now() });
  persist();
  return r;
}
function deleteNews(id) {
  state.news = state.news.filter((x) => String(x.id) !== String(id));
  persist();
}

// ---- Secret photos/messages ----
function listPhotos() { return [...state.secret_photos].sort((a, b) => (b.created_at || '').localeCompare(a.created_at || '')); }
function addPhoto({ title, image_path }) {
  const row = { id: state.seq.photos++, title: title || '', image_path, created_at: now() };
  state.secret_photos.push(row); persist(); return row;
}
function deletePhoto(id) {
  const r = state.secret_photos.find((x) => String(x.id) === String(id));
  state.secret_photos = state.secret_photos.filter((x) => String(x.id) !== String(id));
  persist();
  return r;
}
function listMessages() { return [...state.secret_messages].sort((a, b) => (b.created_at || '').localeCompare(a.created_at || '')); }
function addMessage({ title, body }) {
  const row = { id: state.seq.messages++, title, body, created_at: now() };
  state.secret_messages.push(row); persist(); return row;
}
function updateMessage(id, patch) {
  const r = state.secret_messages.find((x) => String(x.id) === String(id));
  if (!r) return null;
  Object.assign(r, patch); persist(); return r;
}
function deleteMessage(id) {
  state.secret_messages = state.secret_messages.filter((x) => String(x.id) !== String(id));
  persist();
}

module.exports = {
  DATA_DIR,
  getSetting, setSetting,
  findUser, updateUserPassword,
  listNews, listAllNews, getNews, createNews, updateNews, deleteNews,
  listPhotos, addPhoto, deletePhoto,
  listMessages, addMessage, updateMessage, deleteMessage,
};
