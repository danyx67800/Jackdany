const $ = (id) => document.getElementById(id);
const api = (p, opts = {}) => {
  const t = localStorage.getItem('jd_token');
  const h = { 'Content-Type': 'application/json', ...(opts.headers || {}) };
  if (t) h.Authorization = 'Bearer ' + t;
  return fetch(p, { ...opts, headers: h }).then(async (r) => {
    const j = await r.json().catch(() => ({}));
    if (!r.ok) throw new Error(j.error || ('HTTP ' + r.status));
    return j;
  });
};
const toast = (m) => { const t = $('toast'); t.textContent = m; t.style.display = 'block'; setTimeout(() => t.style.display = 'none', 2200); };

document.querySelectorAll('.tabs button').forEach((b) =>
  b.addEventListener('click', () => {
    document.querySelectorAll('.tabs button').forEach((x) => x.classList.remove('active'));
    b.classList.add('active');
    document.querySelectorAll('.tab').forEach((s) => s.classList.add('hidden'));
    $('tab-' + b.dataset.tab).classList.remove('hidden');
  })
);

let editingId = null;
async function refreshAuth() {
  const t = localStorage.getItem('jd_token');
  $('logoutBtn').classList.toggle('hidden', !t);
}
$('loginBtn').onclick = async () => {
  try {
    const j = await api('/api/auth/login', { method: 'POST', body: JSON.stringify({ username: $('user').value, password: $('pass').value }) });
    localStorage.setItem('jd_token', j.token);
    toast('Accesso riuscito'); refreshAuth(); loadAll();
  } catch (e) { toast('Login fallito: ' + e.message); }
};
$('logoutBtn').onclick = () => { localStorage.removeItem('jd_token'); refreshAuth(); };

// ---- News ----
async function loadNews() {
  try {
    const rows = await api('/api/news/admin/all');
    const f = $('filterCat').value;
    const list = $('newsList'); list.innerHTML = '';
    rows.filter((r) => !f || r.category === f).forEach((r) => {
      const d = document.createElement('div'); d.className = 'item';
      d.innerHTML = `<b>${r.title}</b><div class="meta">#${r.id} · ${r.category} · ${r.published ? 'pubblicata' : 'bozza'} · ${r.published_at}</div><div>${(r.excerpt || '').slice(0, 140)}</div><div class="actions"></div>`;
      const eb = document.createElement('button'); eb.textContent = 'Modifica'; eb.className = 'ghost';
      eb.onclick = () => { editingId = r.id; $('nTitle').value = r.title; $('nCat').value = r.category; $('nImg').value = r.image_url || ''; $('nPub').checked = !!r.published; $('nExcerpt').value = r.excerpt || ''; $('nBody').value = r.body || ''; window.scrollTo({ top: 0 }); };
      const db = document.createElement('button'); db.textContent = 'Elimina'; db.className = 'ghost';
      db.onclick = async () => { if (confirm('Eliminare?')) { await api('/api/news/' + r.id, { method: 'DELETE' }); loadNews(); } };
      d.querySelector('.actions').append(eb, db);
      list.appendChild(d);
    });
  } catch (e) { $('newsList').innerHTML = '<p class="muted">Fai login come admin per gestire le notizie.</p>'; }
}
$('reloadNews').onclick = loadNews; $('filterCat').onchange = loadNews;
$('resetNews').onclick = () => { editingId = null; ['nTitle','nImg','nExcerpt','nBody'].forEach((i) => $(i).value = ''); };
$('saveNews').onclick = async () => {
  const body = { title: $('nTitle').value, category: $('nCat').value, image_url: $('nImg').value, published: $('nPub').checked ? 1 : 0, excerpt: $('nExcerpt').value, body: $('nBody').value };
  try {
    if (editingId) await api('/api/news/' + editingId, { method: 'PUT', body: JSON.stringify(body) });
    else await api('/api/news', { method: 'POST', body: JSON.stringify(body) });
    toast('Notizia salvata'); editingId = null; $('resetNews').click(); loadNews();
  } catch (e) { toast('Errore: ' + e.message); }
};

