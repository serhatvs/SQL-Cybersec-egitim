-- DB03 - Banking Queries and Analytics
-- This database is for safe banking analytics SQL practice only.
-- It is not for SQL Injection, Red Team, or Blue Team scenarios.

\connect db03_banking_queries

-- Public schema permissions are restricted before creating workshop objects.
REVOKE ALL ON SCHEMA public FROM PUBLIC;
GRANT USAGE ON SCHEMA public TO db03_user;

-- Customers are the main people/entities in this fake banking dataset.
CREATE TABLE public.customers (
    id SERIAL PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    city VARCHAR(50) NOT NULL,
    email VARCHAR(120) UNIQUE NOT NULL,
    customer_segment VARCHAR(30) NOT NULL,
    created_at DATE NOT NULL
);

-- One customer can have multiple accounts.
CREATE TABLE public.accounts (
    id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL REFERENCES public.customers(id),
    iban VARCHAR(34) UNIQUE NOT NULL,
    account_type VARCHAR(30) NOT NULL,
    balance NUMERIC(12,2) NOT NULL,
    currency VARCHAR(10) DEFAULT 'TRY',
    status VARCHAR(20) DEFAULT 'active',
    opened_at DATE NOT NULL
);

-- Transactions reference accounts twice:
-- from_account_id is the outgoing account, to_account_id is the incoming account.
CREATE TABLE public.transactions (
    id SERIAL PRIMARY KEY,
    from_account_id INT REFERENCES public.accounts(id),
    to_account_id INT REFERENCES public.accounts(id),
    amount NUMERIC(12,2) NOT NULL,
    transaction_type VARCHAR(30) NOT NULL,
    description TEXT,
    status VARCHAR(20) DEFAULT 'completed',
    created_at TIMESTAMP NOT NULL
);

-- Cards belong to customers and allow card-limit analysis.
CREATE TABLE public.cards (
    id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL REFERENCES public.customers(id),
    card_type VARCHAR(30) NOT NULL,
    masked_card_no VARCHAR(30) NOT NULL,
    monthly_limit NUMERIC(12,2) NOT NULL,
    status VARCHAR(20) DEFAULT 'active'
);

-- Branches represent fake bank locations.
CREATE TABLE public.branches (
    id SERIAL PRIMARY KEY,
    branch_name VARCHAR(100) NOT NULL,
    city VARCHAR(50) NOT NULL
);

-- Accounts belong to branches through this relation table.
CREATE TABLE public.account_branches (
    id SERIAL PRIMARY KEY,
    account_id INT NOT NULL REFERENCES public.accounts(id),
    branch_id INT NOT NULL REFERENCES public.branches(id)
);

-- Aggregation is useful for totals, averages, counts, and trend-style analysis.
CREATE INDEX idx_db03_customers_city ON public.customers(city);
CREATE INDEX idx_db03_customers_customer_segment ON public.customers(customer_segment);
CREATE INDEX idx_db03_accounts_customer_id ON public.accounts(customer_id);
CREATE INDEX idx_db03_accounts_balance ON public.accounts(balance);
CREATE INDEX idx_db03_accounts_status ON public.accounts(status);
CREATE INDEX idx_db03_transactions_from_account_id ON public.transactions(from_account_id);
CREATE INDEX idx_db03_transactions_to_account_id ON public.transactions(to_account_id);
CREATE INDEX idx_db03_transactions_created_at ON public.transactions(created_at);
CREATE INDEX idx_db03_transactions_status ON public.transactions(status);
CREATE INDEX idx_db03_transactions_transaction_type ON public.transactions(transaction_type);
CREATE INDEX idx_db03_cards_customer_id ON public.cards(customer_id);
CREATE INDEX idx_db03_account_branches_account_id ON public.account_branches(account_id);
CREATE INDEX idx_db03_account_branches_branch_id ON public.account_branches(branch_id);

