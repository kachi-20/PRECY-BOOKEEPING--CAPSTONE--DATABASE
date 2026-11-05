-- Precy Bookkeeping Database
-- Based on the supplied ERD image.
-- Target: MySQL 8.0 / contemporary XAMPP MariaDB (InnoDB, utf8mb4).
-- Import this file in phpMyAdmin. It creates the database and includes fictional test data.
-- This script does not DROP an existing database or tables.

CREATE DATABASE IF NOT EXISTS precy_bookkeeping_db
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE precy_bookkeeping_db;
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE users_accounts (
  user_id INT NOT NULL AUTO_INCREMENT,
  username VARCHAR(100) NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  role ENUM('admin','staff','client') NOT NULL DEFAULT 'client',
  status VARCHAR(30) NOT NULL DEFAULT 'Active',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (user_id),
  UNIQUE KEY uq_users_accounts_username (username),
  CONSTRAINT chk_users_accounts_status CHECK (status IN ('Active','Inactive'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE employees_staff (
  employee_id INT NOT NULL AUTO_INCREMENT,
  user_id INT NOT NULL,
  first_name VARCHAR(150) NOT NULL,
  middle_name VARCHAR(150) NULL,
  last_name VARCHAR(150) NOT NULL,
  contact_no VARCHAR(30) NULL,
  position VARCHAR(100) NULL,
  PRIMARY KEY (employee_id),
  KEY idx_employees_staff_user_id (user_id),
  CONSTRAINT fk_employees_staff_user
    FOREIGN KEY (user_id) REFERENCES users_accounts(user_id)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE clients (
  client_id INT NOT NULL AUTO_INCREMENT,
  user_id INT NULL,
  firstname VARCHAR(150) NOT NULL,
  middle_name VARCHAR(150) NULL,
  last_name VARCHAR(150) NOT NULL,
  contact_no VARCHAR(30) NULL,
  email VARCHAR(150) NULL,
  address TEXT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (client_id),
  KEY idx_clients_user_id (user_id),
  CONSTRAINT fk_clients_user
    FOREIGN KEY (user_id) REFERENCES users_accounts(user_id)
    ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE services (
  service_id INT NOT NULL AUTO_INCREMENT,
  service_name VARCHAR(150) NOT NULL,
  description TEXT NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'Active',
  PRIMARY KEY (service_id),
  CONSTRAINT chk_services_status CHECK (status IN ('Active','Inactive'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE document_requirements (
  requirement_id INT NOT NULL AUTO_INCREMENT,
  service_id INT NOT NULL,
  requirement_name VARCHAR(150) NOT NULL,
  description TEXT NULL,
  is_required BOOLEAN NOT NULL DEFAULT TRUE,
  PRIMARY KEY (requirement_id),
  KEY idx_document_requirements_service_id (service_id),
  CONSTRAINT fk_document_requirements_service
    FOREIGN KEY (service_id) REFERENCES services(service_id)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE booking_records (
  booking_id INT NOT NULL AUTO_INCREMENT,
  client_id INT NOT NULL,
  period_start DATE NOT NULL,
  period_end DATE NOT NULL,
  notes TEXT NULL,
  PRIMARY KEY (booking_id),
  KEY idx_booking_records_client_id (client_id),
  CONSTRAINT chk_booking_records_period CHECK (period_end >= period_start),
  CONSTRAINT fk_booking_records_client
    FOREIGN KEY (client_id) REFERENCES clients(client_id)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE service_requests (
  request_id INT NOT NULL AUTO_INCREMENT,
  client_id INT NOT NULL,
  service_id INT NOT NULL,
  assigned_employee_id INT NULL,
  request_date DATE NOT NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'Pending',
  notes TEXT NULL,
  PRIMARY KEY (request_id),
  KEY idx_service_requests_client_id (client_id),
  KEY idx_service_requests_service_id (service_id),
  KEY idx_service_requests_employee_id (assigned_employee_id),
  KEY idx_service_requests_status (status),
  CONSTRAINT chk_service_requests_status CHECK (status IN ('Pending','Being Processed','On-Hold','Completed')),
  CONSTRAINT fk_service_requests_client
    FOREIGN KEY (client_id) REFERENCES clients(client_id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_service_requests_service
    FOREIGN KEY (service_id) REFERENCES services(service_id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_service_requests_employee
    FOREIGN KEY (assigned_employee_id) REFERENCES employees_staff(employee_id)
    ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE documents (
  document_id INT NOT NULL AUTO_INCREMENT,
  client_id INT NOT NULL,
  requirement_id INT NULL,
  request_id INT NULL,
  file_name VARCHAR(255) NOT NULL,
  file_path TEXT NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'Pending',
  submitted_at DATETIME NULL,
  PRIMARY KEY (document_id),
  KEY idx_documents_client_id (client_id),
  KEY idx_documents_requirement_id (requirement_id),
  KEY idx_documents_request_id (request_id),
  CONSTRAINT chk_documents_status CHECK (status IN ('Pending','Submitted','Under Review','Complete','Missing/Incomplete')),
  CONSTRAINT fk_documents_client
    FOREIGN KEY (client_id) REFERENCES clients(client_id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_documents_requirement
    FOREIGN KEY (requirement_id) REFERENCES document_requirements(requirement_id)
    ON UPDATE CASCADE ON DELETE SET NULL,
  CONSTRAINT fk_documents_request
    FOREIGN KEY (request_id) REFERENCES service_requests(request_id)
    ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE service_tracking (
  tracking_id INT NOT NULL AUTO_INCREMENT,
  request_id INT NOT NULL,
  updated_by_user_id INT NOT NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'Pending',
  progress_note TEXT NULL,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (tracking_id),
  KEY idx_service_tracking_request_id (request_id),
  KEY idx_service_tracking_updated_by_user_id (updated_by_user_id),
  CONSTRAINT chk_service_tracking_status CHECK (status IN ('Pending','Being Processed','On-Hold','Completed')),
  CONSTRAINT fk_service_tracking_request
    FOREIGN KEY (request_id) REFERENCES service_requests(request_id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_service_tracking_user
    FOREIGN KEY (updated_by_user_id) REFERENCES users_accounts(user_id)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE deadlines (
  deadline_id INT NOT NULL AUTO_INCREMENT,
  request_id INT NOT NULL,
  deadline_date DATE NOT NULL,
  description TEXT NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'Pending',
  PRIMARY KEY (deadline_id),
  KEY idx_deadlines_request_id (request_id),
  KEY idx_deadlines_date_status (deadline_date, status),
  CONSTRAINT chk_deadlines_status CHECK (status IN ('Pending','Approaching','Completed On Time','Overdue')),
  CONSTRAINT fk_deadlines_request
    FOREIGN KEY (request_id) REFERENCES service_requests(request_id)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE notifications (
  notification_id INT NOT NULL AUTO_INCREMENT,
  user_id INT NOT NULL,
  request_id INT NULL,
  notification_type VARCHAR(50) NOT NULL,
  message TEXT NOT NULL,
  is_read BOOLEAN NOT NULL DEFAULT FALSE,
  sent_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (notification_id),
  KEY idx_notifications_user_read (user_id, is_read),
  KEY idx_notifications_request_id (request_id),
  CONSTRAINT fk_notifications_user
    FOREIGN KEY (user_id) REFERENCES users_accounts(user_id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_notifications_request
    FOREIGN KEY (request_id) REFERENCES service_requests(request_id)
    ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE income (
  income_id INT NOT NULL AUTO_INCREMENT,
  booking_id INT NOT NULL,
  income_date DATE NOT NULL,
  description TEXT NULL,
  amount DECIMAL(12,2) NOT NULL,
  PRIMARY KEY (income_id),
  KEY idx_income_booking_id (booking_id),
  CONSTRAINT chk_income_amount CHECK (amount >= 0),
  CONSTRAINT fk_income_booking
    FOREIGN KEY (booking_id) REFERENCES booking_records(booking_id)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE expenses (
  expense_id INT NOT NULL AUTO_INCREMENT,
  booking_id INT NOT NULL,
  expense_date DATE NOT NULL,
  description TEXT NULL,
  amount DECIMAL(12,2) NOT NULL,
  PRIMARY KEY (expense_id),
  KEY idx_expenses_booking_id (booking_id),
  CONSTRAINT chk_expenses_amount CHECK (amount >= 0),
  CONSTRAINT fk_expenses_booking
    FOREIGN KEY (booking_id) REFERENCES booking_records(booking_id)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE transactions (
  transaction_id INT NOT NULL AUTO_INCREMENT,
  client_id INT NOT NULL,
  booking_id INT NULL,
  transaction_date DATE NOT NULL,
  transaction_type VARCHAR(50) NOT NULL,
  description TEXT NULL,
  amount DECIMAL(12,2) NOT NULL,
  PRIMARY KEY (transaction_id),
  KEY idx_transactions_client_id (client_id),
  KEY idx_transactions_booking_id (booking_id),
  KEY idx_transactions_date (transaction_date),
  CONSTRAINT chk_transactions_amount CHECK (amount >= 0),
  CONSTRAINT fk_transactions_client
    FOREIGN KEY (client_id) REFERENCES clients(client_id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_transactions_booking
    FOREIGN KEY (booking_id) REFERENCES booking_records(booking_id)
    ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE payments (
  payment_id INT NOT NULL AUTO_INCREMENT,
  client_id INT NOT NULL,
  request_id INT NULL,
  transaction_id INT NULL,
  payment_date DATE NOT NULL,
  amount DECIMAL(12,2) NOT NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'Pending',
  balance DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  PRIMARY KEY (payment_id),
  KEY idx_payments_client_id (client_id),
  KEY idx_payments_request_id (request_id),
  UNIQUE KEY uq_payments_transaction_id (transaction_id),
  CONSTRAINT chk_payments_status CHECK (status IN ('Pending','Partially Paid','Paid')),
  CONSTRAINT chk_payments_amount CHECK (amount >= 0),
  CONSTRAINT chk_payments_balance CHECK (balance >= 0),
  CONSTRAINT fk_payments_client
    FOREIGN KEY (client_id) REFERENCES clients(client_id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_payments_request
    FOREIGN KEY (request_id) REFERENCES service_requests(request_id)
    ON UPDATE CASCADE ON DELETE SET NULL,
  CONSTRAINT fk_payments_transaction
    FOREIGN KEY (transaction_id) REFERENCES transactions(transaction_id)
    ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Fictional sample data. Password hashes are illustrative placeholders, not usable login credentials.
INSERT INTO users_accounts (user_id, username, password_hash, role, status, created_at) VALUES
(1, 'admin_demo', '$2y$10$example_hash_replace_before_use', 'admin', 'Active', '2026-01-05 09:00:00'),
(2, 'staff_demo', '$2y$10$example_hash_replace_before_use', 'staff', 'Active', '2026-01-06 09:00:00'),
(3, 'client_demo', '$2y$10$example_hash_replace_before_use', 'client', 'Active', '2026-01-07 09:00:00');

INSERT INTO employees_staff (employee_id, user_id, first_name, middle_name, last_name, contact_no, position) VALUES
(1, 2, 'Alex', 'R', 'Santos', '09000000001', 'Service Officer');

INSERT INTO clients (client_id, user_id, firstname, middle_name, last_name, contact_no, email, address, created_at) VALUES
(1, 3, 'Jamie', 'L', 'Reyes', '09000000002', 'jamie.reyes@example.test', 'Fictional Sample Address', '2026-01-07 10:00:00'),
(2, NULL, 'Taylor', NULL, 'Dela Cruz', '09000000003', 'taylor@example.test', 'Another Fictional Address', '2026-01-08 10:00:00');

INSERT INTO services (service_id, service_name, description, status) VALUES
(1, 'Business Permit Assistance', 'Assistance with business permit documentation.', 'Active'),
(2, 'Document Certification', 'Review and certification support.', 'Active');

INSERT INTO document_requirements (requirement_id, service_id, requirement_name, description, is_required) VALUES
(1, 1, 'Valid Identification', 'A valid government-issued identification document.', TRUE),
(2, 1, 'Application Form', 'Completed application form.', TRUE),
(3, 2, 'Supporting Document', 'Document requiring certification.', FALSE);

INSERT INTO booking_records (booking_id, client_id, period_start, period_end, notes) VALUES
(1, 1, '2026-01-10', '2026-01-31', 'Fictional sample booking period');

INSERT INTO service_requests (request_id, client_id, service_id, assigned_employee_id, request_date, status, notes) VALUES
(1, 1, 1, 1, '2026-01-10', 'Being Processed', 'Sample request for testing.'),
(2, 2, 2, NULL, '2026-01-12', 'Pending', 'Unassigned sample request.');

INSERT INTO documents (document_id, client_id, requirement_id, request_id, file_name, file_path, status, submitted_at) VALUES
(1, 1, 1, 1, 'sample-id.pdf', 'uploads/sample-id.pdf', 'Submitted', '2026-01-10 11:00:00'),
(2, 1, 2, 1, 'sample-application.pdf', 'uploads/sample-application.pdf', 'Under Review', '2026-01-10 11:05:00');

INSERT INTO service_tracking (tracking_id, request_id, updated_by_user_id, status, progress_note, updated_at) VALUES
(1, 1, 2, 'Being Processed', 'Initial review started.', '2026-01-11 09:30:00'),
(2, 2, 1, 'Pending', 'Request received.', '2026-01-12 10:00:00');

INSERT INTO deadlines (deadline_id, request_id, deadline_date, description, status) VALUES
(1, 1, '2026-02-05', 'Submit completed application package.', 'Approaching'),
(2, 2, '2026-01-20', 'Provide supporting documents.', 'Overdue');

INSERT INTO notifications (notification_id, user_id, request_id, notification_type, message, is_read, sent_at) VALUES
(1, 3, 1, 'Request Update', 'Your request is being processed.', FALSE, '2026-01-11 09:35:00'),
(2, 2, 2, 'New Request', 'A new service request needs assignment.', TRUE, '2026-01-12 10:05:00');

INSERT INTO income (income_id, booking_id, income_date, description, amount) VALUES
(1, 1, '2026-01-15', 'Service booking income', 1500.00);

INSERT INTO expenses (expense_id, booking_id, expense_date, description, amount) VALUES
(1, 1, '2026-01-16', 'Printing and administrative supplies', 250.00);

INSERT INTO transactions (transaction_id, client_id, booking_id, transaction_date, transaction_type, description, amount) VALUES
(1, 1, 1, '2026-01-15', 'Payment', 'Client payment for service booking', 1000.00);

INSERT INTO payments (payment_id, client_id, request_id, transaction_id, payment_date, amount, status, balance) VALUES
(1, 1, 1, 1, '2026-01-15', 1000.00, 'Partially Paid', 500.00);
