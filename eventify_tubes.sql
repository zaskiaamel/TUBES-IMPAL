-- =====================================================================
-- EVENTIFY - Event Management & Ticketing System
-- Skrip 1 : CREATE DATABASE & CREATE TABLE (DDL)
-- DBMS    : MySQL 8 / MariaDB 10.x (phpMyAdmin - XAMPP)
-- =====================================================================
DROP DATABASE IF EXISTS eventify_tubes;
CREATE DATABASE eventify_tubes
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE eventify_tubes;

-- 1. USERS : akun admin, staff gerbang, dan peserta
CREATE TABLE users (
  id          INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  name        VARCHAR(100)  NOT NULL,
  email       VARCHAR(100)  NOT NULL,
  password    VARCHAR(255)  NOT NULL,
  role        ENUM('admin','staff','participant') NOT NULL DEFAULT 'participant',
  phone       VARCHAR(20)   NULL,
  created_at  TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_users       PRIMARY KEY (id),
  CONSTRAINT uq_users_email UNIQUE (email)
) ENGINE=InnoDB;

-- 2. EVENTS : acara yang dibuat oleh admin
CREATE TABLE events (
  id          INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  title       VARCHAR(150)  NOT NULL,
  description TEXT          NULL,
  `date`      DATE          NOT NULL,
  `time`      TIME          NOT NULL,
  location    VARCHAR(150)  NOT NULL,
  capacity    INT UNSIGNED  NOT NULL,
  category    VARCHAR(50)   NOT NULL,
  image_url   VARCHAR(255)  NULL,
  status      ENUM('draft','published','cancelled','finished')
              NOT NULL DEFAULT 'published',
  created_by  INT UNSIGNED  NOT NULL,
  CONSTRAINT pk_events PRIMARY KEY (id),
  CONSTRAINT ck_events_capacity CHECK (capacity > 0),
  CONSTRAINT fk_events_user FOREIGN KEY (created_by)
    REFERENCES users(id) ON UPDATE CASCADE ON DELETE RESTRICT,
  INDEX idx_events_date (`date`),
  INDEX idx_events_category (category)
) ENGINE=InnoDB;

