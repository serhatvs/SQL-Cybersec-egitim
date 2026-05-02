-- DB06 - Audit Log and Digital Forensics Lab
-- This database is for defensive log analysis, incident investigation,
-- and forensic reasoning with SQL. It is not for exploiting systems.

\connect db06_audit_forensics_lab

-- Public schema permissions are restricted before creating workshop objects.
REVOKE ALL ON SCHEMA public FROM PUBLIC;
GRANT USAGE ON SCHEMA public TO db06_user;

CREATE TABLE public.app_users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(120) UNIQUE NOT NULL,
    role VARCHAR(30) NOT NULL,
    status VARCHAR(20) DEFAULT 'active',
    created_at DATE NOT NULL
);

CREATE TABLE public.devices (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL REFERENCES public.app_users(id),
    device_name VARCHAR(100) NOT NULL,
    device_type VARCHAR(40) NOT NULL,
    os_name VARCHAR(60) NOT NULL,
    trusted BOOLEAN DEFAULT false,
    registered_at DATE NOT NULL
);

-- IP reputation helps analysts correlate network risk with auth and query logs.
CREATE TABLE public.ip_reputation (
    id SERIAL PRIMARY KEY,
    ip_address VARCHAR(45) UNIQUE NOT NULL,
    country VARCHAR(60),
    reputation VARCHAR(30) NOT NULL,
    note TEXT
);

-- auth_logs contains authentication events such as login, logout, and MFA.
CREATE TABLE public.auth_logs (
    id SERIAL PRIMARY KEY,
    user_id INT REFERENCES public.app_users(id),
    device_id INT REFERENCES public.devices(id),
    ip_address VARCHAR(45) NOT NULL,
    event_type VARCHAR(40) NOT NULL,
    success BOOLEAN NOT NULL,
    failure_reason VARCHAR(120),
    created_at TIMESTAMP NOT NULL
);

-- query_activity_logs contains database activity for investigation.
CREATE TABLE public.query_activity_logs (
    id SERIAL PRIMARY KEY,
    user_id INT REFERENCES public.app_users(id),
    ip_address VARCHAR(45) NOT NULL,
    database_name VARCHAR(80) NOT NULL,
    action_type VARCHAR(80) NOT NULL,
    object_name VARCHAR(120),
    row_count INT DEFAULT 0,
    risk_level VARCHAR(30) NOT NULL,
    created_at TIMESTAMP NOT NULL
);

CREATE TABLE public.security_events (
    id SERIAL PRIMARY KEY,
    event_name VARCHAR(120) NOT NULL,
    severity VARCHAR(30) NOT NULL,
    related_user_id INT REFERENCES public.app_users(id),
    ip_address VARCHAR(45),
    description TEXT NOT NULL,
    created_at TIMESTAMP NOT NULL
);

-- Investigation hints and defensive analyst notes.
-- Students should reconstruct timelines using SQL joins and UNION queries.
CREATE TABLE public.incident_notes (
    id SERIAL PRIMARY KEY,
    note_title VARCHAR(120) NOT NULL,
    note_body TEXT NOT NULL,
    created_at TIMESTAMP NOT NULL
);

CREATE INDEX idx_db06_app_users_username ON public.app_users(username);
CREATE INDEX idx_db06_app_users_role ON public.app_users(role);
CREATE INDEX idx_db06_devices_user_id ON public.devices(user_id);
CREATE INDEX idx_db06_devices_trusted ON public.devices(trusted);
CREATE INDEX idx_db06_ip_reputation_ip_address ON public.ip_reputation(ip_address);
CREATE INDEX idx_db06_ip_reputation_reputation ON public.ip_reputation(reputation);
CREATE INDEX idx_db06_auth_logs_user_id ON public.auth_logs(user_id);
CREATE INDEX idx_db06_auth_logs_ip_address ON public.auth_logs(ip_address);
CREATE INDEX idx_db06_auth_logs_created_at ON public.auth_logs(created_at);
CREATE INDEX idx_db06_auth_logs_success ON public.auth_logs(success);
CREATE INDEX idx_db06_query_activity_logs_user_id ON public.query_activity_logs(user_id);
CREATE INDEX idx_db06_query_activity_logs_ip_address ON public.query_activity_logs(ip_address);
CREATE INDEX idx_db06_query_activity_logs_risk_level ON public.query_activity_logs(risk_level);
CREATE INDEX idx_db06_query_activity_logs_created_at ON public.query_activity_logs(created_at);
CREATE INDEX idx_db06_security_events_severity ON public.security_events(severity);
CREATE INDEX idx_db06_security_events_related_user_id ON public.security_events(related_user_id);
CREATE INDEX idx_db06_security_events_created_at ON public.security_events(created_at);

