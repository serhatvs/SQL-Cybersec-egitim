    -- DB07 - AI SQL Workflow and Validation Lab
-- This database is for validating AI-generated SQL before using it.
-- Students should compare generated_sql and corrected_sql, then use the
-- validation_checklist as human review steps.

\connect db07_ai_sql_risk_lab

-- Public schema permissions are restricted before creating workshop objects.
REVOKE ALL ON SCHEMA public FROM PUBLIC;
GRANT USAGE ON SCHEMA public TO db07_user;

CREATE TABLE public.departments (
    id SERIAL PRIMARY KEY,
    department_name VARCHAR(100) UNIQUE NOT NULL,
    manager_employee_id INT
);

CREATE TABLE public.employees (
    id SERIAL PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(120) UNIQUE NOT NULL,
    department_id INT NOT NULL REFERENCES public.departments(id),
    role VARCHAR(50) NOT NULL,
    salary NUMERIC(12,2) NOT NULL,
    city VARCHAR(50) NOT NULL,
    status VARCHAR(20) DEFAULT 'active',
    hired_at DATE NOT NULL
);

CREATE TABLE public.projects (
    id SERIAL PRIMARY KEY,
    project_name VARCHAR(120) NOT NULL,
    department_id INT NOT NULL REFERENCES public.departments(id),
    budget NUMERIC(12,2) NOT NULL,
    status VARCHAR(30) DEFAULT 'active',
    started_at DATE NOT NULL
);

CREATE TABLE public.project_assignments (
    id SERIAL PRIMARY KEY,
    employee_id INT NOT NULL REFERENCES public.employees(id),
    project_id INT NOT NULL REFERENCES public.projects(id),
    assignment_role VARCHAR(60) NOT NULL,
    allocated_hours INT NOT NULL
);

CREATE TABLE public.expenses (
    id SERIAL PRIMARY KEY,
    employee_id INT NOT NULL REFERENCES public.employees(id),
    project_id INT REFERENCES public.projects(id),
    expense_type VARCHAR(50) NOT NULL,
    amount NUMERIC(12,2) NOT NULL,
    approved BOOLEAN DEFAULT false,
    created_at DATE NOT NULL
);

-- Natural-language prompts that students might give to an AI assistant.
CREATE TABLE public.ai_prompt_examples (
    id SERIAL PRIMARY KEY,
    prompt_text TEXT NOT NULL,
    intent_summary VARCHAR(180) NOT NULL,
    expected_tables VARCHAR(200) NOT NULL,
    difficulty VARCHAR(30) NOT NULL
);

-- Intentionally flawed AI-generated SQL examples and corrected versions.
-- These are static training examples, not executable attack code.
CREATE TABLE public.ai_generated_queries (
    id SERIAL PRIMARY KEY,
    prompt_id INT NOT NULL REFERENCES public.ai_prompt_examples(id),
    generated_sql TEXT NOT NULL,
    issue_type VARCHAR(60) NOT NULL,
    risk_level VARCHAR(30) NOT NULL,
    explanation TEXT NOT NULL,
    corrected_sql TEXT NOT NULL
);

-- Human-in-the-loop review checklist for AI-generated SQL.
CREATE TABLE public.validation_checklist (
    id SERIAL PRIMARY KEY,
    checklist_item VARCHAR(160) NOT NULL,
    category VARCHAR(60) NOT NULL,
    explanation TEXT NOT NULL
);

CREATE INDEX idx_db07_employees_department_id ON public.employees(department_id);
CREATE INDEX idx_db07_employees_status ON public.employees(status);
CREATE INDEX idx_db07_employees_city ON public.employees(city);
CREATE INDEX idx_db07_employees_role ON public.employees(role);
CREATE INDEX idx_db07_projects_department_id ON public.projects(department_id);
CREATE INDEX idx_db07_projects_status ON public.projects(status);
CREATE INDEX idx_db07_project_assignments_employee_id ON public.project_assignments(employee_id);
CREATE INDEX idx_db07_project_assignments_project_id ON public.project_assignments(project_id);
CREATE INDEX idx_db07_expenses_employee_id ON public.expenses(employee_id);
CREATE INDEX idx_db07_expenses_project_id ON public.expenses(project_id);
CREATE INDEX idx_db07_expenses_approved ON public.expenses(approved);
CREATE INDEX idx_db07_expenses_created_at ON public.expenses(created_at);
CREATE INDEX idx_db07_ai_generated_queries_issue_type ON public.ai_generated_queries(issue_type);
CREATE INDEX idx_db07_ai_generated_queries_risk_level ON public.ai_generated_queries(risk_level);

