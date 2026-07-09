-- ============================================================
-- HomeFind — Migration ασφαλείας
--
-- ΠΡΙΝ ΤΡΕΞΕΙΣ ΑΥΤΟ:
--   1. Supabase Dashboard → Authentication → Users → Add user
--      Φτιάξε τον χρήστη διαχειριστή (email + κωδικός) και τσέκαρε
--      το "Auto Confirm User".
--   2. Αντικατέστησε παρακάτω το ADMIN_EMAIL_EDW με αυτό το email.
--
-- Μετά τρέξε ολόκληρο το αρχείο στο SQL Editor του Supabase.
-- ============================================================

-- 1. Κάτω τα παλιά, ορθάνοιχτα policies.

DROP POLICY IF EXISTS "public_all_properties" ON properties;
DROP POLICY IF EXISTS "public_all_requests"   ON requests;
DROP POLICY IF EXISTS "public_all_contacts"   ON contacts;

-- 2. Ποιος είναι ο διαχειριστής.

CREATE OR REPLACE FUNCTION is_admin() RETURNS boolean AS $$
  SELECT auth.jwt() ->> 'email' = 'ADMIN_EMAIL_EDW';
$$ LANGUAGE SQL STABLE;

-- 3. Τι επιτρέπεται στον απλό επισκέπτη (anon).
--    Διαβάζει μόνο δημοσιευμένα ακίνητα, υποβάλλει αίτηση, στέλνει μήνυμα.
--    Δεν διαβάζει αιτήσεις, δεν διαβάζει μηνύματα, δεν σβήνει τίποτα.

DROP POLICY IF EXISTS "anon_read_active_properties" ON properties;
CREATE POLICY "anon_read_active_properties" ON properties
  FOR SELECT TO anon USING (status = 'active');

DROP POLICY IF EXISTS "anon_insert_requests" ON requests;
CREATE POLICY "anon_insert_requests" ON requests
  FOR INSERT TO anon WITH CHECK (status = 'pending');

DROP POLICY IF EXISTS "anon_insert_contacts" ON contacts;
CREATE POLICY "anon_insert_contacts" ON contacts
  FOR INSERT TO anon WITH CHECK (true);

-- 4. Πλήρης πρόσβαση μόνο στον διαχειριστή.

DROP POLICY IF EXISTS "admin_all_properties" ON properties;
CREATE POLICY "admin_all_properties" ON properties
  FOR ALL TO authenticated USING (is_admin()) WITH CHECK (is_admin());

DROP POLICY IF EXISTS "admin_all_requests" ON requests;
CREATE POLICY "admin_all_requests" ON requests
  FOR ALL TO authenticated USING (is_admin()) WITH CHECK (is_admin());

DROP POLICY IF EXISTS "admin_all_contacts" ON contacts;
CREATE POLICY "admin_all_contacts" ON contacts
  FOR ALL TO authenticated USING (is_admin()) WITH CHECK (is_admin());

-- 5. Έλεγχος: πρέπει να δεις 6 policies συνολικά.

SELECT tablename, policyname, roles, cmd
FROM pg_policies
WHERE tablename IN ('properties', 'requests', 'contacts')
ORDER BY tablename, policyname;