-- Tum veriler sahte demo verisidir; gercek kisi, banka veya log verisi icermez.
INSERT INTO public.app_users (id, username, full_name, email, role, status, created_at) VALUES
    (1, 'ali.yilmaz', 'Ali Yilmaz', 'ali.yilmaz.db06@securebank.test', 'customer', 'active', '2025-08-01'),
    (2, 'ayse.demir', 'Ayse Demir', 'ayse.demir.db06@securebank.test', 'customer', 'active', '2025-08-02'),
    (3, 'mehmet.kaya', 'Mehmet Kaya', 'mehmet.kaya.db06@securebank.test', 'customer', 'active', '2025-08-03'),
    (4, 'zeynep.arslan', 'Zeynep Arslan', 'zeynep.arslan.db06@securebank.test', 'customer', 'active', '2025-08-04'),
    (5, 'can.ozkan', 'Can Ozkan', 'can.ozkan.db06@securebank.test', 'customer', 'active', '2025-08-05'),
    (6, 'elif.celik', 'Elif Celik', 'elif.celik.db06@securebank.test', 'customer', 'active', '2025-08-06'),
    (7, 'burak.aydin', 'Burak Aydin', 'burak.aydin.db06@securebank.test', 'customer', 'active', '2025-08-07'),
    (8, 'selin.koc', 'Selin Koc', 'selin.koc.db06@securebank.test', 'customer', 'active', '2025-08-08'),
    (9, 'deniz.sahin', 'Deniz Sahin', 'deniz.sahin.db06@securebank.test', 'support_staff', 'active', '2025-08-09'),
    (10, 'mert.kaplan', 'Mert Kaplan', 'mert.kaplan.db06@securebank.test', 'support_staff', 'active', '2025-08-10'),
    (11, 'ece.yildiz', 'Ece Yildiz', 'ece.yildiz.db06@securebank.test', 'analyst', 'active', '2025-08-11'),
    (12, 'murat.aslan', 'Murat Aslan', 'murat.aslan.db06@securebank.test', 'admin', 'active', '2025-08-12');

SELECT setval('public.app_users_id_seq', (SELECT MAX(id) FROM public.app_users));

INSERT INTO public.devices (id, user_id, device_name, device_type, os_name, trusted, registered_at) VALUES
    (1, 1, 'Ali Mobile', 'phone', 'Android', true, '2025-08-02'),
    (2, 1, 'Ali Laptop', 'laptop', 'Ubuntu', true, '2025-08-03'),
    (3, 2, 'Ayse Mobile', 'phone', 'iOS', true, '2025-08-04'),
    (4, 3, 'Mehmet Mobile', 'phone', 'Android', true, '2025-08-05'),
    (5, 3, 'Mehmet Old Laptop', 'laptop', 'Windows', false, '2025-08-06'),
    (6, 4, 'Zeynep Mobile', 'phone', 'iOS', true, '2025-08-07'),
    (7, 5, 'Can Laptop', 'laptop', 'macOS', true, '2025-08-08'),
    (8, 6, 'Elif Mobile', 'phone', 'Android', true, '2025-08-09'),
    (9, 7, 'Burak Mobile', 'phone', 'iOS', true, '2025-08-10'),
    (10, 8, 'Selin Tablet', 'tablet', 'Android', false, '2025-08-11'),
    (11, 9, 'Deniz Support Laptop', 'laptop', 'Windows', true, '2025-08-12'),
    (12, 9, 'Deniz Support Desktop', 'desktop', 'Windows', true, '2025-08-13'),
    (13, 10, 'Mert Support Laptop', 'laptop', 'Ubuntu', true, '2025-08-14'),
    (14, 11, 'Ece Analyst Workstation', 'desktop', 'Ubuntu', true, '2025-08-15'),
    (15, 12, 'Murat Admin Workstation', 'desktop', 'Windows', true, '2025-08-16');

SELECT setval('public.devices_id_seq', (SELECT MAX(id) FROM public.devices));