-- Tum veriler sahte demo verisidir; gercek kisi veya banka verisi icermez.
INSERT INTO public.customers (id, full_name, city, email, customer_segment, created_at) VALUES
    (1, 'Ali Yilmaz', 'Kayseri', 'ali.yilmaz.db03@securebank.test', 'standard', '2025-07-01'),
    (2, 'Ayse Demir', 'Ankara', 'ayse.demir.db03@securebank.test', 'student', '2025-07-04'),
    (3, 'Mehmet Kaya', 'Istanbul', 'mehmet.kaya.db03@securebank.test', 'premium', '2025-07-08'),
    (4, 'Zeynep Arslan', 'Izmir', 'zeynep.arslan.db03@securebank.test', 'business', '2025-07-12'),
    (5, 'Can Ozkan', 'Bursa', 'can.ozkan.db03@securebank.test', 'standard', '2025-07-16'),
    (6, 'Elif Celik', 'Kayseri', 'elif.celik.db03@securebank.test', 'premium', '2025-07-20'),
    (7, 'Burak Aydin', 'Ankara', 'burak.aydin.db03@securebank.test', 'business', '2025-07-24'),
    (8, 'Selin Koc', 'Istanbul', 'selin.koc.db03@securebank.test', 'standard', '2025-07-28'),
    (9, 'Deniz Sahin', 'Izmir', 'deniz.sahin.db03@securebank.test', 'student', '2025-08-01'),
    (10, 'Mert Kaplan', 'Bursa', 'mert.kaplan.db03@securebank.test', 'premium', '2025-08-05'),
    (11, 'Ece Yildiz', 'Kayseri', 'ece.yildiz.db03@securebank.test', 'standard', '2025-08-09'),
    (12, 'Murat Aslan', 'Ankara', 'murat.aslan.db03@securebank.test', 'business', '2025-08-13');

SELECT setval('public.customers_id_seq', (SELECT MAX(id) FROM public.customers));

INSERT INTO public.accounts (id, customer_id, iban, account_type, balance, currency, status, opened_at) VALUES
    (1, 1, 'TR300000000000000000000001', 'checking', 12500.00, 'TRY', 'active', '2025-07-02'),
    (2, 1, 'TR300000000000000000000002', 'savings', 86000.75, 'TRY', 'active', '2025-07-03'),
    (3, 2, 'TR300000000000000000000003', 'student', 2400.00, 'TRY', 'active', '2025-07-05'),
    (4, 3, 'TR300000000000000000000004', 'checking', 45000.50, 'TRY', 'active', '2025-07-09'),
    (5, 3, 'TR300000000000000000000005', 'savings', 230000.00, 'TRY', 'active', '2025-07-10'),
    (6, 4, 'TR300000000000000000000006', 'business', 310000.00, 'TRY', 'active', '2025-07-13'),
    (7, 4, 'TR300000000000000000000007', 'checking', 18600.00, 'TRY', 'active', '2025-07-14'),
    (8, 5, 'TR300000000000000000000008', 'checking', 7800.00, 'TRY', 'active', '2025-07-17'),
    (9, 6, 'TR300000000000000000000009', 'savings', 145000.00, 'TRY', 'active', '2025-07-21'),
    (10, 6, 'TR300000000000000000000010', 'checking', 36000.00, 'TRY', 'active', '2025-07-22'),
    (11, 7, 'TR300000000000000000000011', 'business', 500000.00, 'TRY', 'active', '2025-07-25'),
    (12, 8, 'TR300000000000000000000012', 'checking', 15500.00, 'TRY', 'active', '2025-07-29'),
    (13, 8, 'TR300000000000000000000013', 'savings', 62000.00, 'TRY', 'inactive', '2025-07-30'),
    (14, 9, 'TR300000000000000000000014', 'student', 500.00, 'TRY', 'active', '2025-08-02'),
    (15, 10, 'TR300000000000000000000015', 'savings', 178000.00, 'TRY', 'active', '2025-08-06'),
    (16, 10, 'TR300000000000000000000016', 'checking', 22400.00, 'TRY', 'active', '2025-08-07'),
    (17, 11, 'TR300000000000000000000017', 'checking', 9400.00, 'TRY', 'active', '2025-08-10'),
    (18, 12, 'TR300000000000000000000018', 'business', 275000.00, 'TRY', 'active', '2025-08-14'),
    (19, 12, 'TR300000000000000000000019', 'checking', 50500.00, 'TRY', 'active', '2025-08-15');

SELECT setval('public.accounts_id_seq', (SELECT MAX(id) FROM public.accounts));

INSERT INTO public.branches (id, branch_name, city) VALUES
    (1, 'Kayseri Merkez', 'Kayseri'),
    (2, 'Ankara Cankaya', 'Ankara'),
    (3, 'Istanbul Kadikoy', 'Istanbul'),
    (4, 'Izmir Alsancak', 'Izmir'),
    (5, 'Bursa Nilufer', 'Bursa');

