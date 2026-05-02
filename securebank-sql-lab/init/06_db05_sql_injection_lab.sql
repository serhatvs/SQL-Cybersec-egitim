-- DB05 - Safe SQL Injection Education Lab
-- This controlled local lab explains SQL Injection concepts for defense.
-- It does not include destructive payloads or real-system attack instructions.

\connect db05_sql_injection_lab

-- Public schema permissions are restricted before creating workshop objects.
REVOKE ALL ON SCHEMA public FROM PUBLIC;
GRANT USAGE ON SCHEMA public TO db05_user;

-- Application users. Password values are fake hashes only.
-- Do not store real plaintext passwords.
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

-- Customer profiles represent sensitive-ish data for lab analysis.
CREATE TABLE public.customer_profiles (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL REFERENCES public.app_users(id),
    phone_masked VARCHAR(30),
    city VARCHAR(50),
    risk_level VARCHAR(20),
    kyc_status VARCHAR(30),
    created_at DATE NOT NULL
);

-- Pseudo-code examples only: these rows explain unsafe patterns and safe
-- prepared-statement style alternatives. They are not executable exploit code.
CREATE TABLE public.vulnerable_query_examples (
    id SERIAL PRIMARY KEY,
    example_name VARCHAR(100) NOT NULL,
    feature_area VARCHAR(50) NOT NULL,
    unsafe_pattern TEXT NOT NULL,
    why_vulnerable TEXT NOT NULL,
    safe_pattern TEXT NOT NULL,
    defense_note TEXT NOT NULL
);

-- Input logs are for defensive detection practice with SELECT/WHERE/LIKE/GROUP BY.
-- Suspicious rows contain minimal indicators such as quotes, comment markers,
-- unusual length, or keyword-like fragments. They are non-destructive examples.
CREATE TABLE public.input_attempt_logs (
    id SERIAL PRIMARY KEY,
    source_ip VARCHAR(45) NOT NULL,
    feature_area VARCHAR(50) NOT NULL,
    input_value TEXT NOT NULL,
    normalized_risk VARCHAR(30) NOT NULL,
    detected_reason VARCHAR(150),
    created_at TIMESTAMP NOT NULL
);

-- Prevention techniques for SQL Injection defense.
CREATE TABLE public.safe_query_checklist (
    id SERIAL PRIMARY KEY,
    checklist_item VARCHAR(150) NOT NULL,
    category VARCHAR(50) NOT NULL,
    explanation TEXT NOT NULL
);

CREATE TABLE public.security_flags (
    id SERIAL PRIMARY KEY,
    flag_name VARCHAR(80) NOT NULL,
    flag_value VARCHAR(120) NOT NULL,
    note TEXT
);

CREATE INDEX idx_db05_app_users_username ON public.app_users(username);
CREATE INDEX idx_db05_app_users_role ON public.app_users(role);
CREATE INDEX idx_db05_customer_profiles_user_id ON public.customer_profiles(user_id);
CREATE INDEX idx_db05_customer_profiles_risk_level ON public.customer_profiles(risk_level);
CREATE INDEX idx_db05_input_attempt_logs_feature_area ON public.input_attempt_logs(feature_area);
CREATE INDEX idx_db05_input_attempt_logs_normalized_risk ON public.input_attempt_logs(normalized_risk);
CREATE INDEX idx_db05_input_attempt_logs_created_at ON public.input_attempt_logs(created_at);
CREATE INDEX idx_db05_vulnerable_query_examples_feature_area ON public.vulnerable_query_examples(feature_area);