INSERT INTO public.ip_reputation (id, ip_address, country, reputation, note) VALUES
    (1, '192.168.40.10', 'TR', 'trusted', 'Internal office network'),
    (2, '192.168.40.11', 'TR', 'trusted', 'Internal VPN gateway'),
    (3, '192.168.40.12', 'TR', 'trusted', 'Support office network'),
    (4, '10.10.5.20', 'TR', 'trusted', 'Analyst secure workstation network'),
    (5, '203.0.113.10', 'TR', 'normal', 'Residential ISP example'),
    (6, '203.0.113.11', 'TR', 'normal', 'Mobile ISP example'),
    (7, '198.51.100.25', 'TR', 'normal', 'Home network example'),
    (8, '198.51.100.77', 'NL', 'suspicious', 'Unusual location for this workshop story'),
    (9, '203.0.113.200', 'DE', 'suspicious', 'Repeated failed auth attempts'),
    (10, '192.0.2.66', 'US', 'suspicious', 'Unrecognized proxy-like source'),
    (11, '198.51.100.88', 'GB', 'suspicious', 'Unusual support access location'),
    (12, '185.220.101.45', 'NL', 'malicious', 'Known-bad example IP for local lab timeline');

SELECT setval('public.ip_reputation_id_seq', (SELECT MAX(id) FROM public.ip_reputation));

INSERT INTO public.auth_logs (id, user_id, device_id, ip_address, event_type, success, failure_reason, created_at) VALUES
    (1, 1, 1, '203.0.113.10', 'login', true, NULL, '2025-11-01 08:00:00'),
    (2, 1, 1, '203.0.113.10', 'logout', true, NULL, '2025-11-01 08:45:00'),
    (3, 2, 3, '203.0.113.11', 'login', true, NULL, '2025-11-01 09:00:00'),
    (4, 2, 3, '203.0.113.11', 'logout', true, NULL, '2025-11-01 09:30:00'),
    (5, 3, 4, '198.51.100.25', 'login', true, NULL, '2025-11-01 10:00:00'),
    (6, 3, 4, '198.51.100.25', 'logout', true, NULL, '2025-11-01 10:40:00'),
    (7, 4, 6, '203.0.113.10', 'login', true, NULL, '2025-11-01 11:00:00'),
    (8, 4, 6, '203.0.113.10', 'logout', true, NULL, '2025-11-01 11:35:00'),
    (9, 5, 7, '203.0.113.11', 'login', true, NULL, '2025-11-01 12:00:00'),
    (10, 5, 7, '203.0.113.11', 'logout', true, NULL, '2025-11-01 12:30:00'),
    (11, 6, 8, '198.51.100.25', 'login', true, NULL, '2025-11-01 13:00:00'),
    (12, 6, 8, '198.51.100.25', 'logout', true, NULL, '2025-11-01 13:25:00'),
    (13, 7, 9, '203.0.113.10', 'login', true, NULL, '2025-11-01 14:00:00'),
    (14, 7, 9, '203.0.113.10', 'logout', true, NULL, '2025-11-01 14:20:00'),
    (15, 8, 10, '203.0.113.11', 'login', true, NULL, '2025-11-01 15:00:00'),
    (16, 8, 10, '203.0.113.11', 'logout', true, NULL, '2025-11-01 15:28:00'),
    (17, 9, 11, '192.168.40.12', 'login', true, NULL, '2025-11-01 16:00:00'),
    (18, 9, 11, '192.168.40.12', 'logout', true, NULL, '2025-11-01 16:45:00'),
    (19, 10, 13, '192.168.40.12', 'login', true, NULL, '2025-11-01 17:00:00'),
    (20, 10, 13, '192.168.40.12', 'logout', true, NULL, '2025-11-01 17:35:00'),
    (21, 11, 14, '10.10.5.20', 'login', true, NULL, '2025-11-02 08:00:00'),
    (22, 11, 14, '10.10.5.20', 'logout', true, NULL, '2025-11-02 08:50:00'),
    (23, 12, 15, '192.168.40.10', 'mfa_failed', false, 'wrong mfa code', '2025-11-02 09:00:00'),
    (24, 12, 15, '192.168.40.10', 'mfa_success', true, NULL, '2025-11-02 09:02:00'),
    (25, 12, 15, '192.168.40.10', 'login', true, NULL, '2025-11-02 09:03:00'),
    (26, 12, 15, '192.168.40.10', 'logout', true, NULL, '2025-11-02 09:45:00'),
    (27, 2, 3, '203.0.113.11', 'password_reset', true, NULL, '2025-11-02 10:00:00'),
    (28, 2, 3, '203.0.113.11', 'login', true, NULL, '2025-11-02 10:15:00'),
    (29, 1, 2, '203.0.113.10', 'mfa_failed', false, 'wrong mfa code', '2025-11-02 11:00:00'),
    (30, 1, 2, '203.0.113.10', 'mfa_success', true, NULL, '2025-11-02 11:02:00'),
    (31, 1, 2, '203.0.113.10', 'login', true, NULL, '2025-11-02 11:03:00'),
    (32, 3, NULL, '198.51.100.77', 'login', false, 'invalid password', '2025-11-03 01:10:00'),
    (33, 3, NULL, '203.0.113.200', 'login', false, 'invalid password', '2025-11-03 01:12:00'),
    (34, 3, NULL, '192.0.2.66', 'login', false, 'invalid password', '2025-11-03 01:15:00'),
    (35, 3, NULL, '185.220.101.45', 'login', false, 'invalid password', '2025-11-03 01:18:00'),
    (36, 3, NULL, '198.51.100.77', 'login', false, 'invalid password', '2025-11-03 01:20:00'),
    (37, 3, 5, '198.51.100.25', 'login', true, NULL, '2025-11-03 08:00:00'),
    (38, 9, NULL, '185.220.101.45', 'mfa_failed', false, 'unexpected mfa challenge', '2025-11-04 02:00:00'),
    (39, 9, NULL, '185.220.101.45', 'mfa_success', true, NULL, '2025-11-04 02:03:00'),
    (40, 9, NULL, '185.220.101.45', 'login', true, NULL, '2025-11-04 02:04:00'),
    (41, 9, NULL, '185.220.101.45', 'logout', true, NULL, '2025-11-04 02:30:00'),
    (42, 10, 13, '198.51.100.88', 'login', true, NULL, '2025-11-04 03:00:00'),
    (43, 10, 13, '198.51.100.88', 'logout', true, NULL, '2025-11-04 03:35:00'),
    (44, 11, 14, '10.10.5.20', 'login', true, NULL, '2025-11-04 09:00:00'),
    (45, 5, NULL, '203.0.113.200', 'login', false, 'unknown device', '2025-11-04 10:00:00'),
    (46, 6, NULL, '192.0.2.66', 'login', false, 'unknown device', '2025-11-04 10:05:00'),
    (47, 8, 10, '203.0.113.11', 'mfa_failed', false, 'wrong mfa code', '2025-11-04 11:00:00'),
    (48, 8, 10, '203.0.113.11', 'mfa_success', true, NULL, '2025-11-04 11:02:00'),
    (49, 8, 10, '203.0.113.11', 'login', true, NULL, '2025-11-04 11:03:00'),
    (50, 4, 6, '203.0.113.10', 'login', true, NULL, '2025-11-04 12:00:00');

