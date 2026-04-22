-- ============================================================
-- HomeFind — Supabase Schema
-- Τρέξε αυτό στο SQL Editor του Supabase project σου
-- ============================================================

-- 1. TABLES

CREATE TABLE IF NOT EXISTS properties (
  id          BIGSERIAL PRIMARY KEY,
  type        TEXT NOT NULL,
  category    TEXT NOT NULL,
  title       TEXT NOT NULL,
  price       NUMERIC NOT NULL,
  area        NUMERIC NOT NULL,
  rooms       INTEGER DEFAULT 0,
  bathrooms   INTEGER DEFAULT 0,
  floor       INTEGER DEFAULT 0,
  location    TEXT,
  neighborhood TEXT,
  address     TEXT,
  year        INTEGER,
  description TEXT,
  amenities   JSONB DEFAULT '[]',
  images      JSONB DEFAULT '[]',
  agent       TEXT,
  phone       TEXT,
  status      TEXT DEFAULT 'active',
  date        DATE DEFAULT CURRENT_DATE,
  views       INTEGER DEFAULT 0,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS requests (
  id          BIGSERIAL PRIMARY KEY,
  type        TEXT,
  category    TEXT,
  title       TEXT,
  price       NUMERIC,
  area        NUMERIC,
  rooms       INTEGER DEFAULT 0,
  bathrooms   INTEGER DEFAULT 0,
  floor       INTEGER DEFAULT 0,
  location    TEXT,
  neighborhood TEXT,
  address     TEXT,
  year        INTEGER,
  description TEXT,
  amenities   JSONB DEFAULT '[]',
  images      JSONB DEFAULT '[]',
  agent       TEXT,
  phone       TEXT,
  owner_email TEXT,
  status      TEXT DEFAULT 'pending',
  date        DATE DEFAULT CURRENT_DATE,
  views       INTEGER DEFAULT 0,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS contacts (
  id              BIGSERIAL PRIMARY KEY,
  name            TEXT,
  email           TEXT,
  phone           TEXT,
  message         TEXT,
  property_id     BIGINT,
  property_title  TEXT,
  subject         TEXT,
  date            DATE DEFAULT CURRENT_DATE,
  read            BOOLEAN DEFAULT FALSE,
  created_at      TIMESTAMPTZ DEFAULT NOW()
);

-- 2. ROW LEVEL SECURITY

ALTER TABLE properties ENABLE ROW LEVEL SECURITY;
ALTER TABLE requests    ENABLE ROW LEVEL SECURITY;
ALTER TABLE contacts    ENABLE ROW LEVEL SECURITY;

CREATE POLICY "public_all_properties" ON properties FOR ALL TO anon USING (true) WITH CHECK (true);
CREATE POLICY "public_all_requests"   ON requests    FOR ALL TO anon USING (true) WITH CHECK (true);
CREATE POLICY "public_all_contacts"   ON contacts    FOR ALL TO anon USING (true) WITH CHECK (true);

-- 3. RPC για atomic increment views

CREATE OR REPLACE FUNCTION increment_views(property_id BIGINT)
RETURNS void AS $$
  UPDATE properties SET views = views + 1 WHERE id = property_id;
$$ LANGUAGE SQL SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION increment_views TO anon;

-- 4. SEED DATA (demo ακίνητα)

INSERT INTO properties (type, category, title, price, area, rooms, bathrooms, floor, location, neighborhood, address, year, description, amenities, images, agent, phone, status, date, views) VALUES
(
  'sale', 'apartment', 'Μοντέρνο διαμέρισμα στο κέντρο', 145000, 78, 2, 1, 3,
  'Αθήνα', 'Κολωνάκι', 'Σκουφά 14', 2018,
  'Πωλείται φωτεινό διαμέρισμα 78τμ στην καρδιά του Κολωνακίου. Το ακίνητο βρίσκεται σε τρίτο όροφο πολυκατοικίας και διαθέτει υψηλές οροφές, σαλόνι-κουζίνα ανοιχτού σχεδίου, δύο υπνοδωμάτια και μπάνιο. Ανακαινισμένο πλήρως το 2020.',
  '["Ανελκυστήρας","A/C","Ηλιακός","Φυσικό αέριο","Αποθήκη"]',
  '["https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?w=800&q=80","https://images.unsplash.com/photo-1484154218962-a197022b5858?w=400&q=80"]',
  'Γιώργος Παπαδόπουλος', '210 123 4567', 'active', '2025-03-10', 142
),
(
  'rent', 'apartment', 'Ευρύχωρο τριάρι με θέα', 750, 95, 3, 1, 5,
  'Θεσσαλονίκη', 'Άνω Πόλη', 'Ολύμπου 22', 2005,
  'Ενοικιάζεται τριάρι 95τμ με εκπληκτική θέα στον Θερμαϊκό. Βρίσκεται σε πέμπτο όροφο πολυκατοικίας κοντά στο Λευκό Πύργο. Διαθέτει μεγάλο σαλόνι, 3 υπνοδωμάτια, κουζίνα και ένα μπάνιο.',
  '["A/C","Φυσικό αέριο","Πάρκινγκ"]',
  '["https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=800&q=80","https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=400&q=80"]',
  'Μαρία Αντωνίου', '2310 456 789', 'active', '2025-04-01', 88
),
(
  'sale', 'house', 'Μονοκατοικία με κήπο', 320000, 160, 4, 2, 2,
  'Αθήνα', 'Παλαιό Φάληρο', 'Αμφιτρίτης 7', 1995,
  'Πωλείται διώροφη μονοκατοικία 160τμ με κήπο 200τμ στο Παλαιό Φάληρο. Ισόγειο: σαλόνι, τραπεζαρία, κουζίνα, W/C. Α΄ όροφος: 4 υπνοδωμάτια, 2 μπάνια. Αυτόνομη θέρμανση, τζάκι.',
  '["Κήπος","Τζάκι","Αποθήκη","Φυσικό αέριο","Πάρκινγκ","A/C"]',
  '["https://images.unsplash.com/photo-1568605114967-8130f3a36994?w=800&q=80","https://images.unsplash.com/photo-1570129477492-45c003edd2be?w=400&q=80"]',
  'Νίκος Δημητρίου', '210 987 6543', 'active', '2025-02-20', 215
),
(
  'rent', 'studio', 'Studio κοντά στο ΑΠΘ', 320, 35, 1, 1, 2,
  'Θεσσαλονίκη', 'Πολίτεια', 'Εγνατίας 88', 2010,
  'Ενοικιάζεται studio 35τμ σε 2ο όροφο, λίγα βήματα από το ΑΠΘ. Ιδανικό για φοιτητή/τρια. Πλήρως επιπλωμένο με κουζίνα, μπάνιο και air condition. Αυτόνομη θέρμανση.',
  '["A/C","Επιπλωμένο"]',
  '["https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800&q=80"]',
  'Ελένη Νικολάου', '2310 111 222', 'active', '2025-04-05', 56
),
(
  'sale', 'land', 'Οικόπεδο εντός σχεδίου', 85000, 420, 0, 0, 0,
  'Πάτρα', 'Ρίο', 'Ελ. Βενιζέλου 55', NULL,
  'Πωλείται οικόπεδο 420τμ εντός σχεδίου στο Ρίο Πατρών. Συντελεστής δόμησης 0.8, επιτρέπεται κατοικία έως 3 ορόφους. Πρόσωπο σε ασφαλτοστρωμένο δρόμο.',
  '["Εντός σχεδίου","Γωνιακό"]',
  '["https://images.unsplash.com/photo-1500382017468-9049fed747ef?w=800&q=80"]',
  'Κώστας Ιωάννου', '2610 222 333', 'active', '2025-01-15', 34
),
(
  'rent', 'apartment', 'Ανακαινισμένο διαμέρισμα', 550, 65, 2, 1, 1,
  'Αθήνα', 'Νέος Κόσμος', 'Καλλιρρόης 30', 2000,
  'Ενοικιάζεται πλήρως ανακαινισμένο διαμέρισμα 65τμ. Σαλόνι-κουζίνα, 2 υπνοδωμάτια, μπάνιο. Νέα πάτωμα, πλακάκια, κουζίνα και μπάνιο. Αυτόνομη θέρμανση φυσικού αερίου.',
  '["A/C","Φυσικό αέριο","Ανελκυστήρας"]',
  '["https://images.unsplash.com/photo-1493809842364-78817add7ffb?w=800&q=80","https://images.unsplash.com/photo-1484101403633-562f891dc89a?w=400&q=80"]',
  'Γιώργος Παπαδόπουλος', '210 123 4567', 'active', '2025-03-28', 97
);
