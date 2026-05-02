-- DB04 - Broken Access Control / Authorization Lab
-- This database is about authorization mistakes, not SQL Injection.
-- It contains no exploit payloads and is intended for safe SQL analysis practice.

\connect db04_access_control_lab

-- Public schema permissions are restricted before creating workshop objects.
REVOKE ALL ON SCHEMA public FROM PUBLIC;
GRANT USAGE ON SCHEMA public TO db04_user;

-- Application users represent customers, support staff, and an auditor.
CREATE TABLE public.app_users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(120) UNIQUE NOT NULL,
    role VARCHAR(30) NOT NULL,
    status VARCHAR(20) DEFAULT 'active',
    created_at DATE NOT NULL
);

-- Accounts are owned by app users. A correct application should check ownership
-- or explicit permission before showing an account.
CREATE TABLE public.accounts (
    id SERIAL PRIMARY KEY,
    owner_user_id INT NOT NULL REFERENCES public.app_users(id),
    iban VARCHAR(34) UNIQUE NOT NULL,
    account_type VARCHAR(30) NOT NULL,
    balance NUMERIC(12,2) NOT NULL,
    currency VARCHAR(10) DEFAULT 'TRY',
    status VARCHAR(20) DEFAULT 'active'
);

-- account_access is the permission table.
-- It represents who is allowed to view or manage which account.
CREATE TABLE public.account_access (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL REFERENCES public.app_users(id),
    account_id INT NOT NULL REFERENCES public.accounts(id),
    access_level VARCHAR(30) NOT NULL,
    granted_reason VARCHAR(120),
    created_at DATE NOT NULL
);

-- account_view_events stores account-view audit events.
-- Suspicious access can be found by comparing these events with permissions.
CREATE TABLE public.account_view_events (
    id SERIAL PRIMARY KEY,
    viewer_user_id INT NOT NULL REFERENCES public.app_users(id),
    viewed_account_id INT NOT NULL REFERENCES public.accounts(id),
    source VARCHAR(50) NOT NULL,
    ip_address VARCHAR(45),
    created_at TIMESTAMP NOT NULL
);

CREATE TABLE public.support_tickets (
    id SERIAL PRIMARY KEY,
    requester_user_id INT NOT NULL REFERENCES public.app_users(id),
    related_account_id INT REFERENCES public.accounts(id),
    subject VARCHAR(150) NOT NULL,
    status VARCHAR(30) DEFAULT 'open',
    created_at TIMESTAMP NOT NULL
);

CREATE TABLE public.security_notes (
    id SERIAL PRIMARY KEY,
    note_title VARCHAR(100) NOT NULL,
    note_body TEXT NOT NULL
);

CREATE INDEX idx_db04_app_users_username ON public.app_users(username);
CREATE INDEX idx_db04_app_users_role ON public.app_users(role);
CREATE INDEX idx_db04_accounts_owner_user_id ON public.accounts(owner_user_id);
CREATE INDEX idx_db04_account_access_user_id ON public.account_access(user_id);
CREATE INDEX idx_db04_account_access_account_id ON public.account_access(account_id);
CREATE INDEX idx_db04_account_view_events_viewer_user_id ON public.account_view_events(viewer_user_id);
CREATE INDEX idx_db04_account_view_events_viewed_account_id ON public.account_view_events(viewed_account_id);
CREATE INDEX idx_db04_account_view_events_created_at ON public.account_view_events(created_at);
CREATE INDEX idx_db04_support_tickets_requester_user_id ON public.support_tickets(requester_user_id);
CREATE INDEX idx_db04_support_tickets_related_account_id ON public.support_tickets(related_account_id);

-- Tum veriler sahte demo verisidir; gercek kisi veya banka verisi icermez.
INSERT INTO public.app_users (id, username, full_name, email, role, status, created_at) VALUES
    (1, 'ali.yilmaz', 'Ali Yilmaz', 'ali.yilmaz.db04@securebank.test', 'customer', 'active', '2025-09-01'),
    (2, 'ayse.demir', 'Ayse Demir', 'ayse.demir.db04@securebank.test', 'customer', 'active', '2025-09-03'),
    (3, 'mehmet.kaya', 'Mehmet Kaya', 'mehmet.kaya.db04@securebank.test', 'customer', 'active', '2025-09-05'),
    (4, 'zeynep.arslan', 'Zeynep Arslan', 'zeynep.arslan.db04@securebank.test', 'customer', 'active', '2025-09-07'),
    (5, 'can.ozkan', 'Can Ozkan', 'can.ozkan.db04@securebank.test', 'customer', 'active', '2025-09-09'),
    (6, 'elif.celik', 'Elif Celik', 'elif.celik.db04@securebank.test', 'customer', 'active', '2025-09-11'),
    (7, 'burak.aydin', 'Burak Aydin', 'burak.aydin.db04@securebank.test', 'customer', 'active', '2025-09-13'),
    (8, 'selin.koc', 'Selin Koc', 'selin.koc.db04@securebank.test', 'support_staff', 'active', '2025-09-15'),
    (9, 'deniz.sahin', 'Deniz Sahin', 'deniz.sahin.db04@securebank.test', 'support_staff', 'active', '2025-09-17'),
    (10, 'mert.kaplan', 'Mert Kaplan', 'mert.kaplan.db04@securebank.test', 'auditor', 'active', '2025-09-19');