-- Tum veriler sahte demo verisidir; gercek sirket veya personel verisi icermez.
INSERT INTO public.departments (id, department_name, manager_employee_id) VALUES
    (1, 'Engineering', NULL),
    (2, 'Security', NULL),
    (3, 'Finance', NULL),
    (4, 'Operations', NULL),
    (5, 'Data', NULL);

SELECT setval('public.departments_id_seq', (SELECT MAX(id) FROM public.departments));

INSERT INTO public.employees (id, full_name, email, department_id, role, salary, city, status, hired_at) VALUES
    (1, 'Ali Yilmaz', 'ali.yilmaz.db07@securebank.test', 1, 'manager', 110000.00, 'Istanbul', 'active', '2021-02-01'),
    (2, 'Ayse Demir', 'ayse.demir.db07@securebank.test', 2, 'manager', 105000.00, 'Ankara', 'active', '2021-04-12'),
    (3, 'Mehmet Kaya', 'mehmet.kaya.db07@securebank.test', 1, 'software_engineer', 65000.00, 'Kayseri', 'active', '2022-01-10'),
    (4, 'Zeynep Arslan', 'zeynep.arslan.db07@securebank.test', 2, 'security_analyst', 72000.00, 'Izmir', 'active', '2022-03-18'),
    (5, 'Can Ozkan', 'can.ozkan.db07@securebank.test', 3, 'finance_specialist', 58000.00, 'Bursa', 'active', '2022-06-05'),
    (6, 'Elif Celik', 'elif.celik.db07@securebank.test', 5, 'data_analyst', 70000.00, 'Istanbul', 'active', '2022-08-22'),
    (7, 'Burak Aydin', 'burak.aydin.db07@securebank.test', 4, 'operations_specialist', 52000.00, 'Ankara', 'active', '2022-11-14'),
    (8, 'Selin Koc', 'selin.koc.db07@securebank.test', 1, 'software_engineer', 62000.00, 'Kayseri', 'active', '2023-01-09'),
    (9, 'Deniz Sahin', 'deniz.sahin.db07@securebank.test', 2, 'security_analyst', 76000.00, 'Izmir', 'active', '2023-02-20'),
    (10, 'Mert Kaplan', 'mert.kaplan.db07@securebank.test', 3, 'manager', 98000.00, 'Bursa', 'active', '2020-12-01'),
    (11, 'Ece Yildiz', 'ece.yildiz.db07@securebank.test', 5, 'data_analyst', 68000.00, 'Kayseri', 'active', '2023-04-03'),
    (12, 'Murat Aslan', 'murat.aslan.db07@securebank.test', 4, 'manager', 95000.00, 'Ankara', 'active', '2020-09-15'),
    (13, 'Nisa Korkmaz', 'nisa.korkmaz.db07@securebank.test', 4, 'operations_specialist', 48000.00, 'Istanbul', 'inactive', '2023-06-11'),
    (14, 'Ozan Polat', 'ozan.polat.db07@securebank.test', 5, 'manager', 102000.00, 'Izmir', 'active', '2021-07-19');

SELECT setval('public.employees_id_seq', (SELECT MAX(id) FROM public.employees));

UPDATE public.departments SET manager_employee_id = 1 WHERE id = 1;
UPDATE public.departments SET manager_employee_id = 2 WHERE id = 2;
UPDATE public.departments SET manager_employee_id = 10 WHERE id = 3;
UPDATE public.departments SET manager_employee_id = 12 WHERE id = 4;
UPDATE public.departments SET manager_employee_id = 14 WHERE id = 5;

ALTER TABLE public.departments
    ADD CONSTRAINT fk_departments_manager_employee
    FOREIGN KEY (manager_employee_id) REFERENCES public.employees(id);

