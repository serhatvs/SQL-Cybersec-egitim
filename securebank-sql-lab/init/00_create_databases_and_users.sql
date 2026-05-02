-- SecureBank SQL Lab - database and role bootstrap
-- This file runs once when the PostgreSQL data volume is created.

-- DB01 is a beginner-only SQL practice database.
CREATE ROLE db01_user LOGIN PASSWORD 'db01pass123';
CREATE DATABASE db01_sql_basics OWNER admin;

-- DB02 teaches relational thinking and beginner JOIN practice.
CREATE ROLE db02_user LOGIN PASSWORD 'db02pass123';
CREATE DATABASE db02_relations_joins OWNER admin;

-- DB03 teaches banking analytics queries over related tables.
CREATE ROLE db03_user LOGIN PASSWORD 'db03pass123';
CREATE DATABASE db03_banking_queries OWNER admin;

-- DB04 teaches Broken Access Control and authorization checks.
CREATE ROLE db04_user LOGIN PASSWORD 'db04pass123';
CREATE DATABASE db04_access_control_lab OWNER admin;

-- DB05 teaches safe, defensive SQL Injection concepts in a local lab.
CREATE ROLE db05_user LOGIN PASSWORD 'db05pass123';
CREATE DATABASE db05_sql_injection_lab OWNER admin;

-- DB06 teaches defensive audit-log and forensics analysis.
CREATE ROLE db06_user LOGIN PASSWORD 'db06pass123';
CREATE DATABASE db06_audit_forensics_lab OWNER admin;

-- DB07 teaches safe human validation of AI-generated SQL.
CREATE ROLE db07_user LOGIN PASSWORD 'db07pass123';
CREATE DATABASE db07_ai_sql_risk_lab OWNER admin;

-- DB08 is the final Red vs Blue workshop challenge.
CREATE ROLE db08_red_user LOGIN PASSWORD 'db08redpass123';
CREATE ROLE db08_blue_user LOGIN PASSWORD 'db08bluepass123';
CREATE DATABASE db08_red_vs_blue_final OWNER admin;

-- Keep PUBLIC access narrow so lab users can connect only where intended.
REVOKE CONNECT ON DATABASE securebank FROM PUBLIC;
GRANT CONNECT ON DATABASE securebank TO admin;

REVOKE CONNECT ON DATABASE postgres FROM PUBLIC;
GRANT CONNECT ON DATABASE postgres TO admin;

REVOKE CONNECT ON DATABASE template1 FROM PUBLIC;
GRANT CONNECT ON DATABASE template1 TO admin;

REVOKE ALL ON DATABASE db01_sql_basics FROM PUBLIC;
GRANT CONNECT ON DATABASE db01_sql_basics TO db01_user;
GRANT CONNECT ON DATABASE db01_sql_basics TO admin;

REVOKE ALL ON DATABASE db02_relations_joins FROM PUBLIC;
GRANT CONNECT ON DATABASE db02_relations_joins TO db02_user;
GRANT CONNECT ON DATABASE db02_relations_joins TO admin;

REVOKE ALL ON DATABASE db03_banking_queries FROM PUBLIC;
GRANT CONNECT ON DATABASE db03_banking_queries TO db03_user;
GRANT CONNECT ON DATABASE db03_banking_queries TO admin;

REVOKE ALL ON DATABASE db04_access_control_lab FROM PUBLIC;
GRANT CONNECT ON DATABASE db04_access_control_lab TO db04_user;
GRANT CONNECT ON DATABASE db04_access_control_lab TO admin;

REVOKE ALL ON DATABASE db05_sql_injection_lab FROM PUBLIC;
GRANT CONNECT ON DATABASE db05_sql_injection_lab TO db05_user;
GRANT CONNECT ON DATABASE db05_sql_injection_lab TO admin;

REVOKE ALL ON DATABASE db06_audit_forensics_lab FROM PUBLIC;
GRANT CONNECT ON DATABASE db06_audit_forensics_lab TO db06_user;
GRANT CONNECT ON DATABASE db06_audit_forensics_lab TO admin;

REVOKE ALL ON DATABASE db07_ai_sql_risk_lab FROM PUBLIC;
GRANT CONNECT ON DATABASE db07_ai_sql_risk_lab TO db07_user;
GRANT CONNECT ON DATABASE db07_ai_sql_risk_lab TO admin;

REVOKE ALL ON DATABASE db08_red_vs_blue_final FROM PUBLIC;
GRANT CONNECT ON DATABASE db08_red_vs_blue_final TO db08_red_user;
GRANT CONNECT ON DATABASE db08_red_vs_blue_final TO db08_blue_user;
GRANT CONNECT ON DATABASE db08_red_vs_blue_final TO admin;