SELECT setval('public.app_users_id_seq', (SELECT MAX(id) FROM public.app_users));

INSERT INTO public.accounts (id, owner_user_id, iban, account_type, balance, currency, status) VALUES
    (1, 1, 'TR400000000000000000000001', 'checking', 12500.00, 'TRY', 'active'),
    (2, 1, 'TR400000000000000000000002', 'savings', 78500.75, 'TRY', 'active'),
    (3, 2, 'TR400000000000000000000003', 'student', 3200.00, 'TRY', 'active'),
    (4, 3, 'TR400000000000000000000004', 'checking', 45200.50, 'TRY', 'active'),
    (5, 3, 'TR400000000000000000000005', 'business', 156000.00, 'TRY', 'active'),
    (6, 4, 'TR400000000000000000000006', 'checking', 18400.20, 'TRY', 'active'),
    (7, 5, 'TR400000000000000000000007', 'checking', 9800.00, 'TRY', 'active'),
    (8, 5, 'TR400000000000000000000008', 'savings', 66400.30, 'TRY', 'active'),
    (9, 6, 'TR400000000000000000000009', 'savings', 123500.00, 'TRY', 'active'),
    (10, 7, 'TR400000000000000000000010', 'checking', 22400.00, 'TRY', 'active'),
    (11, 7, 'TR400000000000000000000011', 'business', 210000.00, 'TRY', 'active'),
    (12, 2, 'TR400000000000000000000012', 'savings', 40500.90, 'TRY', 'active');

SELECT setval('public.accounts_id_seq', (SELECT MAX(id) FROM public.accounts));

-- Legitimate permissions. Owner rows are expected for every account.
-- Support staff and auditor access is intentionally limited, not global.
INSERT INTO public.account_access (id, user_id, account_id, access_level, granted_reason, created_at) VALUES
    (1, 1, 1, 'owner', 'Account owner', '2025-09-01'),
    (2, 1, 2, 'owner', 'Account owner', '2025-09-01'),
    (3, 2, 3, 'owner', 'Account owner', '2025-09-03'),
    (4, 2, 12, 'owner', 'Account owner', '2025-09-03'),
    (5, 3, 4, 'owner', 'Account owner', '2025-09-05'),
    (6, 3, 5, 'owner', 'Account owner', '2025-09-05'),
    (7, 4, 6, 'owner', 'Account owner', '2025-09-07'),
    (8, 5, 7, 'owner', 'Account owner', '2025-09-09'),
    (9, 5, 8, 'owner', 'Account owner', '2025-09-09'),
    (10, 6, 9, 'owner', 'Account owner', '2025-09-11'),
    (11, 7, 10, 'owner', 'Account owner', '2025-09-13'),
    (12, 7, 11, 'owner', 'Account owner', '2025-09-13'),
    (13, 8, 3, 'support_readonly', 'Open support ticket review', '2025-10-01'),
    (14, 8, 4, 'support_readonly', 'Open support ticket review', '2025-10-01'),
    (15, 8, 6, 'support_readonly', 'Open support ticket review', '2025-10-01'),
    (16, 9, 7, 'support_readonly', 'Fraud support review', '2025-10-02'),
    (17, 9, 8, 'support_readonly', 'Fraud support review', '2025-10-02'),
    (18, 9, 10, 'support_readonly', 'Fraud support review', '2025-10-02'),
    (19, 10, 2, 'auditor', 'Quarterly audit sample', '2025-10-03'),
    (20, 10, 5, 'auditor', 'Quarterly audit sample', '2025-10-03'),
    (21, 10, 11, 'auditor', 'Quarterly audit sample', '2025-10-03'),
    (22, 1, 3, 'viewer', 'Family account review permission', '2025-10-04'),
    (23, 4, 9, 'viewer', 'Shared savings review permission', '2025-10-04');

SELECT setval('public.account_access_id_seq', (SELECT MAX(id) FROM public.account_access));