INSERT INTO public.projects (id, project_name, department_id, budget, status, started_at) VALUES
    (1, 'Mobile Banking Refresh', 1, 900000.00, 'active', '2025-01-10'),
    (2, 'Fraud Signal Dashboard', 2, 650000.00, 'active', '2025-02-01'),
    (3, 'Quarterly Finance Automation', 3, 350000.00, 'completed', '2024-10-15'),
    (4, 'Branch Operations Portal', 4, 50000.00, 'paused', '2025-03-01'),
    (5, 'Data Quality Lake', 5, 1200000.00, 'active', '2025-01-20'),
    (6, 'Secure API Gateway', 1, 1500000.00, 'active', '2025-04-05'),
    (7, 'Access Review Program', 2, 420000.00, 'completed', '2024-11-18'),
    (8, 'Cost Forecast Model', 3, 250000.00, 'active', '2025-05-12');

SELECT setval('public.projects_id_seq', (SELECT MAX(id) FROM public.projects));

INSERT INTO public.project_assignments (id, employee_id, project_id, assignment_role, allocated_hours) VALUES
    (1, 1, 1, 'project_owner', 80),
    (2, 3, 1, 'backend_engineer', 160),
    (3, 8, 1, 'frontend_engineer', 140),
    (4, 6, 1, 'reporting_support', 60),
    (5, 2, 2, 'security_owner', 90),
    (6, 4, 2, 'detection_engineer', 160),
    (7, 9, 2, 'threat_modeler', 120),
    (8, 11, 2, 'data_support', 100),
    (9, 10, 3, 'finance_owner', 80),
    (10, 5, 3, 'finance_analyst', 140),
    (11, 6, 3, 'data_analyst', 90),
    (12, 12, 4, 'operations_owner', 80),
    (13, 7, 4, 'process_specialist', 150),
    (14, 13, 4, 'field_operations', 120),
    (15, 14, 5, 'data_owner', 90),
    (16, 6, 5, 'data_modeler', 170),
    (17, 11, 5, 'quality_analyst', 150),
    (18, 1, 6, 'engineering_owner', 90),
    (19, 3, 6, 'api_engineer', 180),
    (20, 8, 6, 'integration_engineer', 160),
    (21, 2, 7, 'security_owner', 70),
    (22, 4, 7, 'access_reviewer', 130),
    (23, 9, 7, 'audit_support', 100),
    (24, 10, 8, 'finance_owner', 80),
    (25, 5, 8, 'forecast_specialist', 150),
    (26, 11, 8, 'model_validator', 100),
    (27, 14, 5, 'governance_reviewer', 80),
    (28, 12, 6, 'operations_liaison', 60);

SELECT setval('public.project_assignments_id_seq', (SELECT MAX(id) FROM public.project_assignments));

INSERT INTO public.expenses (id, employee_id, project_id, expense_type, amount, approved, created_at) VALUES
    (1, 3, 1, 'software', 24000.00, true, '2025-05-01'),
    (2, 8, 1, 'hardware', 18000.00, true, '2025-05-03'),
    (3, 1, 1, 'travel', 6500.00, false, '2025-05-05'),
    (4, 4, 2, 'cloud', 42000.00, true, '2025-05-07'),
    (5, 9, 2, 'training', 12500.00, true, '2025-05-09'),
    (6, 2, 2, 'software', 30000.00, false, '2025-05-11'),
    (7, 5, 3, 'office', 5200.00, true, '2025-05-13'),
    (8, 10, 3, 'software', 19500.00, true, '2025-05-15'),
    (9, 6, 3, 'cloud', 28000.00, false, '2025-05-17'),
    (10, 7, 4, 'travel', 8800.00, true, '2025-05-19'),
    (11, 13, 4, 'hardware', 15200.00, false, '2025-05-21'),
    (12, 12, 4, 'office', 4600.00, true, '2025-05-23'),
    (13, 6, 5, 'cloud', 95000.00, true, '2025-06-01'),
    (14, 11, 5, 'software', 34000.00, true, '2025-06-03'),
    (15, 14, 5, 'training', 14800.00, false, '2025-06-05'),
    (16, 3, 6, 'cloud', 120000.00, true, '2025-06-07'),
    (17, 8, 6, 'software', 54000.00, true, '2025-06-09'),
    (18, 1, 6, 'hardware', 76000.00, false, '2025-06-11'),
    (19, 4, 7, 'software', 16500.00, true, '2025-06-13'),
    (20, 9, 7, 'training', 9200.00, true, '2025-06-15'),
    (21, 2, 7, 'travel', 7400.00, false, '2025-06-17'),
    (22, 5, 8, 'cloud', 31000.00, true, '2025-06-19'),
    (23, 11, 8, 'software', 18000.00, true, '2025-06-21'),
    (24, 10, 8, 'office', 3900.00, true, '2025-06-23'),
    (25, 6, NULL, 'training', 4500.00, false, '2025-06-25'),
    (26, 7, NULL, 'travel', 5200.00, true, '2025-06-27'),
    (27, 14, 5, 'cloud', 65000.00, true, '2025-07-01'),
    (28, 12, 4, 'software', 11000.00, false, '2025-07-03'),
    (29, 3, 6, 'training', 8700.00, true, '2025-07-05'),
    (30, 8, 1, 'office', 3200.00, true, '2025-07-07');