-- Tum veriler sahte demo verisidir; gercek kisi veya banka verisi icermez.
INSERT INTO public.app_users (id, username, full_name, email, password_hash, role, status, created_at) VALUES
    (1, 'ali.yilmaz', 'Ali Yilmaz', 'ali.yilmaz.db05@securebank.test', 'fake_hash_ali_001', 'customer', 'active', '2025-09-01'),
    (2, 'ayse.demir', 'Ayse Demir', 'ayse.demir.db05@securebank.test', 'fake_hash_ayse_002', 'customer', 'active', '2025-09-03'),
    (3, 'mehmet.kaya', 'Mehmet Kaya', 'mehmet.kaya.db05@securebank.test', 'fake_hash_mehmet_003', 'customer', 'active', '2025-09-05'),
    (4, 'zeynep.arslan', 'Zeynep Arslan', 'zeynep.arslan.db05@securebank.test', 'fake_hash_zeynep_004', 'customer', 'active', '2025-09-07'),
    (5, 'can.ozkan', 'Can Ozkan', 'can.ozkan.db05@securebank.test', 'fake_hash_can_005', 'customer', 'active', '2025-09-09'),
    (6, 'elif.celik', 'Elif Celik', 'elif.celik.db05@securebank.test', 'fake_hash_elif_006', 'customer', 'active', '2025-09-11'),
    (7, 'burak.aydin', 'Burak Aydin', 'burak.aydin.db05@securebank.test', 'fake_hash_burak_007', 'customer', 'inactive', '2025-09-13'),
    (8, 'selin.koc', 'Selin Koc', 'selin.koc.db05@securebank.test', 'fake_hash_selin_008', 'staff', 'active', '2025-09-15'),
    (9, 'deniz.sahin', 'Deniz Sahin', 'deniz.sahin.db05@securebank.test', 'fake_hash_deniz_009', 'staff', 'active', '2025-09-17'),
    (10, 'mert.kaplan', 'Mert Kaplan', 'mert.kaplan.db05@securebank.test', 'fake_hash_mert_010', 'admin', 'active', '2025-09-19');

SELECT setval('public.app_users_id_seq', (SELECT MAX(id) FROM public.app_users));

INSERT INTO public.customer_profiles (id, user_id, phone_masked, city, risk_level, kyc_status, created_at) VALUES
    (1, 1, '+90 *** *** 1001', 'Kayseri', 'low', 'verified', '2025-09-02'),
    (2, 2, '+90 *** *** 1002', 'Ankara', 'low', 'verified', '2025-09-04'),
    (3, 3, '+90 *** *** 1003', 'Istanbul', 'medium', 'verified', '2025-09-06'),
    (4, 4, '+90 *** *** 1004', 'Izmir', 'low', 'pending_review', '2025-09-08'),
    (5, 5, '+90 *** *** 1005', 'Bursa', 'medium', 'verified', '2025-09-10'),
    (6, 6, '+90 *** *** 1006', 'Kayseri', 'low', 'verified', '2025-09-12'),
    (7, 7, '+90 *** *** 1007', 'Ankara', 'high', 'needs_review', '2025-09-14'),
    (8, 8, '+90 *** *** 1008', 'Istanbul', 'low', 'staff_record', '2025-09-16'),
    (9, 9, '+90 *** *** 1009', 'Izmir', 'low', 'staff_record', '2025-09-18'),
    (10, 10, '+90 *** *** 1010', 'Bursa', 'medium', 'admin_record', '2025-09-20');

SELECT setval('public.customer_profiles_id_seq', (SELECT MAX(id) FROM public.customer_profiles));