-- 3. TICKET_TYPES : jenis & harga tiket per event (setara PRODUK)
CREATE TABLE ticket_types (
  id          INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  event_id    INT UNSIGNED  NOT NULL,
  type_name   VARCHAR(50)   NOT NULL,
  price       DECIMAL(12,2) NOT NULL,
  quota       INT UNSIGNED  NOT NULL,
  CONSTRAINT pk_ticket_types PRIMARY KEY (id),
  CONSTRAINT uq_tt_event_name UNIQUE (event_id, type_name),
  CONSTRAINT uq_tt_id_event   UNIQUE (id, event_id),
  CONSTRAINT ck_tt_price CHECK (price >= 0),
  CONSTRAINT fk_tt_event FOREIGN KEY (event_id)
    REFERENCES events(id) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

-- 4. VOUCHERS : kode promo / diskon
CREATE TABLE vouchers (
  id              INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  code            VARCHAR(30)   NOT NULL,
  description     VARCHAR(150)  NULL,
  discount_type   ENUM('percent','fixed') NOT NULL,
  discount_value  DECIMAL(12,2) NOT NULL,
  max_discount    DECIMAL(12,2) NULL,
  min_purchase    DECIMAL(12,2) NOT NULL DEFAULT 0,
  valid_from      DATE          NOT NULL,
  valid_until     DATE          NOT NULL,
  quota           INT UNSIGNED  NOT NULL,
  used_count      INT UNSIGNED  NOT NULL DEFAULT 0,
  CONSTRAINT pk_vouchers PRIMARY KEY (id),
  CONSTRAINT uq_vouchers_code UNIQUE (code),
  CONSTRAINT ck_vouchers_value CHECK (discount_value > 0),
  CONSTRAINT ck_vouchers_date  CHECK (valid_until >= valid_from),
  CONSTRAINT ck_vouchers_used  CHECK (used_count <= quota)
) ENGINE=InnoDB;

-- 5. BOOKINGS : transaksi pemesanan (setara PENJUALAN + detail)
CREATE TABLE bookings (
  id              INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  user_id         INT UNSIGNED  NOT NULL,
  event_id        INT UNSIGNED  NOT NULL,
  ticket_type_id  INT UNSIGNED  NOT NULL,
  voucher_id      INT UNSIGNED  NULL,
  quantity        INT UNSIGNED  NOT NULL,
  subtotal        DECIMAL(12,2) NOT NULL,
  discount_amount DECIMAL(12,2) NOT NULL DEFAULT 0,
  total_price     DECIMAL(12,2) NOT NULL,
  payment_method  ENUM('credit_card','e_wallet','bank_transfer') NOT NULL,
  payment_status  ENUM('pending','paid','failed','refunded')
                  NOT NULL DEFAULT 'pending',
  booked_at       DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_bookings PRIMARY KEY (id),
  CONSTRAINT ck_bookings_qty   CHECK (quantity > 0),
  CONSTRAINT ck_bookings_total CHECK (total_price = subtotal - discount_amount),
  CONSTRAINT fk_bookings_user FOREIGN KEY (user_id)
    REFERENCES users(id) ON UPDATE CASCADE ON DELETE RESTRICT,
  -- FK majemuk: jenis tiket harus milik event yang sama
  CONSTRAINT fk_bookings_tt_event FOREIGN KEY (ticket_type_id, event_id)
    REFERENCES ticket_types(id, event_id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_bookings_voucher FOREIGN KEY (voucher_id)
    REFERENCES vouchers(id) ON UPDATE CASCADE ON DELETE SET NULL,
  INDEX idx_bookings_user (user_id),
  INDEX idx_bookings_status (payment_status)
) ENGINE=InnoDB;

-- 6. PAYMENTS : riwayat pembayaran tiap booking
CREATE TABLE payments (
  id            INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  booking_id    INT UNSIGNED  NOT NULL,
  method        ENUM('credit_card','e_wallet','bank_transfer') NOT NULL,
  amount        DECIMAL(12,2) NOT NULL,
  status        ENUM('pending','success','failed','refunded')
                NOT NULL DEFAULT 'pending',
  reference_no  VARCHAR(40)   NOT NULL,
  paid_at       DATETIME      NULL,
  CONSTRAINT pk_payments PRIMARY KEY (id),
  CONSTRAINT uq_payments_ref UNIQUE (reference_no),
  CONSTRAINT ck_payments_amount CHECK (amount >= 0),
  CONSTRAINT fk_payments_booking FOREIGN KEY (booking_id)
    REFERENCES bookings(id) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

-- 7. TICKETS : e-ticket (satu baris per tiket) hasil booking
CREATE TABLE tickets (
  id           INT UNSIGNED NOT NULL AUTO_INCREMENT,
  booking_id   INT UNSIGNED NOT NULL,
  ticket_code  VARCHAR(20)  NOT NULL,
  status       ENUM('active','used','cancelled') NOT NULL DEFAULT 'active',
  CONSTRAINT pk_tickets PRIMARY KEY (id),
  CONSTRAINT uq_tickets_code UNIQUE (ticket_code),
  CONSTRAINT fk_tickets_booking FOREIGN KEY (booking_id)
    REFERENCES bookings(id) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

-- 8. EVENT_STAFF : petugas yang ditugaskan di tiap event (setara KASIR)
CREATE TABLE event_staff (
  event_id     INT UNSIGNED NOT NULL,
  user_id      INT UNSIGNED NOT NULL,
  duty         VARCHAR(50)  NOT NULL,
  assigned_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_event_staff PRIMARY KEY (event_id, user_id),
  CONSTRAINT fk_es_event FOREIGN KEY (event_id)
    REFERENCES events(id) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_es_user FOREIGN KEY (user_id)
    REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

-- 9. CHECKIN_LOGS : log pemindaian tiket di pintu masuk
CREATE TABLE checkin_logs (
  id          INT UNSIGNED NOT NULL AUTO_INCREMENT,
  ticket_id   INT UNSIGNED NOT NULL,
  scanned_by  INT UNSIGNED NOT NULL,
  scanned_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  result      ENUM('valid','duplicate','invalid') NOT NULL,
  CONSTRAINT pk_checkin_logs PRIMARY KEY (id),
  CONSTRAINT fk_cl_ticket FOREIGN KEY (ticket_id)
    REFERENCES tickets(id) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_cl_user FOREIGN KEY (scanned_by)
    REFERENCES users(id) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- =====================================================================
-- Skrip 2 : INSERT 5 data untuk setiap tabel (DML)
-- Urutan insert mengikuti ketergantungan Foreign Key
-- =====================================================================

-- 1. users
INSERT INTO users (id, name, email, password, role, phone) VALUES
(1, 'System Admin',  'admin@eventify.com', MD5('admin123'), 'admin',       '081200000001'),
(2, 'Gate Staff',    'staff@eventify.com', MD5('staff123'), 'staff',       '081200000002'),
(3, 'Budi Santoso',  'budi@mail.com',      MD5('budi123'),  'participant', '081311110003'),
(4, 'Sari Dewi',     'sari@mail.com',      MD5('sari123'),  'participant', '081322220004'),
(5, 'Rina Kusuma',   'rina@mail.com',      MD5('rina123'),  'participant', '081333330005');

-- 2. events
INSERT INTO events (id, title, description, `date`, `time`, location, capacity, category, image_url, status, created_by) VALUES
(1, 'Java Music Festival 2026',
    'Festival musik terbesar di Jawa Barat yang menampilkan artis lokal dan internasional.',
    '2026-09-12', '16:00:00', 'Stadion Si Jalak Harupat, Bandung', 5000, 'Music', 'images/event1.jpg', 'finished', 1),
(2, 'Tech Summit Indonesia 2026',
    'Konferensi teknologi terbesar di Indonesia, menghadirkan pembicara dari berbagai perusahaan teknologi.',
    '2026-09-26', '09:00:00', 'Jakarta Convention Center, Jakarta', 2000, 'Technology', 'images/event2.jpg', 'finished', 1),
(3, 'Bandung Food Festival 2026',
    'Pameran kuliner terlengkap se-Jawa Barat dengan ratusan tenant makanan dan minuman.',
    '2026-10-03', '10:00:00', 'Lapangan Gasibu, Bandung', 10000, 'Food', 'images/event3.jpg', 'finished', 1),
(4, 'Workshop UI/UX Design Intensive',
    'Workshop intensif dua hari untuk belajar desain UI/UX dari dasar hingga prototipe.',
    '2026-11-14', '08:00:00', 'Coworking Space KICKNOW, Bandung', 100, 'Education', 'images/event4.jpg', 'published', 1),
(5, 'Badminton Open Tournament 2026',
    'Turnamen bulu tangkis terbuka untuk umum tingkat Kota Bandung.',
    '2026-12-25', '07:00:00', 'GOR Arcamanik, Bandung', 500, 'Sport', 'images/event5.jpg', 'published', 1);

-- 3. ticket_types
INSERT INTO ticket_types (id, event_id, type_name, price, quota) VALUES
(1, 1, 'Regular',     150000.00,  3000),
(2, 1, 'VIP',         350000.00,   500),
(3, 2, 'General',     200000.00,  1500),
(4, 3, 'Tiket Masuk',  25000.00, 10000),
(5, 4, 'Early Bird',  299000.00,    30);

-- 4. vouchers
INSERT INTO vouchers (id, code, description, discount_type, discount_value, max_discount, min_purchase, valid_from, valid_until, quota, used_count) VALUES
(1, 'EVT10',    'Diskon 10% semua event',          'percent',  10.00,  50000.00, 100000.00, '2026-08-01', '2026-12-31', 500, 1),
(2, 'HEMAT5K',  'Potongan Rp5.000',                'fixed',  5000.00,      NULL,  20000.00, '2026-09-01', '2026-12-31', 300, 1),
(3, 'NEWUSER',  'Diskon 15% pengguna baru',        'percent',  15.00,  75000.00,  50000.00, '2026-08-01', '2026-12-31', 100, 0),
(4, 'VIP20',    'Diskon 20% tiket premium',        'percent',  20.00, 150000.00, 300000.00, '2026-10-01', '2026-12-31',  20, 0),
(5, 'PELAJAR',  'Potongan Rp10.000 untuk pelajar', 'fixed',  10000.00,      NULL,  25000.00, '2026-09-01', '2026-12-31', 200, 0);

-- 5. bookings
INSERT INTO bookings (id, user_id, event_id, ticket_type_id, voucher_id, quantity, subtotal, discount_amount, total_price, payment_method, payment_status, booked_at) VALUES
(1, 3, 1, 1, NULL, 1, 150000.00,     0.00, 150000.00, 'e_wallet',      'paid', '2026-08-20 10:15:30'),
(2, 4, 1, 2, 1,    1, 350000.00, 35000.00, 315000.00, 'credit_card',   'paid', '2026-08-22 14:20:05'),
(3, 5, 2, 3, NULL, 1, 200000.00,     0.00, 200000.00, 'bank_transfer', 'paid', '2026-09-01 09:05:45'),
(4, 3, 3, 4, 2,    1,  25000.00,  5000.00,  20000.00, 'e_wallet',      'paid', '2026-09-15 19:30:10'),
(5, 4, 3, 4, NULL, 1,  25000.00,     0.00,  25000.00, 'credit_card',   'paid', '2026-09-16 08:12:00');

-- 6. payments
INSERT INTO payments (id, booking_id, method, amount, status, reference_no, paid_at) VALUES
(1, 1, 'e_wallet',      150000.00, 'success', 'PAY-20260820-0001', '2026-08-20 10:16:02'),
(2, 2, 'credit_card',   315000.00, 'success', 'PAY-20260822-0002', '2026-08-22 14:21:11'),
(3, 3, 'bank_transfer', 200000.00, 'success', 'PAY-20260901-0003', '2026-09-01 09:30:27'),
(4, 4, 'e_wallet',       20000.00, 'success', 'PAY-20260915-0004', '2026-09-15 19:31:00'),
(5, 5, 'credit_card',    25000.00, 'success', 'PAY-20260916-0005', '2026-09-16 08:12:45');

-- 7. tickets
INSERT INTO tickets (id, booking_id, ticket_code, status) VALUES
(1, 1, 'EVT-A1B2-C3D4', 'used'),
(2, 2, 'EVT-E5F6-G7H8', 'used'),
(3, 3, 'EVT-I9J0-K1L2', 'used'),
(4, 4, 'EVT-M3N4-O5P6', 'used'),
(5, 5, 'EVT-Q7R8-S9T0', 'active');

-- 8. event_staff
INSERT INTO event_staff (event_id, user_id, duty, assigned_at) VALUES
(1, 1, 'Event Manager', '2026-08-01 09:00:00'),
(1, 2, 'Gate Scanner',  '2026-08-01 09:05:00'),
(2, 2, 'Gate Scanner',  '2026-08-10 09:00:00'),
(3, 2, 'Gate Scanner',  '2026-08-20 09:00:00'),
(4, 1, 'Event Manager', '2026-10-01 09:00:00');

-- 9. checkin_logs
INSERT INTO checkin_logs (id, ticket_id, scanned_by, scanned_at, result) VALUES
(1, 1, 2, '2026-09-12 15:32:10', 'valid'),
(2, 1, 2, '2026-09-12 15:50:44', 'duplicate'),
(3, 2, 2, '2026-09-12 15:35:02', 'valid'),
(4, 3, 2, '2026-09-26 08:41:18', 'valid'),
(5, 4, 2, '2026-10-03 09:48:27', 'valid');

-- =====================================================================
-- Skrip 3 : Pengujian relasi (JOIN, agregasi, VIEW)
-- =====================================================================

-- Q1. Detail pemesanan (JOIN 5 tabel)
SELECT b.id AS booking, u.name AS pemesan, e.title AS event,
       tt.type_name AS tiket, b.quantity AS qty, b.total_price AS total,
       t.ticket_code AS kode_tiket
FROM bookings b
JOIN users u         ON u.id  = b.user_id
JOIN ticket_types tt ON tt.id = b.ticket_type_id
JOIN events e        ON e.id  = tt.event_id
JOIN tickets t       ON t.booking_id = b.id
ORDER BY b.id;

-- Q2. Total pendapatan per event (agregasi)
SELECT e.title AS event, COUNT(b.id) AS jml_booking,
       COALESCE(SUM(b.quantity),0) AS tiket_terjual, COALESCE(SUM(b.total_price),0) AS pendapatan
FROM events e
LEFT JOIN bookings b ON b.event_id = e.id AND b.payment_status = 'paid'
GROUP BY e.id, e.title
ORDER BY pendapatan DESC;

-- Q3. Sisa kuota tiap jenis tiket
SELECT e.title AS event, tt.type_name AS tiket, tt.quota,
       COALESCE(SUM(b.quantity),0) AS terjual,
       tt.quota - COALESCE(SUM(b.quantity),0) AS sisa
FROM ticket_types tt
JOIN events e ON e.id = tt.event_id
LEFT JOIN bookings b ON b.ticket_type_id = tt.id AND b.payment_status='paid'
GROUP BY tt.id, e.title, tt.type_name, tt.quota;

-- Q4. Peserta yang sudah membeli tiket tetapi belum check-in
SELECT u.name AS peserta, e.title AS event, t.ticket_code
FROM tickets t
JOIN bookings b ON b.id = t.booking_id
JOIN users u    ON u.id = b.user_id
JOIN events e   ON e.id = b.event_id
LEFT JOIN checkin_logs c ON c.ticket_id = t.id AND c.result = 'valid'
WHERE c.id IS NULL;

-- Q5. VIEW ringkasan transaksi lalu SELECT dari VIEW
CREATE OR REPLACE VIEW v_transaksi AS
SELECT b.id AS booking_id, u.name AS pemesan, e.title AS event,
       tt.type_name AS tiket, b.quantity, b.total_price,
       COALESCE(v.code,'-') AS voucher, p.reference_no, p.status AS status_bayar
FROM bookings b
JOIN users u         ON u.id  = b.user_id
JOIN ticket_types tt ON tt.id = b.ticket_type_id
JOIN events e        ON e.id  = tt.event_id
LEFT JOIN vouchers v ON v.id  = b.voucher_id
LEFT JOIN payments p ON p.booking_id = b.id;

SELECT * FROM v_transaksi;