SELECT setval('public.branches_id_seq', (SELECT MAX(id) FROM public.branches));

INSERT INTO public.account_branches (id, account_id, branch_id) VALUES
    (1, 1, 1),
    (2, 2, 1),
    (3, 3, 2),
    (4, 4, 3),
    (5, 5, 3),
    (6, 6, 4),
    (7, 7, 4),
    (8, 8, 5),
    (9, 9, 1),
    (10, 10, 1),
    (11, 11, 2),
    (12, 12, 3),
    (13, 13, 3),
    (14, 14, 4),
    (15, 15, 5),
    (16, 16, 5),
    (17, 17, 1),
    (18, 18, 2),
    (19, 19, 2);

SELECT setval('public.account_branches_id_seq', (SELECT MAX(id) FROM public.account_branches));

INSERT INTO public.cards (id, customer_id, card_type, masked_card_no, monthly_limit, status) VALUES
    (1, 1, 'debit', '**** **** **** 1001', 10000.00, 'active'),
    (2, 2, 'student', '**** **** **** 1002', 3000.00, 'active'),
    (3, 3, 'credit', '**** **** **** 1003', 75000.00, 'active'),
    (4, 3, 'debit', '**** **** **** 1004', 20000.00, 'active'),
    (5, 4, 'business', '**** **** **** 1005', 120000.00, 'active'),
    (6, 6, 'credit', '**** **** **** 1006', 90000.00, 'active'),
    (7, 6, 'debit', '**** **** **** 1007', 25000.00, 'active'),
    (8, 7, 'business', '**** **** **** 1008', 150000.00, 'active'),
    (9, 9, 'student', '**** **** **** 1009', 2500.00, 'inactive'),
    (10, 10, 'credit', '**** **** **** 1010', 80000.00, 'active'),
    (11, 12, 'business', '**** **** **** 1011', 140000.00, 'active'),
    (12, 12, 'debit', '**** **** **** 1012', 30000.00, 'active');

SELECT setval('public.cards_id_seq', (SELECT MAX(id) FROM public.cards));