SELECT setval('public.expenses_id_seq', (SELECT MAX(id) FROM public.expenses));

INSERT INTO public.ai_prompt_examples (id, prompt_text, intent_summary, expected_tables, difficulty) VALUES
    (1, 'List active employees in Engineering with their department name.', 'Active Engineering employees with department context', 'employees, departments', 'beginner'),
    (2, 'Show active projects and their department names.', 'Active projects by department', 'projects, departments', 'beginner'),
    (3, 'Find unapproved expenses from June 2025.', 'Unapproved expense review', 'expenses, employees, projects', 'beginner'),
    (4, 'Show employees assigned to more than one project.', 'Multi-project employee workload', 'employees, project_assignments', 'intermediate'),
    (5, 'Show project names with total approved expenses.', 'Project expense aggregation', 'projects, expenses', 'intermediate'),
    (6, 'List Security department employees without exposing salary or email.', 'Security employee list with minimized columns', 'employees, departments', 'beginner'),
    (7, 'Show project assignments with employee and project names.', 'Assignment detail report', 'employees, projects, project_assignments', 'beginner'),
    (8, 'Summarize expenses by department.', 'Department-level expense summary', 'departments, projects, expenses', 'intermediate'),
    (9, 'Find active employees in Kayseri working on active projects.', 'Filtered active employee and project report', 'employees, projects, project_assignments', 'intermediate'),
    (10, 'Create a validation checklist for reviewing AI-generated SQL.', 'Human review steps for AI SQL', 'validation_checklist', 'beginner');

SELECT setval('public.ai_prompt_examples_id_seq', (SELECT MAX(id) FROM public.ai_prompt_examples));