INSERT INTO public.vulnerable_query_examples (id, example_name, feature_area, unsafe_pattern, why_vulnerable, safe_pattern, defense_note) VALUES
    (1, 'Unsafe login query by concatenation', 'login', 'PSEUDO-CODE: SELECT * FROM app_users WHERE username = '' + username_input + '' AND password_hash = '' + hash_input + ''', 'User input is directly joined into SQL text, so query logic may change if special SQL-like characters are accepted.', 'Use a prepared statement: SELECT * FROM app_users WHERE username = $1 AND password_hash = $2', 'Parameterize every value, return generic login errors, and keep the database user least-privileged.'),
    (2, 'Unsafe customer search query', 'customer_search', 'PSEUDO-CODE: SELECT * FROM customer_profiles WHERE city LIKE ''%'' + search_input + ''%''', 'Search text is treated as SQL text instead of data, which can blur the boundary between input and query structure.', 'Use a prepared statement with a parameterized pattern value, for example city ILIKE $1 where $1 is built safely by application code.', 'Validate length, log suspicious markers, and avoid exposing detailed SQL errors to users.'),
    (3, 'Unsafe account lookup by id', 'account_lookup', 'PSEUDO-CODE: SELECT * FROM accounts WHERE id = ' || 'account_id_input', 'A numeric identifier supplied by a user should still be parsed and bound safely, not appended into a SQL string.', 'Parse the id as an integer in application code, then use WHERE id = $1 with a prepared statement.', 'Combine parameterization with authorization checks so users only access allowed records.'),
    (4, 'Unsafe ORDER BY sort parameter', 'sorting', 'PSEUDO-CODE: SELECT * FROM app_users ORDER BY ' || 'sort_input', 'Column names cannot be value-parameterized in the same way, so raw sort text can change query structure.', 'Use an allow-list such as username, created_at, or status, then map the approved option to a fixed SQL fragment.', 'Allow-list sort columns and directions; reject unknown values.'),
    (5, 'Unsafe admin filter logic', 'admin_filter', 'PSEUDO-CODE: SELECT * FROM app_users WHERE role = '' + role_filter + '' AND status = ''active''', 'Admin filters often handle powerful data; direct concatenation may alter the intended filter logic.', 'Use prepared statements for filter values and enforce role checks before running admin queries.', 'Use prepared statements, authorization checks, least privilege, and safe error handling together.');

SELECT setval('public.vulnerable_query_examples_id_seq', (SELECT MAX(id) FROM public.vulnerable_query_examples));