SELECT setval('public.auth_logs_id_seq', (SELECT MAX(id) FROM public.auth_logs));

INSERT INTO public.query_activity_logs (id, user_id, ip_address, database_name, action_type, object_name, row_count, risk_level, created_at) VALUES
    (1, 1, '203.0.113.10', 'securebank', 'select_accounts', 'accounts', 2, 'low', '2025-11-01 08:05:00'),
    (2, 2, '203.0.113.11', 'securebank', 'select_profiles', 'customer_profiles', 1, 'low', '2025-11-01 09:05:00'),
    (3, 3, '198.51.100.25', 'securebank', 'select_accounts', 'accounts', 2, 'low', '2025-11-01 10:05:00'),
    (4, 4, '203.0.113.10', 'securebank', 'select_accounts', 'accounts', 1, 'low', '2025-11-01 11:05:00'),
    (5, 5, '203.0.113.11', 'securebank', 'select_profiles', 'customer_profiles', 1, 'low', '2025-11-01 12:05:00'),
    (6, 6, '198.51.100.25', 'securebank', 'select_accounts', 'accounts', 1, 'low', '2025-11-01 13:05:00'),
    (7, 7, '203.0.113.10', 'securebank', 'select_accounts', 'accounts', 1, 'low', '2025-11-01 14:05:00'),
    (8, 8, '203.0.113.11', 'securebank', 'select_profiles', 'customer_profiles', 1, 'low', '2025-11-01 15:05:00'),
    (9, 9, '192.168.40.12', 'securebank', 'select_profiles', 'customer_profiles', 25, 'medium', '2025-11-01 16:05:00'),
    (10, 10, '192.168.40.12', 'securebank', 'select_accounts', 'accounts', 20, 'medium', '2025-11-01 17:05:00'),
    (11, 11, '10.10.5.20', 'securebank', 'view_audit_logs', 'auth_logs', 50, 'medium', '2025-11-02 08:05:00'),
    (12, 12, '192.168.40.10', 'securebank', 'view_audit_logs', 'security_events', 15, 'medium', '2025-11-02 09:10:00'),
    (13, 2, '203.0.113.11', 'securebank', 'select_profiles', 'customer_profiles', 1, 'low', '2025-11-02 10:20:00'),
    (14, 1, '203.0.113.10', 'securebank', 'select_accounts', 'accounts', 2, 'low', '2025-11-02 11:10:00'),
    (15, 3, '198.51.100.25', 'securebank', 'select_accounts', 'accounts', 2, 'low', '2025-11-03 08:05:00'),
    (16, 9, '185.220.101.45', 'securebank', 'select_profiles', 'customer_profiles', 100, 'high', '2025-11-04 02:06:00'),
    (17, 9, '185.220.101.45', 'securebank', 'export_report', 'customer_profiles', 100, 'high', '2025-11-04 02:08:00'),
    (18, 9, '185.220.101.45', 'securebank', 'view_audit_logs', 'auth_logs', 50, 'high', '2025-11-04 02:12:00'),
    (19, 10, '198.51.100.88', 'securebank', 'select_accounts', 'accounts', 40, 'medium', '2025-11-04 03:05:00'),
    (20, 10, '198.51.100.88', 'securebank', 'failed_query', 'customer_profiles', 0, 'medium', '2025-11-04 03:08:00'),
    (21, 11, '10.10.5.20', 'securebank', 'view_audit_logs', 'query_activity_logs', 35, 'medium', '2025-11-04 09:05:00'),
    (22, 11, '10.10.5.20', 'securebank', 'export_report', 'security_summary', 15, 'high', '2025-11-04 09:15:00'),
    (23, 12, '192.168.40.10', 'securebank', 'select_profiles', 'app_users', 12, 'medium', '2025-11-04 09:20:00'),
    (24, 5, '203.0.113.200', 'securebank', 'failed_query', 'accounts', 0, 'high', '2025-11-04 10:02:00'),
    (25, 6, '192.0.2.66', 'securebank', 'failed_query', 'accounts', 0, 'high', '2025-11-04 10:07:00'),
    (26, 8, '203.0.113.11', 'securebank', 'select_accounts', 'accounts', 1, 'low', '2025-11-04 11:08:00'),
    (27, 4, '203.0.113.10', 'securebank', 'select_profiles', 'customer_profiles', 1, 'low', '2025-11-04 12:05:00'),
    (28, 9, '192.168.40.12', 'db04_access_control_lab', 'view_audit_logs', 'account_view_events', 28, 'medium', '2025-11-05 09:00:00'),
    (29, 10, '192.168.40.12', 'db04_access_control_lab', 'select_profiles', 'app_users', 10, 'low', '2025-11-05 09:10:00'),
    (30, 11, '10.10.5.20', 'db06_audit_forensics_lab', 'view_audit_logs', 'auth_logs', 50, 'medium', '2025-11-05 09:20:00'),
    (31, 11, '10.10.5.20', 'db06_audit_forensics_lab', 'select_profiles', 'ip_reputation', 12, 'low', '2025-11-05 09:25:00'),
    (32, 12, '192.168.40.10', 'db06_audit_forensics_lab', 'export_report', 'incident_notes', 5, 'medium', '2025-11-05 09:30:00'),
    (33, 3, '198.51.100.25', 'securebank', 'select_accounts', 'accounts', 2, 'low', '2025-11-05 10:00:00'),
    (34, 2, '203.0.113.11', 'securebank', 'failed_query', 'customer_profiles', 0, 'low', '2025-11-05 10:15:00'),
    (35, 1, '203.0.113.10', 'securebank', 'select_profiles', 'customer_profiles', 1, 'low', '2025-11-05 10:30:00');

