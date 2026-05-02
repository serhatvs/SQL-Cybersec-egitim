-- DB08 - Red vs Blue Final Challenge
-- This database is the final local lab for SQL 101 ve Veritabani Guvenligi Atolyesi.
-- Red Team should only operate inside this local lab.
-- Blue Team should focus on parameterized queries, least privilege, and audit analysis.
-- vulnerable_query_notes are pseudo-code notes, not real attack instructions.

\connect db08_red_vs_blue_final

REVOKE ALL ON SCHEMA public FROM PUBLIC;
GRANT USAGE ON SCHEMA public TO db08_red_user;
GRANT USAGE ON SCHEMA public TO db08_blue_user;

CREATE TABLE public.app_users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(120) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(30) NOT NULL,
    status VARCHAR(20) DEFAULT 'active',
    created_at DATE NOT NULL
);

CREATE TABLE public.accounts (
    id SERIAL PRIMARY KEY,
    owner_user_id INT NOT NULL REFERENCES public.app_users(id),
    iban VARCHAR(34) UNIQUE NOT NULL,
    account_type VARCHAR(30) NOT NULL,
    balance NUMERIC(12,2) NOT NULL,
    currency VARCHAR(10) DEFAULT 'TRY',
    status VARCHAR(20) DEFAULT 'active'
);

CREATE TABLE public.transactions (
    id SERIAL PRIMARY KEY,
    from_account_id INT REFERENCES public.accounts(id),
    to_account_id INT REFERENCES public.accounts(id),
    amount NUMERIC(12,2) NOT NULL,
    transaction_type VARCHAR(40) NOT NULL,
    description TEXT,
    status VARCHAR(20) DEFAULT 'completed',
    created_at TIMESTAMP NOT NULL
);

-- account_access represents which users are allowed to access which accounts.
-- It is used for Broken Access Control analysis in the final challenge.
CREATE TABLE public.account_access (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL REFERENCES public.app_users(id),
    account_id INT NOT NULL REFERENCES public.accounts(id),
    access_level VARCHAR(30) NOT NULL,
    granted_reason VARCHAR(120),
    created_at DATE NOT NULL
);

CREATE TABLE public.support_tickets (
    id SERIAL PRIMARY KEY,
    requester_user_id INT NOT NULL REFERENCES public.app_users(id),
    related_account_id INT REFERENCES public.accounts(id),
    subject VARCHAR(150) NOT NULL,
    message TEXT NOT NULL,
    status VARCHAR(30) DEFAULT 'open',
    created_at TIMESTAMP NOT NULL
);

CREATE TABLE public.vulnerable_query_notes (
    id SERIAL PRIMARY KEY,
    feature_area VARCHAR(80) NOT NULL,
    unsafe_pattern TEXT NOT NULL,
    why_vulnerable TEXT NOT NULL,
    safe_pattern TEXT NOT NULL,
    defense_note TEXT NOT NULL
);

CREATE TABLE public.input_attempt_logs (
    id SERIAL PRIMARY KEY,
    source_ip VARCHAR(45) NOT NULL,
    username_attempt VARCHAR(80),
    feature_area VARCHAR(80) NOT NULL,
    input_value TEXT NOT NULL,
    normalized_risk VARCHAR(30) NOT NULL,
    detected_reason VARCHAR(150),
    created_at TIMESTAMP NOT NULL
);

CREATE TABLE public.audit_logs (
    id SERIAL PRIMARY KEY,
    actor_user_id INT REFERENCES public.app_users(id),
    source_ip VARCHAR(45) NOT NULL,
    action_type VARCHAR(100) NOT NULL,
    object_name VARCHAR(120),
    row_count INT DEFAULT 0,
    risk_level VARCHAR(30) DEFAULT 'low',
    created_at TIMESTAMP NOT NULL
);

-- Restricted tables represent sensitive data that should not be broadly exposed.
CREATE TABLE public.admin_notes (
    id SERIAL PRIMARY KEY,
    note_title VARCHAR(120) NOT NULL,
    note_body TEXT NOT NULL,
    sensitivity VARCHAR(30) NOT NULL,
    created_at TIMESTAMP NOT NULL
);

CREATE TABLE public.security_flags (
    id SERIAL PRIMARY KEY,
    flag_name VARCHAR(80) NOT NULL,
    flag_value VARCHAR(120) NOT NULL,
    note TEXT
);

CREATE TABLE public.challenge_config (
    id SERIAL PRIMARY KEY,
    config_key VARCHAR(100) UNIQUE NOT NULL,
    config_value VARCHAR(200) NOT NULL,
    note TEXT
);