-- Some events are legitimate and some are suspicious.
-- Suspicious events have no matching row in account_access for viewer/account.
INSERT INTO public.account_view_events (id, viewer_user_id, viewed_account_id, source, ip_address, created_at) VALUES
    (1, 1, 1, 'mobile_app', '192.168.20.11', '2025-10-10 09:00:00'),
    (2, 1, 2, 'web_panel', '192.168.20.11', '2025-10-10 09:05:00'),
    (3, 2, 3, 'mobile_app', '192.168.20.12', '2025-10-10 09:10:00'),
    (4, 2, 12, 'web_panel', '192.168.20.12', '2025-10-10 09:15:00'),
    (5, 3, 4, 'mobile_app', '192.168.20.13', '2025-10-10 09:20:00'),
    (6, 3, 5, 'web_panel', '192.168.20.13', '2025-10-10 09:25:00'),
    (7, 4, 6, 'mobile_app', '192.168.20.14', '2025-10-10 09:30:00'),
    (8, 5, 7, 'mobile_app', '192.168.20.15', '2025-10-10 09:35:00'),
    (9, 5, 8, 'web_panel', '192.168.20.15', '2025-10-10 09:40:00'),
    (10, 6, 9, 'mobile_app', '192.168.20.16', '2025-10-10 09:45:00'),
    (11, 7, 10, 'mobile_app', '192.168.20.17', '2025-10-10 09:50:00'),
    (12, 7, 11, 'web_panel', '192.168.20.17', '2025-10-10 09:55:00'),
    (13, 8, 3, 'support_panel', '192.168.20.30', '2025-10-10 10:00:00'),
    (14, 8, 4, 'support_panel', '192.168.20.30', '2025-10-10 10:05:00'),
    (15, 8, 6, 'support_panel', '192.168.20.30', '2025-10-10 10:10:00'),
    (16, 9, 7, 'support_panel', '192.168.20.31', '2025-10-10 10:15:00'),
    (17, 9, 8, 'support_panel', '192.168.20.31', '2025-10-10 10:20:00'),
    (18, 9, 10, 'support_panel', '192.168.20.31', '2025-10-10 10:25:00'),
    (19, 10, 2, 'audit_panel', '192.168.20.40', '2025-10-10 10:30:00'),
    (20, 10, 5, 'audit_panel', '192.168.20.40', '2025-10-10 10:35:00'),
    (21, 2, 1, 'web_panel', '192.168.20.12', '2025-10-10 10:40:00'),
    (22, 4, 2, 'mobile_app', '192.168.20.14', '2025-10-10 10:45:00'),
    (23, 5, 5, 'web_panel', '192.168.20.15', '2025-10-10 10:50:00'),
    (24, 8, 11, 'support_panel', '192.168.20.30', '2025-10-10 10:55:00'),
    (25, 9, 12, 'support_panel', '192.168.20.31', '2025-10-10 11:00:00'),
    (26, 3, 12, 'web_panel', '192.168.20.13', '2025-10-10 11:05:00'),
    (27, 1, 3, 'web_panel', '192.168.20.11', '2025-10-10 11:10:00'),
    (28, 4, 9, 'mobile_app', '192.168.20.14', '2025-10-10 11:15:00');

SELECT setval('public.account_view_events_id_seq', (SELECT MAX(id) FROM public.account_view_events));

INSERT INTO public.support_tickets (id, requester_user_id, related_account_id, subject, status, created_at) VALUES
    (1, 1, 1, 'Mobil uygulamada hesap goruntuleme sorusu', 'open', '2025-10-09 09:00:00'),
    (2, 2, 3, 'Kart ve hesap hareketleri sorusu', 'in_progress', '2025-10-09 09:30:00'),
    (3, 3, 5, 'Is hesabi yetki kontrolu talebi', 'open', '2025-10-09 10:00:00'),
    (4, 4, 6, 'Hesap bakiyesi goruntuleme sorunu', 'closed', '2025-10-09 10:30:00'),
    (5, 5, 8, 'Birikim hesabi erisim sorusu', 'open', '2025-10-09 11:00:00'),
    (6, 6, 9, 'Ortak hesap goruntuleme talebi', 'in_progress', '2025-10-09 11:30:00'),
    (7, 7, 10, 'Hesap hareketleri inceleme talebi', 'open', '2025-10-09 12:00:00'),
    (8, 2, 12, 'Vadeli hesap destek talebi', 'closed', '2025-10-09 12:30:00');

SELECT setval('public.support_tickets_id_seq', (SELECT MAX(id) FROM public.support_tickets));

INSERT INTO public.security_notes (id, note_title, note_body) VALUES
    (1, 'Authorization check', 'A correct query should check whether the viewer owns the account or has an explicit account_access row.'),
    (2, 'Least privilege', 'Support staff should receive access only to accounts needed for a specific support reason, not to every account.'),
    (3, 'Audit review', 'Unauthorized views can be detected by comparing account_view_events with account_access using LEFT JOIN or NOT EXISTS.');

SELECT setval('public.security_notes_id_seq', (SELECT MAX(id) FROM public.security_notes));

-- db04_user is intentionally read-only for this access-control lab.
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM PUBLIC;
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM db04_user;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO db04_user;

REVOKE ALL ON ALL SEQUENCES IN SCHEMA public FROM PUBLIC;
REVOKE ALL ON ALL SEQUENCES IN SCHEMA public FROM db04_user;

ALTER DEFAULT PRIVILEGES IN SCHEMA public REVOKE ALL ON TABLES FROM PUBLIC;
ALTER DEFAULT PRIVILEGES IN SCHEMA public REVOKE ALL ON SEQUENCES FROM PUBLIC;