SELECT setval('public.query_activity_logs_id_seq', (SELECT MAX(id) FROM public.query_activity_logs));

INSERT INTO public.security_events (id, event_name, severity, related_user_id, ip_address, description, created_at) VALUES
    (1, 'Daily login baseline', 'info', NULL, NULL, 'Normal login volume for the morning period.', '2025-11-01 18:00:00'),
    (2, 'Admin MFA retry', 'low', 12, '192.168.40.10', 'Admin user had one failed MFA attempt followed by success.', '2025-11-02 09:05:00'),
    (3, 'Customer MFA retry', 'low', 1, '203.0.113.10', 'Customer had one failed MFA attempt followed by success.', '2025-11-02 11:05:00'),
    (4, 'Failed login spike', 'medium', 3, '198.51.100.77', 'Multiple failed logins began for one customer account.', '2025-11-03 01:25:00'),
    (5, 'Failed login from suspicious IP', 'medium', 3, '203.0.113.200', 'Suspicious IP generated failed authentication.', '2025-11-03 01:26:00'),
    (6, 'Failed login from malicious IP', 'high', 3, '185.220.101.45', 'Malicious reputation IP attempted login for a customer account.', '2025-11-03 01:27:00'),
    (7, 'Customer recovered normal login', 'info', 3, '198.51.100.25', 'Customer later logged in from normal IP.', '2025-11-03 08:10:00'),
    (8, 'Support login from malicious IP', 'critical', 9, '185.220.101.45', 'Support staff account logged in successfully from malicious reputation IP.', '2025-11-04 02:05:00'),
    (9, 'High risk profile selection', 'high', 9, '185.220.101.45', 'Support account selected a large profile result set from unusual IP.', '2025-11-04 02:07:00'),
    (10, 'High risk export report', 'critical', 9, '185.220.101.45', 'Support account performed export_report from unusual IP.', '2025-11-04 02:09:00'),
    (11, 'Support query from suspicious IP', 'medium', 10, '198.51.100.88', 'Support staff accessed accounts from suspicious reputation IP.', '2025-11-04 03:10:00'),
    (12, 'Analyst export report', 'high', 11, '10.10.5.20', 'Internal analyst exported security summary for investigation.', '2025-11-04 09:16:00'),
    (13, 'Failed query from suspicious IP', 'high', 5, '203.0.113.200', 'Suspicious IP caused failed query activity.', '2025-11-04 10:03:00'),
    (14, 'Failed query from proxy-like source', 'high', 6, '192.0.2.66', 'Proxy-like suspicious IP caused failed query activity.', '2025-11-04 10:08:00'),
    (15, 'Investigation review opened', 'info', 11, '10.10.5.20', 'Analyst reviewed DB06 logs and incident notes.', '2025-11-05 09:35:00');