INSERT INTO public.input_attempt_logs (id, source_ip, feature_area, input_value, normalized_risk, detected_reason, created_at) VALUES
    (1, '192.168.30.11', 'login', 'ali.yilmaz', 'normal', 'expected username format', '2025-10-01 09:00:00'),
    (2, '192.168.30.12', 'login', 'ayse.demir', 'normal', 'expected username format', '2025-10-01 09:03:00'),
    (3, '192.168.30.13', 'customer_search', 'Kayseri', 'normal', 'known city value', '2025-10-01 09:06:00'),
    (4, '192.168.30.14', 'customer_search', 'Ankara', 'normal', 'known city value', '2025-10-01 09:09:00'),
    (5, '192.168.30.15', 'account_lookup', '1001', 'normal', 'numeric lookup value', '2025-10-01 09:12:00'),
    (6, '192.168.30.16', 'account_lookup', '1002', 'normal', 'numeric lookup value', '2025-10-01 09:15:00'),
    (7, '192.168.30.17', 'sorting', 'created_at_desc', 'normal', 'allowed sort option', '2025-10-01 09:18:00'),
    (8, '192.168.30.18', 'sorting', 'username_asc', 'normal', 'allowed sort option', '2025-10-01 09:21:00'),
    (9, '192.168.30.19', 'admin_filter', 'customer', 'normal', 'known role value', '2025-10-01 09:24:00'),
    (10, '192.168.30.20', 'admin_filter', 'staff', 'normal', 'known role value', '2025-10-01 09:27:00'),
    (11, '192.168.30.21', 'login', 'mehmet.kaya', 'normal', 'expected username format', '2025-10-01 09:30:00'),
    (12, '192.168.30.22', 'customer_search', 'Istanbul', 'normal', 'known city value', '2025-10-01 09:33:00'),
    (13, '192.168.30.23', 'customer_search', 'Izmir', 'normal', 'known city value', '2025-10-01 09:36:00'),
    (14, '192.168.30.24', 'customer_search', 'Bursa', 'normal', 'known city value', '2025-10-01 09:39:00'),
    (15, '192.168.30.25', 'profile_search', 'verified', 'normal', 'known status value', '2025-10-01 09:42:00'),
    (16, '192.168.30.26', 'profile_search', 'pending_review', 'normal', 'known status value', '2025-10-01 09:45:00'),
    (17, '192.168.30.27', 'login', 'zeynep.arslan', 'normal', 'expected username format', '2025-10-01 09:48:00'),
    (18, '192.168.30.28', 'sorting', 'status_asc', 'normal', 'allowed sort option', '2025-10-01 09:51:00'),
    (19, '192.168.30.31', 'login', 'ali''', 'suspicious', 'contains quote character', '2025-10-01 10:00:00'),
    (20, '192.168.30.32', 'customer_search', 'Kayseri -- note', 'suspicious', 'contains comment marker', '2025-10-01 10:03:00'),
    (21, '192.168.30.33', 'account_lookup', '1001 OR 1002', 'suspicious', 'contains boolean-like expression', '2025-10-01 10:06:00'),
    (22, '192.168.30.34', 'admin_filter', 'admin''', 'suspicious', 'contains quote character', '2025-10-01 10:09:00'),
    (23, '192.168.30.35', 'sorting', 'created_at -- check', 'suspicious', 'contains comment marker', '2025-10-01 10:12:00'),
    (24, '192.168.30.36', 'customer_search', 'name OR city', 'suspicious', 'contains boolean-like expression', '2025-10-01 10:15:00'),
    (25, '192.168.30.37', 'profile_search', 'verified'' status', 'suspicious', 'contains quote character', '2025-10-01 10:18:00'),
    (26, '192.168.30.38', 'login', 'very_long_username_marker_aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa', 'suspicious', 'unusual input length', '2025-10-01 10:21:00'),
    (27, '192.168.30.41', 'login', ''' boolean marker', 'high', 'contains quote character and boolean-like expression', '2025-10-01 10:30:00'),
    (28, '192.168.30.42', 'account_lookup', '1 -- marker', 'high', 'contains comment marker', '2025-10-01 10:33:00'),
    (29, '192.168.30.43', 'admin_filter', 'role OR status', 'high', 'unexpected keyword-like pattern', '2025-10-01 10:36:00'),
    (30, '192.168.30.44', 'customer_search', ''' -- marker', 'high', 'contains quote character and comment marker', '2025-10-01 10:39:00');

SELECT setval('public.input_attempt_logs_id_seq', (SELECT MAX(id) FROM public.input_attempt_logs));

INSERT INTO public.safe_query_checklist (id, checklist_item, category, explanation) VALUES
    (1, 'Use prepared statements for every user-provided value', 'parameterization', 'Prepared statements keep data separate from SQL structure.'),
    (2, 'Bind login username and password hash as parameters', 'parameterization', 'Login queries should never be assembled through string concatenation.'),
    (3, 'Validate input length and expected format', 'validation', 'Short allow-listed formats reduce noisy and suspicious inputs.'),
    (4, 'Allow-list sort columns and sort directions', 'validation', 'ORDER BY identifiers should come from fixed application choices.'),
    (5, 'Check authorization after identifying the requested record', 'authorization', 'A safe query must also confirm the user is allowed to see the data.'),
    (6, 'Run the application with a least-privileged database user', 'least_privilege', 'Read-only lab users limit damage if application logic has a bug.'),
    (7, 'Log suspicious input patterns for review', 'logging', 'Quote characters, comment markers, and unusual lengths are useful detection signals.'),
    (8, 'Return generic errors to users', 'error_handling', 'Detailed SQL errors can reveal table names, column names, or query structure.'),
    (9, 'Review suspicious activity by feature area', 'logging', 'Grouping by feature_area helps defenders see where risky inputs appear most often.');

SELECT setval('public.safe_query_checklist_id_seq', (SELECT MAX(id) FROM public.safe_query_checklist));

INSERT INTO public.security_flags (id, flag_name, flag_value, note) VALUES
    (1, 'training_flag_05', 'flag{parameterize_every_query}', 'Lab discovery flag for prepared statement discussion.');

SELECT setval('public.security_flags_id_seq', (SELECT MAX(id) FROM public.security_flags));

-- db05_user is intentionally read-only for this safe education lab.
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM PUBLIC;
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM db05_user;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO db05_user;

REVOKE ALL ON ALL SEQUENCES IN SCHEMA public FROM PUBLIC;
REVOKE ALL ON ALL SEQUENCES IN SCHEMA public FROM db05_user;

ALTER DEFAULT PRIVILEGES IN SCHEMA public REVOKE ALL ON TABLES FROM PUBLIC;
ALTER DEFAULT PRIVILEGES IN SCHEMA public REVOKE ALL ON SEQUENCES FROM PUBLIC;