INSERT INTO public.ai_generated_queries (id, prompt_id, generated_sql, issue_type, risk_level, explanation, corrected_sql) VALUES
    (1, 1, $sql$SELECT e.full_name, d.department_title
FROM employees e
JOIN departments d ON e.department_id = d.id
WHERE e.status = 'active';$sql$, 'hallucinated_column', 'medium', 'departments.department_title does not exist; the real column is department_name.', $sql$SELECT e.full_name, d.department_name
FROM employees e
JOIN departments d ON e.department_id = d.id
WHERE e.status = 'active'
  AND d.department_name = 'Engineering';$sql$),
    (2, 4, $sql$SELECT e.full_name, pa.total_hours
FROM employees e
JOIN project_assignments pa ON e.id = pa.employee_id;$sql$, 'hallucinated_column', 'medium', 'project_assignments.total_hours does not exist; allocated_hours is the real column.', $sql$SELECT e.full_name, SUM(pa.allocated_hours) AS total_allocated_hours
FROM employees e
JOIN project_assignments pa ON e.id = pa.employee_id
GROUP BY e.id, e.full_name
HAVING COUNT(pa.project_id) > 1;$sql$),
    (3, 2, $sql$SELECT p.project_name, d.department_name, p.status
FROM projects p
JOIN departments d ON p.department_id = d.id;$sql$, 'missing_where', 'low', 'The prompt asked for active projects, but the generated query forgot the status filter.', $sql$SELECT p.project_name, d.department_name, p.status
FROM projects p
JOIN departments d ON p.department_id = d.id
WHERE p.status = 'active';$sql$),
    (4, 3, $sql$SELECT ex.id, ex.amount, ex.approved, ex.created_at
FROM expenses ex
WHERE ex.created_at BETWEEN '2025-06-01' AND '2025-06-30';$sql$, 'missing_where', 'medium', 'The prompt asked for unapproved expenses, but the generated query does not filter approved = false.', $sql$SELECT ex.id, ex.amount, ex.approved, ex.created_at
FROM expenses ex
WHERE ex.approved = false
  AND ex.created_at BETWEEN '2025-06-01' AND '2025-06-30';$sql$),
    (5, 6, $sql$SELECT *
FROM employees e
JOIN departments d ON e.department_id = d.id
WHERE d.department_name = 'Security';$sql$, 'over_fetching', 'high', 'SELECT * returns unnecessary sensitive fields such as salary and email.', $sql$SELECT e.full_name, e.role, e.city, d.department_name
FROM employees e
JOIN departments d ON e.department_id = d.id
WHERE d.department_name = 'Security'
  AND e.status = 'active';$sql$),
    (6, 7, $sql$SELECT e.full_name, e.email, e.salary, p.project_name, pa.assignment_role
FROM employees e
JOIN project_assignments pa ON e.id = pa.employee_id
JOIN projects p ON pa.project_id = p.id;$sql$, 'sensitive_data_exposure', 'high', 'The prompt needs assignment context, not employee salary or email.', $sql$SELECT e.full_name, p.project_name, pa.assignment_role, pa.allocated_hours
FROM employees e
JOIN project_assignments pa ON e.id = pa.employee_id
JOIN projects p ON pa.project_id = p.id;$sql$),
    (7, 9, $sql$SELECT e.full_name, e.email, e.salary, e.city, p.project_name
FROM employees e
JOIN project_assignments pa ON e.id = pa.employee_id
JOIN projects p ON pa.project_id = p.id
WHERE e.city = 'Kayseri';$sql$, 'over_fetching', 'high', 'The query includes salary and email unnecessarily and also misses active filters.', $sql$SELECT e.full_name, e.city, p.project_name
FROM employees e
JOIN project_assignments pa ON e.id = pa.employee_id
JOIN projects p ON pa.project_id = p.id
WHERE e.city = 'Kayseri'
  AND e.status = 'active'
  AND p.status = 'active';$sql$),
    (8, 1, $sql$SELECT e.full_name, d.department_name
FROM employees e
JOIN departments d ON e.id = d.id;$sql$, 'wrong_join', 'high', 'employees should join departments through e.department_id = d.id, not e.id = d.id.', $sql$SELECT e.full_name, d.department_name
FROM employees e
JOIN departments d ON e.department_id = d.id
WHERE e.status = 'active';$sql$),
    (9, 8, $sql$SELECT d.department_name, SUM(ex.amount) AS total_expense
FROM departments d
JOIN expenses ex ON ex.project_id = d.id
GROUP BY d.department_name;$sql$, 'wrong_join', 'high', 'expenses relate to departments through projects; ex.project_id should join projects.id first.', $sql$SELECT d.department_name, SUM(ex.amount) AS total_expense
FROM departments d
JOIN projects p ON p.department_id = d.id
JOIN expenses ex ON ex.project_id = p.id
GROUP BY d.id, d.department_name
ORDER BY total_expense DESC;$sql$),
    (10, 5, $sql$SELECT p.project_name, ex.expense_type, SUM(ex.amount) AS total_amount
FROM projects p
JOIN expenses ex ON p.id = ex.project_id
WHERE ex.approved = true
GROUP BY p.project_name;$sql$, 'aggregation_error', 'medium', 'expense_type is selected but not grouped or aggregated, so the query is invalid.', $sql$SELECT p.project_name, SUM(ex.amount) AS total_amount
FROM projects p
JOIN expenses ex ON p.id = ex.project_id
WHERE ex.approved = true
GROUP BY p.id, p.project_name
ORDER BY total_amount DESC;$sql$),
    (11, 4, $sql$SELECT d.department_name, e.full_name, COUNT(pa.project_id) AS project_count
FROM departments d
JOIN employees e ON e.department_id = d.id
JOIN project_assignments pa ON pa.employee_id = e.id
GROUP BY d.department_name;$sql$, 'aggregation_error', 'medium', 'e.full_name is selected without being included in GROUP BY; the grouping level is unclear.', $sql$SELECT e.full_name, COUNT(pa.project_id) AS project_count
FROM employees e
JOIN project_assignments pa ON pa.employee_id = e.id
GROUP BY e.id, e.full_name
HAVING COUNT(pa.project_id) > 1
ORDER BY project_count DESC;$sql$),
    (12, 2, $sql$SELECT *
FROM projects p
WHERE p.id IN (
  SELECT project_id FROM project_assignments
);$sql$, 'inefficient_query', 'low', 'The query uses SELECT * and an unnecessary subquery for a simple active project list.', $sql$SELECT p.project_name, p.status, d.department_name
FROM projects p
JOIN departments d ON p.department_id = d.id
WHERE p.status = 'active'
ORDER BY p.project_name;$sql$),
    (13, 1, $sql$SELECT s.full_name, s.department_name
FROM staff s
WHERE s.status = 'active';$sql$, 'wrong_table', 'medium', 'The table staff does not exist; employee data is stored in employees and departments.', $sql$SELECT e.full_name, d.department_name
FROM employees e
JOIN departments d ON e.department_id = d.id
WHERE e.status = 'active';$sql$),
    (14, 6, $sql$SELECT e.full_name, e.email, e.salary, d.department_name
FROM employees e
JOIN departments d ON e.department_id = d.id
WHERE d.department_name = 'Security';$sql$, 'sensitive_data_exposure', 'high', 'The prompt explicitly asks not to expose salary or email, but the generated SQL includes both.', $sql$SELECT e.full_name, e.role, d.department_name
FROM employees e
JOIN departments d ON e.department_id = d.id
WHERE d.department_name = 'Security'
  AND e.status = 'active';$sql$);