CREATE TABLE public.defense_findings (
    id SERIAL PRIMARY KEY,
    finding_title VARCHAR(120) NOT NULL,
    finding_body TEXT NOT NULL,
    severity VARCHAR(30) NOT NULL,
    suggested_fix TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_db08_app_users_username ON public.app_users(username);
CREATE INDEX idx_db08_app_users_role ON public.app_users(role);
CREATE INDEX idx_db08_accounts_owner_user_id ON public.accounts(owner_user_id);
CREATE INDEX idx_db08_transactions_from_account_id ON public.transactions(from_account_id);
CREATE INDEX idx_db08_transactions_to_account_id ON public.transactions(to_account_id);
CREATE INDEX idx_db08_transactions_created_at ON public.transactions(created_at);
CREATE INDEX idx_db08_account_access_user_id ON public.account_access(user_id);
CREATE INDEX idx_db08_account_access_account_id ON public.account_access(account_id);
CREATE INDEX idx_db08_support_tickets_requester_user_id ON public.support_tickets(requester_user_id);
CREATE INDEX idx_db08_support_tickets_related_account_id ON public.support_tickets(related_account_id);
CREATE INDEX idx_db08_input_attempt_logs_source_ip ON public.input_attempt_logs(source_ip);
CREATE INDEX idx_db08_input_attempt_logs_feature_area ON public.input_attempt_logs(feature_area);
CREATE INDEX idx_db08_input_attempt_logs_normalized_risk ON public.input_attempt_logs(normalized_risk);
CREATE INDEX idx_db08_input_attempt_logs_created_at ON public.input_attempt_logs(created_at);
CREATE INDEX idx_db08_audit_logs_actor_user_id ON public.audit_logs(actor_user_id);
CREATE INDEX idx_db08_audit_logs_source_ip ON public.audit_logs(source_ip);
CREATE INDEX idx_db08_audit_logs_risk_level ON public.audit_logs(risk_level);
CREATE INDEX idx_db08_audit_logs_created_at ON public.audit_logs(created_at);
CREATE INDEX idx_db08_admin_notes_sensitivity ON public.admin_notes(sensitivity);
CREATE INDEX idx_db08_defense_findings_severity ON public.defense_findings(severity);

-- Tum veriler sahte demo verisidir; gercek kisi, banka veya musteri verisi icermez.
INSERT INTO public.app_users (id, username, full_name, email, password_hash, role, status, created_at) VALUES
    (1, 'ali.yilmaz', 'Ali Yilmaz', 'ali.yilmaz.db08@securebank.test', 'fake_hash_ali_001', 'customer', 'active', '2025-09-01'),
    (2, 'ayse.demir', 'Ayse Demir', 'ayse.demir.db08@securebank.test', 'fake_hash_ayse_002', 'customer', 'active', '2025-09-02'),
    (3, 'mehmet.kaya', 'Mehmet Kaya', 'mehmet.kaya.db08@securebank.test', 'fake_hash_mehmet_003', 'customer', 'active', '2025-09-03'),
    (4, 'zeynep.arslan', 'Zeynep Arslan', 'zeynep.arslan.db08@securebank.test', 'fake_hash_zeynep_004', 'customer', 'active', '2025-09-04'),
    (5, 'can.ozkan', 'Can Ozkan', 'can.ozkan.db08@securebank.test', 'fake_hash_can_005', 'customer', 'active', '2025-09-05'),
    (6, 'elif.celik', 'Elif Celik', 'elif.celik.db08@securebank.test', 'fake_hash_elif_006', 'customer', 'active', '2025-09-06'),
    (7, 'burak.aydin', 'Burak Aydin', 'burak.aydin.db08@securebank.test', 'fake_hash_burak_007', 'customer', 'active', '2025-09-07'),
    (8, 'selin.koc', 'Selin Koc', 'selin.koc.db08@securebank.test', 'fake_hash_selin_008', 'customer', 'active', '2025-09-08'),
    (9, 'deniz.sahin', 'Deniz Sahin', 'deniz.sahin.db08@securebank.test', 'fake_hash_deniz_009', 'support_staff', 'active', '2025-09-09'),
    (10, 'mert.kaplan', 'Mert Kaplan', 'mert.kaplan.db08@securebank.test', 'fake_hash_mert_010', 'support_staff', 'active', '2025-09-10'),
    (11, 'ece.yildiz', 'Ece Yildiz', 'ece.yildiz.db08@securebank.test', 'fake_hash_ece_011', 'auditor', 'active', '2025-09-11'),
    (12, 'murat.aslan', 'Murat Aslan', 'murat.aslan.db08@securebank.test', 'fake_hash_murat_012', 'admin', 'active', '2025-09-12');

SELECT setval('public.app_users_id_seq', (SELECT MAX(id) FROM public.app_users));

INSERT INTO public.accounts (id, owner_user_id, iban, account_type, balance, currency, status) VALUES
    (1, 1, 'TR800000000000000000000001', 'checking', 12500.00, 'TRY', 'active'),
    (2, 1, 'TR800000000000000000000002', 'savings', 78500.75, 'TRY', 'active'),
    (3, 2, 'TR800000000000000000000003', 'checking', 9200.00, 'TRY', 'active'),
    (4, 2, 'TR800000000000000000000004', 'student', 2100.00, 'TRY', 'active'),
    (5, 3, 'TR800000000000000000000005', 'business', 156000.00, 'TRY', 'active'),
    (6, 3, 'TR800000000000000000000006', 'checking', 45200.50, 'TRY', 'active'),
    (7, 4, 'TR800000000000000000000007', 'savings', 63000.00, 'TRY', 'active'),
    (8, 5, 'TR800000000000000000000008', 'checking', 18400.20, 'TRY', 'active'),
    (9, 5, 'TR800000000000000000000009', 'business', 210000.00, 'TRY', 'active'),
    (10, 6, 'TR800000000000000000000010', 'savings', 123500.00, 'TRY', 'active'),
    (11, 7, 'TR800000000000000000000011', 'checking', 22400.00, 'TRY', 'active'),
    (12, 7, 'TR800000000000000000000012', 'business', 310000.00, 'TRY', 'active'),
    (13, 8, 'TR800000000000000000000013', 'checking', 17500.00, 'TRY', 'active'),
    (14, 8, 'TR800000000000000000000014', 'savings', 92500.00, 'TRY', 'blocked');

SELECT setval('public.accounts_id_seq', (SELECT MAX(id) FROM public.accounts));

INSERT INTO public.transactions (id, from_account_id, to_account_id, amount, transaction_type, description, status, created_at) VALUES
    (1, 1, 3, 750.00, 'transfer', 'Demo bireysel transfer', 'completed', '2025-11-01 09:00:00'),
    (2, 5, 1, 28500.00, 'salary', 'Demo maas aktarimi', 'completed', '2025-11-01 09:10:00'),
    (3, 3, 6, 1200.00, 'bill_payment', 'Demo fatura odemesi', 'completed', '2025-11-01 09:20:00'),
    (4, 2, 7, 12500.00, 'transfer', 'Demo birikim aktarimi', 'completed', '2025-11-01 09:30:00'),
    (5, 12, 10, 75000.00, 'transfer', 'Demo is odemesi', 'completed', '2025-11-01 09:40:00'),
    (6, 8, 4, 3250.00, 'card_payment', 'Demo kart odemesi', 'completed', '2025-11-01 09:50:00'),
    (7, 4, 13, 95.00, 'card_payment', 'Demo kucuk harcama', 'completed', '2025-11-01 10:00:00'),
    (8, 12, 5, 42000.00, 'loan_payment', 'Demo kredi odemesi', 'pending', '2025-11-01 10:10:00'),
    (9, 5, 12, 120000.00, 'transfer', 'Demo yuksek tutar', 'completed', '2025-11-01 10:20:00'),
    (10, 14, 6, 9900.00, 'transfer', 'Demo bloke hesap denemesi', 'failed', '2025-11-01 10:30:00'),
    (11, 6, 9, 18500.00, 'transfer', 'Demo sirket transferi', 'completed', '2025-11-01 10:40:00'),
    (12, 10, 1, 2700.00, 'bill_payment', 'Demo abonelik odemesi', 'completed', '2025-11-01 10:50:00'),
    (13, 4, 11, 650.00, 'card_payment', 'Demo ogrenci odemesi', 'completed', '2025-11-01 11:00:00'),
    (14, 8, 6, 1800.00, 'transfer', 'Demo bireysel odeme', 'completed', '2025-11-01 11:10:00'),
    (15, 10, 2, 64000.00, 'transfer', 'Demo vadeli aktarim', 'completed', '2025-11-01 11:20:00'),
    (16, 1, 13, 5000.00, 'transfer', 'Demo aile aktarimi', 'completed', '2025-11-01 11:30:00'),
    (17, 11, 3, 4100.00, 'transfer', 'Demo bekleyen islem', 'pending', '2025-11-01 11:40:00'),
    (18, 7, 2, 22000.00, 'transfer', 'Demo tasarruf aktarimi', 'completed', '2025-11-01 11:50:00'),
    (19, 9, 10, 7000.00, 'transfer', 'Demo hesap aktarimi', 'completed', '2025-11-01 12:00:00'),
    (20, 12, 5, 98000.00, 'loan_payment', 'Demo kredi kapama', 'completed', '2025-11-01 12:10:00'),
    (21, 13, 8, 2400.00, 'atm_withdrawal', 'Demo ATM islemi', 'completed', '2025-11-01 12:20:00'),
    (22, 6, 14, 1300.00, 'card_payment', 'Demo basarisiz kart islemi', 'failed', '2025-11-01 12:30:00'),
    (23, 5, 6, 33250.00, 'transfer', 'Demo cari aktarim', 'completed', '2025-11-01 12:40:00'),
    (24, 12, 1, 17500.00, 'salary', 'Demo ek odeme', 'completed', '2025-11-01 12:50:00'),
    (25, 2, 4, 880.00, 'transfer', 'Demo destek aktarimi', 'completed', '2025-11-01 13:00:00'),
    (26, 6, 7, 9900.00, 'transfer', 'Demo tasarruf transferi', 'completed', '2025-11-01 13:10:00'),
    (27, 10, 5, 55000.00, 'transfer', 'Demo yuksek bakiye aktarimi', 'completed', '2025-11-01 13:20:00'),
    (28, 8, 11, 640.00, 'card_payment', 'Demo kart odemesi', 'completed', '2025-11-01 13:30:00'),
    (29, 5, 2, 21200.00, 'transfer', 'Demo yatirim aktarimi', 'completed', '2025-11-01 13:40:00'),
    (30, 12, 9, 45500.00, 'transfer', 'Demo firma odemesi', 'completed', '2025-11-01 13:50:00'),
    (31, 1, 8, 1250.00, 'bill_payment', 'Demo bekleyen fatura', 'pending', '2025-11-01 14:00:00'),
    (32, 10, 3, 5050.00, 'transfer', 'Demo rutin transfer', 'completed', '2025-11-01 14:10:00'),
    (33, 4, 14, 600.00, 'card_payment', 'Demo basarisiz kart', 'failed', '2025-11-01 14:20:00'),
    (34, 12, 5, 112000.00, 'transfer', 'Demo kurumsal odeme', 'completed', '2025-11-01 14:30:00'),
    (35, 13, 9, 3750.00, 'transfer', 'Demo bireysel odeme', 'completed', '2025-11-01 14:40:00');

SELECT setval('public.transactions_id_seq', (SELECT MAX(id) FROM public.transactions));

INSERT INTO public.account_access (id, user_id, account_id, access_level, granted_reason, created_at) VALUES
    (1, 1, 1, 'owner', 'Account owner', '2025-09-01'),
    (2, 1, 2, 'owner', 'Account owner', '2025-09-01'),
    (3, 2, 3, 'owner', 'Account owner', '2025-09-02'),
    (4, 2, 4, 'owner', 'Account owner', '2025-09-02'),
    (5, 3, 5, 'owner', 'Account owner', '2025-09-03'),
    (6, 3, 6, 'owner', 'Account owner', '2025-09-03'),
    (7, 4, 7, 'owner', 'Account owner', '2025-09-04'),
    (8, 5, 8, 'owner', 'Account owner', '2025-09-05'),
    (9, 5, 9, 'owner', 'Account owner', '2025-09-05'),
    (10, 6, 10, 'owner', 'Account owner', '2025-09-06'),
    (11, 7, 11, 'owner', 'Account owner', '2025-09-07'),
    (12, 7, 12, 'owner', 'Account owner', '2025-09-07'),
    (13, 8, 13, 'owner', 'Account owner', '2025-09-08'),
    (14, 8, 14, 'owner', 'Account owner', '2025-09-08'),
    (15, 9, 3, 'support_readonly', 'Support ticket review', '2025-10-01'),
    (16, 9, 6, 'support_readonly', 'Support ticket review', '2025-10-01'),
    (17, 10, 8, 'support_readonly', 'Support ticket review', '2025-10-02'),
    (18, 10, 11, 'support_readonly', 'Support ticket review', '2025-10-02'),
    (19, 11, 2, 'auditor', 'Audit sample', '2025-10-03'),
    (20, 11, 5, 'auditor', 'Audit sample', '2025-10-03'),
    (21, 11, 12, 'auditor', 'Audit sample', '2025-10-03');

SELECT setval('public.account_access_id_seq', (SELECT MAX(id) FROM public.account_access));

INSERT INTO public.support_tickets (id, requester_user_id, related_account_id, subject, message, status, created_at) VALUES
    (1, 1, 1, 'Mobil uygulama hesap goruntuleme', 'Kayseri subesindeki hesabimi mobilde goremiyorum.', 'open', '2025-11-02 09:00:00'),
    (2, 2, 3, 'Kart hareketleri sorusu', 'Son kart odememi kontrol etmek istiyorum.', 'in_progress', '2025-11-02 09:20:00'),
    (3, 3, 5, 'Is hesabi destek talebi', 'Business hesabim icin hesap ozeti lazim.', 'open', '2025-11-02 09:40:00'),
    (4, 4, 7, 'Vadeli hesap sorusu', 'Tasarruf hesabim icin faiz bilgisini gormek istiyorum.', 'closed', '2025-11-02 10:00:00'),
    (5, 5, 8, 'IBAN goruntuleme sorunu', 'Ankara ofisinden baglaninca IBAN gorunmuyor.', 'open', '2025-11-02 10:20:00'),
    (6, 6, 10, 'Birikim hesabi erisim', 'Sadece kendi hesaplarimi gormem gerekiyor.', 'in_progress', '2025-11-02 10:40:00'),
    (7, 7, 11, 'Hesap hareketleri talebi', 'Son islemlerimi listelemek istiyorum.', 'open', '2025-11-02 11:00:00'),
    (8, 8, 14, 'Bloke hesap bilgilendirme', 'Bloke hesap durumunu ogrenmek istiyorum.', 'closed', '2025-11-02 11:20:00'),
    (9, 3, 6, 'Yetki kontrolu sorusu', 'Destek ekibi hangi hesabimi gorebilir?', 'open', '2025-11-02 11:40:00'),
    (10, 5, 9, 'Kurumsal odeme sorusu', 'Business hesabimdan yapilan odemeleri kontrol etmek istiyorum.', 'open', '2025-11-02 12:00:00');

SELECT setval('public.support_tickets_id_seq', (SELECT MAX(id) FROM public.support_tickets));

INSERT INTO public.vulnerable_query_notes (id, feature_area, unsafe_pattern, why_vulnerable, safe_pattern, defense_note) VALUES
    (1, 'customer_search', 'PSEUDO-CODE: SELECT * FROM app_users WHERE full_name LIKE ''%'' + user_input + ''%''', 'User input is appended into SQL text instead of being treated as data.', 'Use a prepared statement with a bound search pattern value.', 'Parameterize input, validate length, and return only necessary columns.'),
    (2, 'account_lookup', 'PSEUDO-CODE: SELECT * FROM accounts WHERE id = account_id_input', 'Looking up only by account id can expose accounts without checking the current user permission.', 'Use WHERE accounts.id = $1 and require a matching account_access row for the current user.', 'Combine parameterization with authorization checks and least privilege.'),
    (3, 'support_ticket_search', 'PSEUDO-CODE: SELECT * FROM support_tickets WHERE message LIKE ''%'' + ticket_input + ''%''', 'Free-text ticket search can over-fetch sensitive support messages if not scoped.', 'Use prepared statements and scope results to the requester or assigned support role.', 'Limit columns and enforce role-based filtering.'),
    (4, 'admin_note_filter', 'PSEUDO-CODE: SELECT * FROM admin_notes WHERE sensitivity = '' + filter_input + ''', 'Admin-only data should not be reachable through user-controlled filters.', 'Use prepared statements and restrict admin_notes to authorized roles only.', 'Keep restricted tables out of broad read-only roles and monitor audit logs.');

SELECT setval('public.vulnerable_query_notes_id_seq', (SELECT MAX(id) FROM public.vulnerable_query_notes));

INSERT INTO public.input_attempt_logs (id, source_ip, username_attempt, feature_area, input_value, normalized_risk, detected_reason, created_at) VALUES
    (1, '203.0.113.10', 'ali.yilmaz', 'login', 'ali.yilmaz', 'normal', 'expected username format', '2025-11-03 09:00:00'),
    (2, '203.0.113.11', 'ayse.demir', 'login', 'ayse.demir', 'normal', 'expected username format', '2025-11-03 09:03:00'),
    (3, '203.0.113.12', 'mehmet.kaya', 'customer_search', 'Mehmet', 'normal', 'short text search', '2025-11-03 09:06:00'),
    (4, '203.0.113.13', 'zeynep.arslan', 'account_lookup', '7', 'normal', 'numeric lookup value', '2025-11-03 09:09:00'),
    (5, '203.0.113.14', 'can.ozkan', 'support_ticket_search', 'IBAN', 'normal', 'expected ticket keyword', '2025-11-03 09:12:00'),
    (6, '203.0.113.15', 'elif.celik', 'customer_search', 'Kayseri', 'normal', 'known city-like text', '2025-11-03 09:15:00'),
    (7, '203.0.113.16', 'burak.aydin', 'account_lookup', '11', 'normal', 'numeric lookup value', '2025-11-03 09:18:00'),
    (8, '203.0.113.17', 'selin.koc', 'support_ticket_search', 'Bloke', 'normal', 'expected ticket keyword', '2025-11-03 09:21:00'),
    (9, '203.0.113.10', 'ali.yilmaz', 'customer_search', 'Ali', 'normal', 'short text search', '2025-11-03 09:24:00'),
    (10, '203.0.113.11', 'ayse.demir', 'account_lookup', '3', 'normal', 'numeric lookup value', '2025-11-03 09:27:00'),
    (11, '203.0.113.12', 'mehmet.kaya', 'support_ticket_search', 'business', 'normal', 'expected ticket keyword', '2025-11-03 09:30:00'),
    (12, '203.0.113.13', 'zeynep.arslan', 'customer_search', 'Zeynep', 'normal', 'short text search', '2025-11-03 09:33:00'),
    (13, '203.0.113.14', 'can.ozkan', 'account_lookup', '8', 'normal', 'numeric lookup value', '2025-11-03 09:36:00'),
    (14, '203.0.113.15', 'elif.celik', 'support_ticket_search', 'hesap', 'normal', 'expected ticket keyword', '2025-11-03 09:39:00'),
    (15, '203.0.113.16', 'burak.aydin', 'customer_search', 'Bursa', 'normal', 'known city-like text', '2025-11-03 09:42:00'),
    (16, '203.0.113.17', 'selin.koc', 'account_lookup', '14', 'normal', 'numeric lookup value', '2025-11-03 09:45:00'),
    (17, '203.0.113.18', 'deniz.sahin', 'support_ticket_search', 'open', 'normal', 'known status value', '2025-11-03 09:48:00'),
    (18, '203.0.113.19', 'mert.kaplan', 'customer_search', 'support', 'normal', 'expected role text', '2025-11-03 09:51:00'),
    (19, '203.0.113.20', 'ece.yildiz', 'account_lookup', '5', 'normal', 'numeric lookup value', '2025-11-03 09:54:00'),
    (20, '203.0.113.21', 'murat.aslan', 'admin_note_filter', 'internal', 'normal', 'known sensitivity value', '2025-11-03 09:57:00'),
    (21, '185.220.101.45', 'ali.yilmaz', 'customer_search', 'Ali''', 'suspicious', 'contains quote character', '2025-11-03 10:00:00'),
    (22, '185.220.101.45', 'ali.yilmaz', 'account_lookup', '1 OR 2', 'suspicious', 'contains boolean-like fragment', '2025-11-03 10:03:00'),
    (23, '185.220.101.45', 'ali.yilmaz', 'support_ticket_search', 'ticket -- note', 'suspicious', 'contains comment marker', '2025-11-03 10:06:00'),
    (24, '198.51.100.45', 'ayse.demir', 'customer_search', 'name OR role', 'suspicious', 'unexpected keyword-like pattern', '2025-11-03 10:09:00'),
    (25, '198.51.100.46', 'mehmet.kaya', 'admin_note_filter', 'admin''', 'suspicious', 'contains quote character', '2025-11-03 10:12:00'),
    (26, '198.51.100.47', 'zeynep.arslan', 'account_lookup', '000000000000000000000000000000000000000000000000', 'suspicious', 'unusual input length', '2025-11-03 10:15:00'),
    (27, '198.51.100.48', 'can.ozkan', 'support_ticket_search', 'open OR closed', 'suspicious', 'contains boolean-like fragment', '2025-11-03 10:18:00'),
    (28, '198.51.100.49', 'elif.celik', 'customer_search', 'Elif -- check', 'suspicious', 'contains comment marker', '2025-11-03 10:21:00'),
    (29, '185.220.101.45', 'ali.yilmaz', 'admin_note_filter', ''' internal marker', 'high', 'contains quote character and restricted feature access', '2025-11-03 10:24:00'),
    (30, '185.220.101.45', 'ali.yilmaz', 'account_lookup', '14 OR 1', 'high', 'contains boolean-like fragment against account lookup', '2025-11-03 10:27:00'),
    (31, '185.220.101.45', 'ali.yilmaz', 'challenge_result_lookup', 'flag -- marker', 'high', 'contains comment marker near challenge result lookup', '2025-11-03 10:30:00'),
    (32, '192.0.2.88', 'selin.koc', 'admin_note_filter', 'sensitive OR internal', 'high', 'unexpected keyword-like pattern on restricted feature', '2025-11-03 10:33:00'),
    (33, '192.0.2.89', 'burak.aydin', 'customer_search', ''' boolean marker', 'high', 'contains quote character and boolean-like fragment', '2025-11-03 10:36:00'),
    (34, '203.0.113.22', 'deniz.sahin', 'support_ticket_search', 'yetki kontrolu', 'normal', 'expected support search text', '2025-11-03 10:39:00'),
    (35, '203.0.113.23', 'mert.kaplan', 'customer_search', 'Mert', 'normal', 'short text search', '2025-11-03 10:42:00'),
    (36, '185.220.101.45', 'ali.yilmaz', 'customer_search', 'final challenge marker', 'high', 'repeated suspicious source IP', '2025-11-03 10:45:00');

SELECT setval('public.input_attempt_logs_id_seq', (SELECT MAX(id) FROM public.input_attempt_logs));

INSERT INTO public.audit_logs (id, actor_user_id, source_ip, action_type, object_name, row_count, risk_level, created_at) VALUES
    (1, 1, '203.0.113.10', 'login_success', 'app_session', 1, 'low', '2025-11-03 09:00:30'),
    (2, 1, '203.0.113.10', 'view_account', 'TR800000000000000000000001', 1, 'low', '2025-11-03 09:01:00'),
    (3, 2, '203.0.113.11', 'login_success', 'app_session', 1, 'low', '2025-11-03 09:03:30'),
    (4, 2, '203.0.113.11', 'view_account', 'TR800000000000000000000003', 1, 'low', '2025-11-03 09:04:00'),
    (5, 3, '203.0.113.12', 'login_success', 'app_session', 1, 'low', '2025-11-03 09:06:30'),
    (6, 3, '203.0.113.12', 'view_account', 'TR800000000000000000000005', 1, 'low', '2025-11-03 09:07:00'),
    (7, 4, '203.0.113.13', 'view_account', 'TR800000000000000000000007', 1, 'low', '2025-11-03 09:10:00'),
    (8, 5, '203.0.113.14', 'view_account', 'TR800000000000000000000008', 1, 'low', '2025-11-03 09:13:00'),
    (9, 6, '203.0.113.15', 'view_account', 'TR800000000000000000000010', 1, 'low', '2025-11-03 09:16:00'),
    (10, 7, '203.0.113.16', 'view_account', 'TR800000000000000000000011', 1, 'low', '2025-11-03 09:19:00'),
    (11, 8, '203.0.113.17', 'view_account', 'TR800000000000000000000014', 1, 'low', '2025-11-03 09:22:00'),
    (12, 9, '203.0.113.18', 'support_view_ticket', 'support_tickets', 3, 'medium', '2025-11-03 09:49:00'),
    (13, 9, '203.0.113.18', 'view_account', 'TR800000000000000000000003', 1, 'low', '2025-11-03 09:50:00'),
    (14, 10, '203.0.113.23', 'support_view_ticket', 'support_tickets', 2, 'medium', '2025-11-03 10:43:00'),
    (15, 10, '203.0.113.23', 'view_account', 'TR800000000000000000000008', 1, 'low', '2025-11-03 10:44:00'),
    (16, 11, '203.0.113.20', 'audit_review', 'audit_logs', 30, 'medium', '2025-11-03 09:55:00'),
    (17, 11, '203.0.113.20', 'view_account', 'TR800000000000000000000005', 1, 'low', '2025-11-03 09:56:00'),
    (18, 12, '203.0.113.21', 'admin_review', 'challenge_config', 3, 'medium', '2025-11-03 09:58:00'),
    (19, 1, '185.220.101.45', 'login_success', 'app_session', 1, 'high', '2025-11-03 10:01:00'),
    (20, 1, '185.220.101.45', 'customer_search', 'app_users', 12, 'high', '2025-11-03 10:02:00'),
    (21, 1, '185.220.101.45', 'view_account', 'TR800000000000000000000014', 1, 'high', '2025-11-03 10:28:00'),
    (22, 1, '185.220.101.45', 'challenge_result_view', 'exposed_challenge_results', 1, 'high', '2025-11-03 10:31:00'),
    (23, 1, '185.220.101.45', 'view_restricted_attempt', 'admin_notes', 0, 'high', '2025-11-03 10:32:00'),
    (24, 2, '198.51.100.45', 'customer_search', 'app_users', 12, 'medium', '2025-11-03 10:10:00'),
    (25, 3, '198.51.100.46', 'restricted_filter_attempt', 'admin_notes', 0, 'high', '2025-11-03 10:13:00'),
    (26, 4, '198.51.100.47', 'account_lookup', 'accounts', 0, 'medium', '2025-11-03 10:16:00'),
    (27, 5, '198.51.100.48', 'support_ticket_search', 'support_tickets', 10, 'medium', '2025-11-03 10:19:00'),
    (28, 6, '198.51.100.49', 'customer_search', 'app_users', 8, 'medium', '2025-11-03 10:22:00'),
    (29, 7, '192.0.2.89', 'customer_search', 'app_users', 12, 'high', '2025-11-03 10:37:00'),
    (30, 9, '185.220.101.45', 'support_view_ticket', 'support_tickets', 10, 'high', '2025-11-03 10:46:00'),
    (31, 9, '185.220.101.45', 'view_account', 'TR800000000000000000000012', 1, 'high', '2025-11-03 10:47:00'),
    (32, 11, '203.0.113.20', 'audit_review', 'input_attempt_logs', 36, 'medium', '2025-11-03 10:50:00');

SELECT setval('public.audit_logs_id_seq', (SELECT MAX(id) FROM public.audit_logs));

INSERT INTO public.admin_notes (id, note_title, note_body, sensitivity, created_at) VALUES
    (1, 'Final challenge scope', 'This final lab is local-only and should not be used as a real-world testing guide.', 'internal', '2025-11-03 08:00:00'),
    (2, 'Restricted data handling', 'Admin notes and security flags represent restricted data in the simplified SQL-panel scenario.', 'restricted', '2025-11-03 08:05:00'),
    (3, 'Defense expectation', 'Blue Team should recommend parameterized queries, authorization checks, least privilege, and monitoring.', 'internal', '2025-11-03 08:10:00'),
    (4, 'Audit focus', 'The IP 185.220.101.45 appears in both input attempts and audit logs for timeline reconstruction.', 'restricted', '2025-11-03 08:15:00'),
    (5, 'Organizer note', 'The challenge flag is exposed through a view for the red user, while the base table remains restricted.', 'restricted', '2025-11-03 08:20:00');

SELECT setval('public.admin_notes_id_seq', (SELECT MAX(id) FROM public.admin_notes));

INSERT INTO public.security_flags (id, flag_name, flag_value, note) VALUES
    (1, 'final_challenge_flag', 'flag{securebank_red_vs_blue_final}', 'Final local lab flag. Blue Team should explain how access should be prevented.');

SELECT setval('public.security_flags_id_seq', (SELECT MAX(id) FROM public.security_flags));

CREATE VIEW public.exposed_challenge_results AS
SELECT flag_name, flag_value
FROM public.security_flags
WHERE flag_name = 'final_challenge_flag';

INSERT INTO public.challenge_config (id, config_key, config_value, note) VALUES
    (1, 'vulnerable_feature', 'account_lookup', 'Simplified final lab focus area for analysis.'),
    (2, 'defense_status', 'unreviewed', 'Blue Team may update this to patched_proposed after analysis.'),
    (3, 'patch_strategy', 'pending', 'Blue Team should propose parameterization, allow-listing, least privilege, and monitoring.');

SELECT setval('public.challenge_config_id_seq', (SELECT MAX(id) FROM public.challenge_config));

INSERT INTO public.defense_findings (id, finding_title, finding_body, severity, suggested_fix, created_at) VALUES
    (1, 'Account lookup needs authorization', 'Looking up accounts by id alone does not prove the actor can view that account.', 'high', 'Require account_access match for the current user before returning account data.', '2025-11-03 08:30:00'),
    (2, 'Suspicious input monitoring needed', 'Input attempts with quote characters, comments, and boolean-like fragments should be reviewed.', 'medium', 'Log normalized risk and alert on repeated high-risk input from the same IP.', '2025-11-03 08:35:00'),
    (3, 'Restricted tables need least privilege', 'Admin notes and security flags should not be broadly queryable by challenge-facing roles.', 'high', 'Grant only required tables or views and keep restricted base tables limited to trusted roles.', '2025-11-03 08:40:00');

SELECT setval('public.defense_findings_id_seq', (SELECT MAX(id) FROM public.defense_findings));

REVOKE ALL ON ALL TABLES IN SCHEMA public FROM PUBLIC;
REVOKE ALL ON ALL SEQUENCES IN SCHEMA public FROM PUBLIC;

REVOKE ALL ON ALL TABLES IN SCHEMA public FROM db08_red_user;
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM db08_blue_user;
REVOKE ALL ON ALL SEQUENCES IN SCHEMA public FROM db08_red_user;
REVOKE ALL ON ALL SEQUENCES IN SCHEMA public FROM db08_blue_user;

GRANT SELECT ON public.app_users TO db08_red_user;
GRANT SELECT ON public.accounts TO db08_red_user;
GRANT SELECT ON public.transactions TO db08_red_user;
GRANT SELECT ON public.account_access TO db08_red_user;
GRANT SELECT ON public.support_tickets TO db08_red_user;
GRANT SELECT ON public.vulnerable_query_notes TO db08_red_user;
GRANT SELECT ON public.input_attempt_logs TO db08_red_user;
GRANT SELECT ON public.audit_logs TO db08_red_user;
GRANT SELECT ON public.exposed_challenge_results TO db08_red_user;

GRANT SELECT ON ALL TABLES IN SCHEMA public TO db08_blue_user;
GRANT INSERT ON public.defense_findings TO db08_blue_user;
GRANT UPDATE ON public.challenge_config TO db08_blue_user;
GRANT USAGE, SELECT ON SEQUENCE public.defense_findings_id_seq TO db08_blue_user;

ALTER DEFAULT PRIVILEGES IN SCHEMA public REVOKE ALL ON TABLES FROM PUBLIC;
ALTER DEFAULT PRIVILEGES IN SCHEMA public REVOKE ALL ON SEQUENCES FROM PUBLIC;
