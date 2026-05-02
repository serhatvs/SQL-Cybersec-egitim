-- DB02 - Relations and JOINs
-- Bu veritabani yalnizca iliskisel veritabani ve JOIN pratigi icindir.
-- SQL Injection, Red Team veya Blue Team senaryosu degildir.

\connect db02_relations_joins

-- Public schema permissions are restricted before creating workshop objects.
REVOKE ALL ON SCHEMA public FROM PUBLIC;
GRANT USAGE ON SCHEMA public TO db02_user;

-- Primary Key (PK): customers.id her musteriyi benzersiz olarak tanimlar.
CREATE TABLE public.customers (
    id SERIAL PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    city VARCHAR(50) NOT NULL,
    email VARCHAR(120) UNIQUE NOT NULL,
    created_at DATE NOT NULL
);

-- Foreign Key (FK): accounts.customer_id, customers.id alanina baglanir.
-- One-to-many: Bir musteri birden fazla hesaba sahip olabilir.
CREATE TABLE public.accounts (
    id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL REFERENCES public.customers(id),
    iban VARCHAR(34) UNIQUE NOT NULL,
    account_type VARCHAR(30) NOT NULL,
    balance NUMERIC(12,2) NOT NULL,
    currency VARCHAR(10) DEFAULT 'TRY',
    status VARCHAR(20) DEFAULT 'active'
);

-- Useful indexes for beginner WHERE and JOIN examples.
CREATE INDEX idx_db02_customers_city ON public.customers(city);
CREATE INDEX idx_db02_accounts_customer_id ON public.accounts(customer_id);
CREATE INDEX idx_db02_accounts_balance ON public.accounts(balance);
CREATE INDEX idx_db02_accounts_status ON public.accounts(status);

-- Tum veriler sahte demo verisidir; gercek kisi veya banka verisi icermez.
INSERT INTO public.customers (id, full_name, city, email, created_at) VALUES
    (1, 'Ali Yilmaz', 'Kayseri', 'ali.yilmaz.db02@securebank.test', '2025-08-01'),
    (2, 'Ayse Demir', 'Ankara', 'ayse.demir.db02@securebank.test', '2025-08-04'),
    (3, 'Mehmet Kaya', 'Istanbul', 'mehmet.kaya.db02@securebank.test', '2025-08-08'),
    (4, 'Zeynep Arslan', 'Izmir', 'zeynep.arslan.db02@securebank.test', '2025-08-13'),
    (5, 'Can Ozkan', 'Bursa', 'can.ozkan.db02@securebank.test', '2025-08-17'),
    (6, 'Elif Celik', 'Kayseri', 'elif.celik.db02@securebank.test', '2025-08-22'),
    (7, 'Burak Aydin', 'Ankara', 'burak.aydin.db02@securebank.test', '2025-08-29'),
    (8, 'Selin Koc', 'Istanbul', 'selin.koc.db02@securebank.test', '2025-09-03'),
    (9, 'Deniz Sahin', 'Izmir', 'deniz.sahin.db02@securebank.test', '2025-09-09'),
    (10, 'Mert Kaplan', 'Bursa', 'mert.kaplan.db02@securebank.test', '2025-09-14');

SELECT setval('public.customers_id_seq', (SELECT MAX(id) FROM public.customers));

INSERT INTO public.accounts (id, customer_id, iban, account_type, balance, currency, status) VALUES
    (1, 1, 'TR200000000000000000000001', 'checking', 12500.00, 'TRY', 'active'),
    (2, 1, 'TR200000000000000000000002', 'savings', 68500.75, 'TRY', 'active'),
    (3, 2, 'TR200000000000000000000003', 'student', 1800.00, 'TRY', 'active'),
    (4, 3, 'TR200000000000000000000004', 'checking', 42000.50, 'TRY', 'active'),
    (5, 3, 'TR200000000000000000000005', 'savings', 150000.00, 'TRY', 'active'),
    (6, 3, 'TR200000000000000000000006', 'business', 200000.00, 'TRY', 'active'),
    (7, 4, 'TR200000000000000000000007', 'checking', 27500.25, 'TRY', 'active'),
    (8, 4, 'TR200000000000000000000008', 'business', 94500.80, 'TRY', 'active'),
    (9, 6, 'TR200000000000000000000009', 'savings', 54000.00, 'TRY', 'active'),
    (10, 7, 'TR200000000000000000000010', 'checking', 9900.40, 'TRY', 'active'),
    (11, 7, 'TR200000000000000000000011', 'business', 121000.00, 'TRY', 'active'),
    (12, 9, 'TR200000000000000000000012', 'student', 500.00, 'TRY', 'active'),
    (13, 9, 'TR200000000000000000000013', 'checking', 31250.60, 'TRY', 'active'),
    (14, 9, 'TR200000000000000000000014', 'savings', 87500.00, 'TRY', 'inactive'),
    (15, 10, 'TR200000000000000000000015', 'checking', 16400.35, 'TRY', 'active'),
    (16, 10, 'TR200000000000000000000016', 'business', 132000.90, 'TRY', 'active');

SELECT setval('public.accounts_id_seq', (SELECT MAX(id) FROM public.accounts));

-- db02_user is intentionally read-only for this JOIN practice lab.
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM PUBLIC;
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM db02_user;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO db02_user;

REVOKE ALL ON ALL SEQUENCES IN SCHEMA public FROM PUBLIC;
REVOKE ALL ON ALL SEQUENCES IN SCHEMA public FROM db02_user;

ALTER DEFAULT PRIVILEGES IN SCHEMA public REVOKE ALL ON TABLES FROM PUBLIC;
ALTER DEFAULT PRIVILEGES IN SCHEMA public REVOKE ALL ON SEQUENCES FROM PUBLIC;