// ---- Secret ----
async function loadSecret() {
  try {
    const t = localStorage.getItem('jd_token');
    const h = { Authorization: 'Bearer ' + t };
    const photos = await fetch('/api/secret/photos', { headers: h }).then((r) => r.json());
    const pl = $('photoList'); pl.innerHTML = '';
    (Array.isArray(photos) ? photos : []).forEach((p) => {
      const d = document.createElement('div'); d.className = 'ph';
      d.innerHTML = `<img src="${p.image_url}" /><div>${p.title || ''}</div>`;
      const b = document.createElement('button'); b.textContent = 'Elimina'; b.className = 'ghost';
      b.onclick = async () => { await api('/api/secret/photos/' + p.id, { method: 'DELETE' }); loadSecret(); };
      d.appendChild(b); pl.appendChild(d);
    });
    const msgs = await fetch('/api/secret/messages', { headers: h }).then((r) => r.json());
    const ml = $('msgList'); ml.innerHTML = '';
    (Array.isArray(msgs) ? msgs : []).forEach((m) => {
      const d = document.createElement('div'); d.className = 'item';
      d.innerHTML = `<b>${m.title}</b><div class="meta">#${m.id} · ${m.created_at}</div><div>${m.body}</div>`;
      const b = document.createElement('button'); b.textContent = 'Elimina'; b.className = 'ghost';
      b.onclick = async () => { await api('/api/secret/messages/' + m.id, { method: 'DELETE' }); loadSecret(); };
      d.appendChild(b); ml.appendChild(d);
    });
  } catch { /* non admin */ }
}
$('uploadPhoto').onclick = async () => {
  const f = $('phFile').files[0]; if (!f) return toast('Seleziona un file');
  const fd = new FormData(); fd.append('photo', f); fd.append('title', $('phTitle').value);
  const t = localStorage.getItem('jd_token');
  const r = await fetch('/api/secret/photos', { method: 'POST', headers: { Authorization: 'Bearer ' + t }, body: fd });
  if (!r.ok) return toast('Upload fallito');
  toast('Foto caricata'); loadSecret();
};
$('saveMsg').onclick = async () => {
  try { await api('/api/secret/messages', { method: 'POST', body: JSON.stringify({ title: $('mTitle').value, body: $('mBody').value }) }); toast('Messaggio salvato'); loadSecret(); }
  catch (e) { toast('Errore: ' + e.message); }
};
$('savePin').onclick = async () => {
  try { await api('/api/secret/pin', { method: 'POST', body: JSON.stringify({ newPin: $('newPin').value }) }); toast('PIN aggiornato'); }
  catch (e) { toast('Errore: ' + e.message); }
};

// ---- Settings ----
async function loadSettings() {
  try {
    const s = await api('/api/settings');
    $('sAppName').value = s.app_name || ''; $('sF1').value = s.f1_provider || 'openf1';
    $('sMaint').value = s.maintenance_mode || 'false';
  } catch {}
}
$('saveSettings').onclick = async () => {
  try { await api('/api/settings', { method: 'PUT', body: JSON.stringify({ app_name: $('sAppName').value, f1_provider: $('sF1').value, maintenance_mode: $('sMaint').value }) }); toast('Impostazioni salvate'); }
  catch (e) { toast('Errore: ' + e.message); }
};
$('savePass').onclick = async () => {
  try { await api('/api/auth/change-password', { method: 'POST', body: JSON.stringify({ oldPassword: $('oldPass').value, newPassword: $('newPass').value }) }); toast('Password aggiornata'); }
  catch (e) { toast('Errore: ' + e.message); }
};

function loadAll() { loadNews(); loadSecret(); loadSettings(); }
refreshAuth(); loadAll();
