-- SecureBank v1.0 - SQL 101 ve Veritabani Guvenligi Atolyesi
-- Bu dosyadaki tum veriler egitim amacli ve tamamen sahtedir.

-- ============================================================
-- Schema
-- ============================================================

CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(120) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE accounts (
    id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(id),
    iban VARCHAR(34) UNIQUE NOT NULL,
    account_type VARCHAR(30) NOT NULL,
    balance NUMERIC(12,2) NOT NULL,
    currency VARCHAR(10) DEFAULT 'TRY',
    status VARCHAR(20) DEFAULT 'active'
);

CREATE TABLE transactions (
    id SERIAL PRIMARY KEY,
    from_account_id INT REFERENCES accounts(id),
    to_account_id INT REFERENCES accounts(id),
    amount NUMERIC(12,2) NOT NULL,
    description TEXT,
    status VARCHAR(20) DEFAULT 'completed',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE audit_logs (
    id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(id),
    action VARCHAR(100) NOT NULL,
    ip_address VARCHAR(45),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE support_requests (
    id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(id),
    subject VARCHAR(150) NOT NULL,
    status VARCHAR(30) DEFAULT 'open',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE security_flags (
    id SERIAL PRIMARY KEY,
    flag_name VARCHAR(80) NOT NULL,
    flag_value VARCHAR(120) NOT NULL,
    note TEXT
);

-- ============================================================
-- Indexes
-- ============================================================

CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_accounts_user_id ON accounts(user_id);
CREATE INDEX idx_transactions_from_account_id ON transactions(from_account_id);
CREATE INDEX idx_transactions_to_account_id ON transactions(to_account_id);
CREATE INDEX idx_audit_logs_user_id ON audit_logs(user_id);

-- ============================================================
-- Seed data: users
-- Password hash values are demo placeholders, not real credentials.
-- ============================================================

INSERT INTO users (id, username, full_name, email, password_hash, role, created_at) VALUES
    (1, 'ali.yilmaz', 'Ali Yilmaz', 'ali.yilmaz@securebank.test', 'demo_hash_ali_001', 'customer', '2026-01-10 09:15:00'),
    (2, 'ayse.demir', 'Ayse Demir', 'ayse.demir@securebank.test', 'demo_hash_ayse_002', 'customer', '2026-01-11 10:20:00'),
    (3, 'mehmet.kaya', 'Mehmet Kaya', 'mehmet.kaya@securebank.test', 'demo_hash_mehmet_003', 'customer', '2026-01-12 11:25:00'),
    (4, 'zeynep.celik', 'Zeynep Celik', 'zeynep.celik@securebank.test', 'demo_hash_zeynep_004', 'customer', '2026-01-13 12:30:00'),
    (5, 'emre.sahin', 'Emre Sahin', 'emre.sahin@securebank.test', 'demo_hash_emre_005', 'customer', '2026-01-14 13:35:00'),
    (6, 'elif.arslan', 'Elif Arslan', 'elif.arslan@securebank.test', 'demo_hash_elif_006', 'customer', '2026-01-15 14:40:00'),
    (7, 'deniz.staff', 'Deniz Acar', 'deniz.staff@securebank.test', 'demo_hash_deniz_007', 'staff', '2026-01-16 08:45:00'),
    (8, 'selin.admin', 'Selin Ozkan', 'selin.admin@securebank.test', 'demo_hash_selin_008', 'admin', '2026-01-17 08:50:00');

SELECT setval('users_id_seq', (SELECT MAX(id) FROM users));

-- ============================================================
-- Seed data: accounts
-- IBAN values are fake and reserved for this training database.
-- ============================================================

INSERT INTO accounts (id, user_id, iban, account_type, balance, currency, status) VALUES
    (1, 1, 'TR100000000000000000000001', 'checking', 12500.75, 'TRY', 'active'),
    (2, 1, 'TR100000000000000000000002', 'savings', 68250.00, 'TRY', 'active'),
    (3, 2, 'TR100000000000000000000003', 'checking', 8450.20, 'TRY', 'active'),
    (4, 2, 'TR100000000000000000000004', 'savings', 52400.50, 'TRY', 'active'),
    (5, 3, 'TR100000000000000000000005', 'checking', 30100.00, 'TRY', 'active'),
    (6, 4, 'TR100000000000000000000006', 'checking', 920.40, 'TRY', 'active'),
    (7, 4, 'TR100000000000000000000007', 'credit', -2450.00, 'TRY', 'active'),
    (8, 5, 'TR100000000000000000000008', 'checking', 74500.99, 'TRY', 'active'),
    (9, 6, 'TR100000000000000000000009', 'savings', 113200.00, 'TRY', 'active'),
    (10, 6, 'TR100000000000000000000010', 'checking', 15600.35, 'TRY', 'blocked');

SELECT setval('accounts_id_seq', (SELECT MAX(id) FROM accounts));

-- ============================================================
-- Seed data: transactions
-- ============================================================

INSERT INTO transactions (id, from_account_id, to_account_id, amount, description, status, created_at) VALUES
    (1, 1, 3, 1250.00, 'Kira odemesi demo', 'completed', '2026-02-01 09:05:00'),
    (2, 3, 5, 320.50, 'Market alisverisi demo', 'completed', '2026-02-01 10:15:00'),
    (3, 5, 1, 750.00, 'Fatura paylasimi demo', 'completed', '2026-02-02 11:25:00'),
    (4, 2, 4, 5000.00, 'Birikim aktarimi demo', 'completed', '2026-02-03 12:35:00'),
    (5, 8, 6, 875.25, 'Egitim odemesi demo', 'completed', '2026-02-04 13:45:00'),
    (6, 9, 2, 10000.00, 'Vadeli hesap aktarimi demo', 'completed', '2026-02-05 14:55:00'),
    (7, 6, 7, 250.00, 'Kart borcu demo', 'completed', '2026-02-06 15:05:00'),
    (8, 4, 8, 1420.75, 'Tatil rezervasyonu demo', 'completed', '2026-02-07 16:15:00'),
    (9, 1, 9, 2100.00, 'Aile transferi demo', 'completed', '2026-02-08 17:25:00'),
    (10, 10, 3, 650.00, 'Bloke hesap denemesi demo', 'failed', '2026-02-09 18:35:00'),
    (11, 3, 1, 430.00, 'Iade demo', 'completed', '2026-02-10 09:10:00'),
    (12, 5, 8, 2999.99, 'Elektronik odemesi demo', 'completed', '2026-02-11 10:20:00'),
    (13, 8, 2, 15000.00, 'Yatirim aktarimi demo', 'completed', '2026-02-12 11:30:00'),
    (14, 9, 4, 7800.40, 'Arac bakim odemesi demo', 'completed', '2026-02-13 12:40:00'),
    (15, 2, 6, 610.60, 'Aidat odemesi demo', 'completed', '2026-02-14 13:50:00'),
    (16, 4, 5, 120.00, 'Kafe odemesi demo', 'completed', '2026-02-15 14:00:00'),
    (17, 6, 1, 300.00, 'Arkadas transferi demo', 'pending', '2026-02-16 15:10:00'),
    (18, 7, 8, 980.00, 'Kart taksit demo', 'completed', '2026-02-17 16:20:00'),
    (19, 1, 5, 45.90, 'Ulasim odemesi demo', 'completed', '2026-02-18 17:30:00'),
    (20, 8, 9, 25000.00, 'Birikim transferi demo', 'completed', '2026-02-19 18:40:00');

SELECT setval('transactions_id_seq', (SELECT MAX(id) FROM transactions));

-- ============================================================
-- Seed data: audit logs
-- ============================================================

INSERT INTO audit_logs (id, user_id, action, ip_address, created_at) VALUES
    (1, 1, 'login_success', '192.168.10.21', '2026-02-20 09:01:00'),
    (2, 2, 'login_success', '192.168.10.22', '2026-02-20 09:04:00'),
    (3, 3, 'password_change_demo', '192.168.10.23', '2026-02-20 09:10:00'),
    (4, 4, 'viewed_accounts', '192.168.10.24', '2026-02-20 09:14:00'),
    (5, 5, 'transfer_created', '192.168.10.25', '2026-02-20 09:20:00'),
    (6, 6, 'login_failed_demo', '192.168.10.26', '2026-02-20 09:22:00'),
    (7, 7, 'staff_reviewed_support_request', '192.168.10.10', '2026-02-20 09:30:00'),
    (8, 8, 'admin_export_demo', '192.168.10.5', '2026-02-20 09:35:00'),
    (9, 1, 'profile_update_demo', '192.168.10.21', '2026-02-20 10:01:00'),
    (10, 2, 'logout', '192.168.10.22', '2026-02-20 10:08:00');

SELECT setval('audit_logs_id_seq', (SELECT MAX(id) FROM audit_logs));

-- ============================================================
-- Seed data: support requests
-- ============================================================

INSERT INTO support_requests (id, user_id, subject, status, created_at) VALUES
    (1, 1, 'Mobil uygulama giris sorunu demo', 'open', '2026-02-21 09:00:00'),
    (2, 2, 'Kart limit bilgisi demo', 'in_progress', '2026-02-21 09:30:00'),
    (3, 3, 'Hesap hareketleri sorusu demo', 'closed', '2026-02-21 10:00:00'),
    (4, 4, 'IBAN goruntuleme sorunu demo', 'open', '2026-02-21 10:30:00'),
    (5, 6, 'Bloke hesap bilgilendirme demo', 'open', '2026-02-21 11:00:00');

SELECT setval('support_requests_id_seq', (SELECT MAX(id) FROM support_requests));

-- ============================================================
-- Seed data: training flag
-- ============================================================

INSERT INTO security_flags (id, flag_name, flag_value, note) VALUES
    (1, 'training_flag_01', 'flag{protect_customer_data}', 'Workshop flag for data protection discussion.');

SELECT setval('security_flags_id_seq', (SELECT MAX(id) FROM security_flags));
