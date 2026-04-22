// ============================================================
// main.js — Κοινές λειτουργίες (navbar, toast, cards, κλπ.)
// ============================================================

// --- Navbar hamburger ---
document.addEventListener('DOMContentLoaded', () => {
  const hamburger = document.querySelector('.hamburger');
  const navLinks = document.querySelector('.nav-links');
  if (hamburger && navLinks) {
    hamburger.addEventListener('click', () => navLinks.classList.toggle('open'));
  }

  // Σήμανση ενεργού συνδέσμου
  const currentPage = window.location.pathname.split('/').pop();
  document.querySelectorAll('.nav-links a').forEach(a => {
    if (a.getAttribute('href') === currentPage) a.classList.add('active');
  });
});

// --- Toast Notifications ---
function showToast(msg, type = '') {
  let toast = document.getElementById('toast');
  if (!toast) {
    toast = document.createElement('div');
    toast.id = 'toast';
    toast.className = 'toast';
    document.body.appendChild(toast);
  }
  toast.textContent = msg;
  toast.className = `toast ${type}`;
  requestAnimationFrame(() => {
    toast.classList.add('show');
  });
  clearTimeout(toast._timer);
  toast._timer = setTimeout(() => toast.classList.remove('show'), 3200);
}

// --- Κάρτα ακινήτου (HTML) ---
function buildCard(prop, viewMode = 'grid') {
  const isRent = prop.type === 'rent';
  const badgeClass = isRent ? 'badge-rent' : 'badge-sale';
  const badgeText = isRent ? 'Ενοικίαση' : 'Πώληση';
  const priceStr = prop.price.toLocaleString('el-GR') + ' €' + (isRent ? '/μήνα' : '');
  const img = (prop.images && prop.images[0])
    ? `<img src="${prop.images[0]}" alt="${prop.title}" loading="lazy" onerror="this.src='https://images.unsplash.com/photo-1560518883-ce09059eeffa?w=600&q=70'">`
    : `<div style="background:#dde3ee;width:100%;height:100%;display:flex;align-items:center;justify-content:center;color:#aaa;font-size:2rem;"><i class="fas fa-home"></i></div>`;

  const roomsHtml = prop.rooms > 0
    ? `<span><i class="fas fa-bed"></i> ${prop.rooms} υπν.</span>` : '';
  const bathHtml = prop.bathrooms > 0
    ? `<span><i class="fas fa-bath"></i> ${prop.bathrooms} μπ.</span>` : '';

  if (viewMode === 'list') {
    return `
      <div class="property-card list-card" onclick="location.href='provolh.html?id=${prop.id}'">
        <div class="card-img">
          ${img}
          <span class="card-badge ${badgeClass}">${badgeText}</span>
        </div>
        <div class="card-body">
          <div>
            <div class="card-price">${priceStr}</div>
            <div class="card-title">${prop.title}</div>
            <div class="card-location"><i class="fas fa-map-marker-alt"></i> ${prop.neighborhood}, ${prop.location}</div>
            <div class="card-features">
              <span><i class="fas fa-vector-square"></i> ${prop.area} τμ</span>
              ${roomsHtml}${bathHtml}
              <span><i class="fas fa-building"></i> ${DB.getCategoryLabel(prop.category)}</span>
            </div>
          </div>
          <p style="font-size:0.85rem;color:#666;margin-top:10px;line-height:1.5;">
            ${prop.description.substring(0, 130)}...
          </p>
        </div>
      </div>`;
  }

  return `
    <div class="property-card" onclick="location.href='provolh.html?id=${prop.id}'">
      <div class="card-img">
        ${img}
        <span class="card-badge ${badgeClass}">${badgeText}</span>
        <button class="card-fav" onclick="event.stopPropagation(); toggleFav(${prop.id}, this)" title="Αποθήκευση">
          <i class="fas fa-heart"></i>
        </button>
      </div>
      <div class="card-body">
        <div class="card-price">${priceStr}</div>
        <div class="card-title">${prop.title}</div>
        <div class="card-location"><i class="fas fa-map-marker-alt"></i> ${prop.neighborhood}, ${prop.location}</div>
        <div class="card-features">
          <span><i class="fas fa-vector-square"></i> ${prop.area} τμ</span>
          ${roomsHtml}${bathHtml}
        </div>
      </div>
    </div>`;
}

// --- Αγαπημένα (localStorage) ---
function getFavs() {
  return JSON.parse(localStorage.getItem('re_favs') || '[]');
}

function toggleFav(id, btn) {
  let favs = getFavs();
  if (favs.includes(id)) {
    favs = favs.filter(f => f !== id);
    btn && btn.classList.remove('active');
    showToast('Αφαιρέθηκε από τα αγαπημένα');
  } else {
    favs.push(id);
    btn && btn.classList.add('active');
    showToast('Προστέθηκε στα αγαπημένα ♥', 'success');
  }
  localStorage.setItem('re_favs', JSON.stringify(favs));
}

// Εφαρμογή αγαπημένων σε κάρτες
function applyFavStates() {
  const favs = getFavs();
  document.querySelectorAll('.card-fav').forEach(btn => {
    const id = Number(btn.getAttribute('onclick')?.match(/\d+/)?.[0]);
    if (favs.includes(id)) btn.classList.add('active');
  });
}