INSERT INTO public.transactions (id, from_account_id, to_account_id, amount, transaction_type, description, status, created_at) VALUES
    (1, 1, 3, 750.00, 'transfer', 'Demo havale', 'completed', '2025-10-01 09:05:00'),
    (2, 11, 1, 28500.00, 'salary', 'Demo maas odemesi', 'completed', '2025-10-02 10:10:00'),
    (3, 4, 6, 1200.00, 'bill_payment', 'Demo fatura odemesi', 'completed', '2025-10-03 11:15:00'),
    (4, 2, 5, 12500.00, 'transfer', 'Demo birikim aktarimi', 'completed', '2025-10-04 12:20:00'),
    (5, 11, 9, 75000.00, 'transfer', 'Demo tedarikci odemesi', 'completed', '2025-10-05 13:25:00'),
    (6, 16, 8, 3250.00, 'card_payment', 'Demo kart harcamasi', 'completed', '2025-10-06 14:30:00'),
    (7, 14, 12, 50.00, 'card_payment', 'Demo kucuk tutar', 'completed', '2025-10-07 15:35:00'),
    (8, 18, 6, 42000.00, 'loan_payment', 'Demo kredi odemesi', 'pending', '2025-10-08 16:40:00'),
    (9, 5, 11, 120000.00, 'transfer', 'Demo yuksek tutar', 'completed', '2025-10-09 17:45:00'),
    (10, 13, 4, 9900.00, 'transfer', 'Demo basarisiz transfer', 'failed', '2025-10-10 18:50:00'),
    (11, 6, 18, 18500.00, 'transfer', 'Demo sirket transferi', 'completed', '2025-10-11 09:00:00'),
    (12, 10, 1, 2700.00, 'bill_payment', 'Demo abonelik odemesi', 'completed', '2025-10-12 10:05:00'),
    (13, 3, 12, 650.00, 'card_payment', 'Demo ogrenci harcamasi', 'completed', '2025-10-13 11:10:00'),
    (14, 8, 7, 1800.00, 'transfer', 'Demo bireysel transfer', 'completed', '2025-10-14 12:15:00'),
    (15, 18, 15, 64000.00, 'transfer', 'Demo hesaplar arasi', 'completed', '2025-10-15 13:20:00'),
    (16, 1, 17, 5000.00, 'transfer', 'Demo aile transferi', 'completed', '2025-10-16 14:25:00'),
    (17, 17, 3, 4100.00, 'transfer', 'Demo bekleyen transfer', 'pending', '2025-10-17 15:30:00'),
    (18, 15, 2, 22000.00, 'transfer', 'Demo vadeli aktarim', 'completed', '2025-10-18 16:35:00'),
    (19, 9, 10, 7000.00, 'transfer', 'Demo hesap aktarimi', 'completed', '2025-10-19 17:40:00'),
    (20, 11, 18, 98000.00, 'loan_payment', 'Demo kredi kapama', 'completed', '2025-10-20 18:45:00'),
    (21, 12, 4, 2400.00, 'atm_withdrawal', 'Demo ATM islemi', 'completed', '2025-11-01 09:05:00'),
    (22, 7, 16, 1300.00, 'card_payment', 'Demo reddedilen kart islemi', 'failed', '2025-11-02 10:10:00'),
    (23, 6, 5, 33250.00, 'transfer', 'Demo cari aktarim', 'completed', '2025-11-03 11:15:00'),
    (24, 19, 1, 17500.00, 'salary', 'Demo maas aktarimi', 'completed', '2025-11-04 12:20:00'),
    (25, 2, 14, 880.00, 'transfer', 'Demo ogrenci destegi', 'completed', '2025-11-05 13:25:00'),
    (26, 4, 13, 9900.00, 'transfer', 'Demo tasarruf aktarimi', 'completed', '2025-11-06 14:30:00'),
    (27, 15, 6, 55000.00, 'transfer', 'Demo yuksek bakiye aktarimi', 'completed', '2025-11-07 15:35:00'),
    (28, 10, 7, 640.00, 'card_payment', 'Demo kart odemesi', 'completed', '2025-11-08 16:40:00'),
    (29, 5, 2, 21200.00, 'transfer', 'Demo yatirim aktarimi', 'completed', '2025-11-09 17:45:00'),
    (30, 18, 11, 45500.00, 'transfer', 'Demo firma odemesi', 'completed', '2025-11-10 18:50:00'),
    (31, 1, 8, 1250.00, 'bill_payment', 'Demo bekleyen fatura', 'pending', '2025-11-11 09:00:00'),
    (32, 9, 3, 5050.00, 'transfer', 'Demo rutin transfer', 'completed', '2025-11-12 10:05:00'),
    (33, 3, 14, 600.00, 'card_payment', 'Demo basarisiz kart islemi', 'failed', '2025-11-13 11:10:00'),
    (34, 11, 5, 112000.00, 'transfer', 'Demo kurumsal odeme', 'completed', '2025-12-01 12:15:00'),
    (35, 16, 19, 3750.00, 'transfer', 'Demo bireysel odeme', 'completed', '2025-12-02 13:20:00'),
    (36, 17, 9, 500.00, 'atm_withdrawal', 'Demo basarisiz ATM islemi', 'failed', '2025-12-03 14:25:00'),
    (37, 13, 12, 8200.00, 'transfer', 'Demo hesap transferi', 'completed', '2025-12-04 15:30:00'),
    (38, 18, 6, 70000.00, 'loan_payment', 'Demo kredi odemesi', 'completed', '2025-12-05 16:35:00'),
    (39, 4, 10, 3600.00, 'transfer', 'Demo bekleyen islem', 'pending', '2025-12-06 17:40:00'),
    (40, 6, 15, 18200.00, 'salary', 'Demo personel maasi', 'completed', '2025-12-07 18:45:00');

SELECT setval('public.transactions_id_seq', (SELECT MAX(id) FROM public.transactions));

-- db03_user is intentionally read-only for this analytics lab.
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM PUBLIC;
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM db03_user;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO db03_user;

REVOKE ALL ON ALL SEQUENCES IN SCHEMA public FROM PUBLIC;
REVOKE ALL ON ALL SEQUENCES IN SCHEMA public FROM db03_user;

ALTER DEFAULT PRIVILEGES IN SCHEMA public REVOKE ALL ON TABLES FROM PUBLIC;
ALTER DEFAULT PRIVILEGES IN SCHEMA public REVOKE ALL ON SEQUENCES FROM PUBLIC;