SELECT setval('public.security_events_id_seq', (SELECT MAX(id) FROM public.security_events));

INSERT INTO public.incident_notes (id, note_title, note_body, created_at) VALUES
    (1, 'Start with failed login counts', 'Use GROUP BY and HAVING to find users with unusual failed login volume.', '2025-11-05 08:00:00'),
    (2, 'Correlate IP reputation', 'Join auth_logs and query_activity_logs with ip_reputation to prioritize suspicious IPs.', '2025-11-05 08:05:00'),
    (3, 'Build timelines', 'Use UNION ALL to combine authentication and query activity for a single IP address.', '2025-11-05 08:10:00'),
    (4, 'Look for successful risky access', 'A successful login from a malicious IP is more urgent than failed attempts alone.', '2025-11-05 08:15:00'),
    (5, 'Review export actions', 'High-risk export_report actions should be reviewed with user, IP, and timestamp context.', '2025-11-05 08:20:00');

SELECT setval('public.incident_notes_id_seq', (SELECT MAX(id) FROM public.incident_notes));

-- db06_user is intentionally read-only for this defensive analysis lab.
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM PUBLIC;
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM db06_user;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO db06_user;

REVOKE ALL ON ALL SEQUENCES IN SCHEMA public FROM PUBLIC;
REVOKE ALL ON ALL SEQUENCES IN SCHEMA public FROM db06_user;

ALTER DEFAULT PRIVILEGES IN SCHEMA public REVOKE ALL ON TABLES FROM PUBLIC;
ALTER DEFAULT PRIVILEGES IN SCHEMA public REVOKE ALL ON SEQUENCES FROM PUBLIC;