SELECT setval('public.ai_generated_queries_id_seq', (SELECT MAX(id) FROM public.ai_generated_queries));

INSERT INTO public.validation_checklist (id, checklist_item, category, explanation) VALUES
    (1, 'Confirm every referenced table exists', 'schema_check', 'AI may invent table names that sound plausible but are not in the schema.'),
    (2, 'Confirm every referenced column exists', 'schema_check', 'Check generated column names against the real schema before running the query.'),
    (3, 'Verify the JOIN path uses foreign-key relationships', 'logic_check', 'Wrong joins can silently return misleading results.'),
    (4, 'Check required WHERE filters are present', 'logic_check', 'Prompts often imply filters such as active, unapproved, city, or date range.'),
    (5, 'Avoid SELECT star for review queries', 'data_minimization', 'Return only the columns needed for the task.'),
    (6, 'Do not fetch salary or email unless needed', 'data_minimization', 'Sensitive fields require a clear business need.'),
    (7, 'Check GROUP BY level matches the question', 'business_context', 'Aggregation must match the entity being summarized.'),
    (8, 'Look for avoidable subqueries or cross joins', 'performance', 'Unnecessary query complexity can slow reviews and confuse students.'),
    (9, 'Limit result sets for exploratory queries', 'performance', 'Use LIMIT or filters when browsing unknown data.'),
    (10, 'Confirm the query matches the business intent', 'business_context', 'A syntactically valid query can still answer the wrong question.'),
    (11, 'Review sensitive fields before sharing results', 'security', 'AI-generated SQL may over-fetch data that should not be shown.'),
    (12, 'Keep a human approval step before production use', 'security', 'AI output should be reviewed, tested, and approved by a responsible person.');

SELECT setval('public.validation_checklist_id_seq', (SELECT MAX(id) FROM public.validation_checklist));

-- db07_user is intentionally read-only for this AI SQL validation lab.
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM PUBLIC;
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM db07_user;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO db07_user;

REVOKE ALL ON ALL SEQUENCES IN SCHEMA public FROM PUBLIC;
REVOKE ALL ON ALL SEQUENCES IN SCHEMA public FROM db07_user;

ALTER DEFAULT PRIVILEGES IN SCHEMA public REVOKE ALL ON TABLES FROM PUBLIC;
ALTER DEFAULT PRIVILEGES IN SCHEMA public REVOKE ALL ON SEQUENCES FROM PUBLIC;
