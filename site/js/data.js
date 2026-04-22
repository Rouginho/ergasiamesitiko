// ============================================================
// data.js — Διαχείριση δεδομένων μέσω Supabase
// ============================================================

const _db = window.supabase.createClient(SUPABASE_URL, SUPABASE_KEY);

const DB = {

  async getProperties(filters = {}) {
    let q = _db.from('properties').select('*');

    if (!filters.adminMode) q = q.eq('status', 'active');
    if (filters.type     && filters.type     !== 'all') q = q.eq('type',     filters.type);
    if (filters.category && filters.category !== 'all') q = q.eq('category', filters.category);
    if (filters.location && filters.location !== 'all') q = q.eq('location', filters.location);
    if (filters.minPrice) q = q.gte('price', Number(filters.minPrice));
    if (filters.maxPrice) q = q.lte('price', Number(filters.maxPrice));
    if (filters.minArea)  q = q.gte('area',  Number(filters.minArea));
    if (filters.rooms && filters.rooms !== 'all') q = q.gte('rooms', Number(filters.rooms));

    if      (filters.sort === 'price_asc')  q = q.order('price', { ascending: true  });
    else if (filters.sort === 'price_desc') q = q.order('price', { ascending: false });
    else if (filters.sort === 'area_desc')  q = q.order('area',  { ascending: false });
    else                                    q = q.order('date',  { ascending: false });

    const { data, error } = await q;
    if (error) { console.error('getProperties:', error); return []; }
    return data || [];
  },

  async getProperty(id) {
    const { data, error } = await _db.from('properties').select('*').eq('id', Number(id)).single();
    if (error) return null;
    return data;
  },

  async addRequest(requestData) {
    const { data, error } = await _db.from('requests').insert([{
      ...requestData,
      status: 'pending',
      date: new Date().toISOString().slice(0, 10),
    }]).select().single();
    if (error) throw error;
    return data;
  },

  async getRequests() {
    const { data, error } = await _db.from('requests').select('*').order('created_at', { ascending: false });
    if (error) { console.error('getRequests:', error); return []; }
    return data || [];
  },

  async approveRequest(id) {
    const { data: req } = await _db.from('requests').select('*').eq('id', id).single();
    if (!req) return;
    await _db.from('requests').update({ status: 'approved' }).eq('id', id);
    const { id: _id, created_at, owner_email, status, ...propData } = req;
    await _db.from('properties').insert([{ ...propData, status: 'active' }]);
  },

  async rejectRequest(id) {
    await _db.from('requests').update({ status: 'rejected' }).eq('id', id);
  },

  async deleteProperty(id) {
    await _db.from('properties').delete().eq('id', Number(id));
  },

  async saveContact(contactData) {
    await _db.from('contacts').insert([{
      ...contactData,
      date: new Date().toISOString().slice(0, 10),
      read: false,
    }]);
  },

  async getContacts() {
    const { data, error } = await _db.from('contacts').select('*').order('created_at', { ascending: false });
    if (error) { console.error('getContacts:', error); return []; }
    return data || [];
  },

  async markContactsRead() {
    await _db.from('contacts').update({ read: true }).eq('read', false);
  },

  async incrementViews(id) {
    await _db.rpc('increment_views', { property_id: Number(id) });
  },

  // Σύγχρονα helpers (δεν χρειάζονται DB)
  formatPrice(price, type) {
    const formatted = price.toLocaleString('el-GR');
    return type === 'rent' ? `${formatted} €/μήνα` : `${formatted} €`;
  },

  getCategoryLabel(cat) {
    const labels = {
      apartment: 'Διαμέρισμα', house: 'Μονοκατοικία',
      studio: 'Studio', land: 'Οικόπεδο', commercial: 'Επαγγελματικό',
    };
    return labels[cat] || cat;
  },
};
