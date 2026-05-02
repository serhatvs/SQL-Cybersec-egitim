-- DB01 - SQL Basics
-- Bu veritabani yalnizca baslangic seviye SQL pratigi icindir.
-- SQL Injection, Red Team veya Blue Team senaryosu degildir.

\connect db01_sql_basics

-- Public schema permissions are restricted before creating workshop objects.
REVOKE ALL ON SCHEMA public FROM PUBLIC;
GRANT USAGE ON SCHEMA public TO db01_user;

-- Tek tablo: ogrenciler SELECT, WHERE, ORDER BY ve LIMIT calissin diye sade tutuldu.
CREATE TABLE public.customers (
    id SERIAL PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    city VARCHAR(50) NOT NULL,
    age INT NOT NULL,
    balance NUMERIC(12,2) NOT NULL,
    account_type VARCHAR(30) NOT NULL,
    is_active BOOLEAN DEFAULT true,
    created_at DATE NOT NULL
);

-- Tum veriler sahte demo verisidir; gercek kisi veya banka verisi icermez.
INSERT INTO public.customers (id, full_name, city, age, balance, account_type, is_active, created_at) VALUES
    (1, 'Ali Yilmaz', 'Kayseri', 34, 12500.75, 'checking', true, '2025-09-10'),
    (2, 'Ayse Demir', 'Ankara', 28, 8450.00, 'student', true, '2025-09-12'),
    (3, 'Mehmet Kaya', 'Istanbul', 45, 73500.50, 'savings', true, '2025-09-18'),
    (4, 'Zeynep Arslan', 'Izmir', 31, 52200.25, 'business', true, '2025-09-25'),
    (5, 'Can Ozkan', 'Bursa', 22, 3100.00, 'student', false, '2025-10-02'),
    (6, 'Elif Celik', 'Kayseri', 39, 148900.00, 'business', true, '2025-10-08'),
    (7, 'Murat Sahin', 'Ankara', 52, 21500.40, 'checking', true, '2025-10-15'),
    (8, 'Deniz Acar', 'Istanbul', 19, 980.00, 'student', true, '2025-10-19'),
    (9, 'Selin Ozkan', 'Izmir', 41, 67320.90, 'savings', false, '2025-10-28'),
    (10, 'Burak Yildiz', 'Bursa', 36, 45500.10, 'checking', true, '2025-11-03'),
    (11, 'Ece Koc', 'Kayseri', 27, 18900.00, 'savings', true, '2025-11-11'),
    (12, 'Ozan Kurt', 'Ankara', 63, 99000.00, 'business', false, '2025-11-18'),
    (13, 'Buse Aydin', 'Istanbul', 24, 5600.75, 'student', true, '2025-11-24'),
    (14, 'Kerem Polat', 'Izmir', 48, 82000.30, 'business', true, '2025-12-01'),
    (15, 'Seda Gunes', 'Bursa', 33, 15100.00, 'checking', true, '2025-12-07'),
    (16, 'Hakan Aslan', 'Kayseri', 58, 120500.80, 'savings', true, '2025-12-13'),
    (17, 'Derya Eren', 'Ankara', 18, 500.00, 'student', false, '2025-12-20'),
    (18, 'Kaan Tekin', 'Istanbul', 29, 34200.45, 'checking', true, '2025-12-27'),
    (19, 'Melis Kaplan', 'Izmir', 65, 150000.00, 'savings', true, '2026-01-05'),
    (20, 'Arda Cinar', 'Bursa', 44, 60500.60, 'business', false, '2026-01-14');

SELECT setval('public.customers_id_seq', (SELECT MAX(id) FROM public.customers));

-- db01_user is intentionally read-only for this beginner lab.
REVOKE ALL ON public.customers FROM PUBLIC;
REVOKE ALL ON public.customers FROM db01_user;
GRANT SELECT ON public.customers TO db01_user;

REVOKE ALL ON ALL SEQUENCES IN SCHEMA public FROM PUBLIC;
REVOKE ALL ON ALL SEQUENCES IN SCHEMA public FROM db01_user;

ALTER DEFAULT PRIVILEGES IN SCHEMA public REVOKE ALL ON TABLES FROM PUBLIC;
ALTER DEFAULT PRIVILEGES IN SCHEMA public REVOKE ALL ON SEQUENCES FROM PUBLIC;
