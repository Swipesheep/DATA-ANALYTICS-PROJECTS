-- ============================================================
--        BLOOD BANK MANAGEMENT SYSTEM
-- ============================================================
-- ============================================================
-- SECTION 1: DATABASE SCHEMA (CREATE TABLES)
-- ============================================================

CREATE DATABASE IF NOT EXISTS BloodBankDB;
USE BloodBankDB;

-- Blood Types reference table
CREATE TABLE BloodTypes (
    blood_type_id          INT PRIMARY KEY AUTO_INCREMENT,
    blood_group            VARCHAR(5)  NOT NULL UNIQUE,
    is_universal_donor     BOOLEAN     DEFAULT FALSE,
    is_universal_recipient BOOLEAN     DEFAULT FALSE
);

-- Hospitals
CREATE TABLE Hospitals (
    hospital_id     INT PRIMARY KEY AUTO_INCREMENT,
    hospital_name   VARCHAR(150) NOT NULL,
    address         VARCHAR(255),
    city            VARCHAR(100),
    contact_number  VARCHAR(20),
    email           VARCHAR(100),
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Donors
CREATE TABLE Donors (
    donor_id        INT PRIMARY KEY AUTO_INCREMENT,
    first_name      VARCHAR(80)  NOT NULL,
    last_name       VARCHAR(80)  NOT NULL,
    date_of_birth   DATE         NOT NULL,
    gender          ENUM('Male','Female','Other') NOT NULL,
    blood_type_id   INT          NOT NULL,
    phone           VARCHAR(20),
    email           VARCHAR(100),
    address         VARCHAR(255),
    city            VARCHAR(100),
    weight_kg       DECIMAL(5,2),
    is_active       BOOLEAN      DEFAULT TRUE,
    registered_at   TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (blood_type_id) REFERENCES BloodTypes(blood_type_id)
);

-- Donor Health Screening
CREATE TABLE DonorHealthScreening (
    screening_id        INT PRIMARY KEY AUTO_INCREMENT,
    donor_id            INT          NOT NULL,
    screening_date      DATE         NOT NULL,
    hemoglobin_level    DECIMAL(4,1),
    blood_pressure_sys  INT,
    blood_pressure_dia  INT,
    pulse_rate          INT,
    temperature_f       DECIMAL(4,1),
    has_hiv             BOOLEAN      DEFAULT FALSE,
    has_hepatitis_b     BOOLEAN      DEFAULT FALSE,
    has_hepatitis_c     BOOLEAN      DEFAULT FALSE,
    has_syphilis        BOOLEAN      DEFAULT FALSE,
    has_malaria         BOOLEAN      DEFAULT FALSE,
    is_eligible         BOOLEAN      DEFAULT TRUE,
    notes               TEXT,
    screened_by         VARCHAR(100),
    FOREIGN KEY (donor_id) REFERENCES Donors(donor_id)
);

-- Donation Records
CREATE TABLE Donations (
    donation_id     INT PRIMARY KEY AUTO_INCREMENT,
    donor_id        INT          NOT NULL,
    screening_id    INT          NOT NULL,
    donation_date   DATE         NOT NULL,
    units_donated   DECIMAL(4,2) DEFAULT 1.00,
    donation_type   ENUM('Whole Blood','Plasma','Platelets','Red Cells') DEFAULT 'Whole Blood',
    collected_by    VARCHAR(100),
    FOREIGN KEY (donor_id)     REFERENCES Donors(donor_id),
    FOREIGN KEY (screening_id) REFERENCES DonorHealthScreening(screening_id)
);

-- Blood Inventory
CREATE TABLE BloodInventory (
    inventory_id         INT PRIMARY KEY AUTO_INCREMENT,
    donation_id          INT          NOT NULL UNIQUE,
    blood_type_id        INT          NOT NULL,
    donation_type        ENUM('Whole Blood','Plasma','Platelets','Red Cells'),
    units_available      DECIMAL(4,2) NOT NULL,
    collection_date      DATE         NOT NULL,
    expiry_date          DATE         NOT NULL,
    storage_location     VARCHAR(100),
    is_contaminated      BOOLEAN      DEFAULT FALSE,
    contamination_reason VARCHAR(255),
    status               ENUM('Available','Reserved','Used','Expired','Discarded') DEFAULT 'Available',
    FOREIGN KEY (donation_id)   REFERENCES Donations(donation_id),
    FOREIGN KEY (blood_type_id) REFERENCES BloodTypes(blood_type_id)
);

-- Recipients / Patients
CREATE TABLE Recipients (
    recipient_id      INT PRIMARY KEY AUTO_INCREMENT,
    first_name        VARCHAR(80)  NOT NULL,
    last_name         VARCHAR(80)  NOT NULL,
    date_of_birth     DATE         NOT NULL,
    gender            ENUM('Male','Female','Other') NOT NULL,
    blood_type_id     INT          NOT NULL,
    phone             VARCHAR(20),
    address           VARCHAR(255),
    city              VARCHAR(100),
    hospital_id       INT,
    medical_condition VARCHAR(255),
    registered_at     TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (blood_type_id) REFERENCES BloodTypes(blood_type_id),
    FOREIGN KEY (hospital_id)   REFERENCES Hospitals(hospital_id)
);

-- Blood Requests
CREATE TABLE BloodRequests (
    request_id       INT PRIMARY KEY AUTO_INCREMENT,
    recipient_id     INT,
    hospital_id      INT          NOT NULL,
    blood_type_id    INT          NOT NULL,
    donation_type    ENUM('Whole Blood','Plasma','Platelets','Red Cells') DEFAULT 'Whole Blood',
    units_requested  DECIMAL(4,2) NOT NULL,
    urgency          ENUM('Critical','High','Medium','Low') DEFAULT 'Medium',
    request_date     DATE         NOT NULL,
    required_by_date DATE,
    status           ENUM('Pending','Approved','Fulfilled','Rejected','Cancelled') DEFAULT 'Pending',
    approved_by      VARCHAR(100),
    notes            TEXT,
    FOREIGN KEY (recipient_id) REFERENCES Recipients(recipient_id),
    FOREIGN KEY (hospital_id)  REFERENCES Hospitals(hospital_id),
    FOREIGN KEY (blood_type_id) REFERENCES BloodTypes(blood_type_id)
);

-- Blood Transfusions
CREATE TABLE Transfusions (
    transfusion_id   INT PRIMARY KEY AUTO_INCREMENT,
    request_id       INT          NOT NULL,
    inventory_id     INT          NOT NULL,
    recipient_id     INT          NOT NULL,
    hospital_id      INT          NOT NULL,
    transfusion_date DATE         NOT NULL,
    units_transfused DECIMAL(4,2) NOT NULL,
    administered_by  VARCHAR(100),
    outcome          ENUM('Successful','Adverse Reaction','Pending') DEFAULT 'Pending',
    notes            TEXT,
    FOREIGN KEY (request_id)   REFERENCES BloodRequests(request_id),
    FOREIGN KEY (inventory_id) REFERENCES BloodInventory(inventory_id),
    FOREIGN KEY (recipient_id) REFERENCES Recipients(recipient_id),
    FOREIGN KEY (hospital_id)  REFERENCES Hospitals(hospital_id)
);

-- Staff
CREATE TABLE Staff (
    staff_id  INT PRIMARY KEY AUTO_INCREMENT,
    full_name VARCHAR(150) NOT NULL,
    role      ENUM('Doctor','Nurse','Lab Technician','Admin','Phlebotomist') NOT NULL,
    phone     VARCHAR(20),
    email     VARCHAR(100),
    hire_date DATE
);


-- ============================================================
-- SECTION 2: SAMPLE DATA
-- ============================================================

-- Blood Types
INSERT INTO BloodTypes (blood_group, is_universal_donor, is_universal_recipient) VALUES
('A+',  FALSE, FALSE),
('A-',  FALSE, FALSE),
('B+',  FALSE, FALSE),
('B-',  FALSE, FALSE),
('AB+', FALSE, TRUE),
('AB-', FALSE, FALSE),
('O+',  FALSE, FALSE),
('O-',  TRUE,  FALSE);

-- Hospitals
INSERT INTO Hospitals (hospital_name, address, city, contact_number, email) VALUES
('SSKM Hospital',                  'Harish M Street',   'Kolkata', '2555-1001', 'info@sskm.org'),
('B M Birla Hospital',             'Beleverde Avenue',  'Kolkata', '2555-2002', 'contact@bmri.org'),
('Fortis Hospital',                'EM Bypass Road',    'Kolkata', '2555-3003', 'gvh@fortis.com'),
('Chittaranjan Children Hospital', 'Hazra road',        'Kolkata', '2555-4004', 'contact@ch.org'),
('Ruby Hospital',                  'Rashbehari Road',   'Kolkata', '2555-5005', 'admin@ruby.org');

-- Donors
INSERT INTO Donors (first_name, last_name, date_of_birth, gender, blood_type_id, phone, email, city, weight_kg, is_active) VALUES
('Ravi',     'Tiwari',   '1985-03-14', 'Male',   7, '9836506115', 'ravi.t@mail.com',      'Kolkata', 78.5, TRUE),
('Komal',    'Mondal',   '1990-07-22', 'Female', 1, '9836115722', 'k.mondal@mail.com',    'Kolkata', 62.0, TRUE),
('Abhishek', 'Sharma',   '1978-11-05', 'Male',   3, '9888206118', 'abhishek.s@mail.com',  'Kolkata', 85.0, TRUE),
('Priya',    'Sharma',   '1995-01-30', 'Female', 8, '9836506115', 'priya.s@mail.com',     'Kolkata', 55.5, TRUE),
('Suraj',    'Sarogi',   '1988-06-18', 'Male',   5, '9836118628', 's.suraj@mail.com',     'Kolkata', 90.0, TRUE),
('Kirti',    'Roshan',   '1992-09-09', 'Female', 2, '8950012112', 'K.r@mail.com',         'Kolkata', 60.0, TRUE),
('Nikhil',   'Pawar',    '1975-12-25', 'Male',   6, '7980606119', 'N.pawar@mail.com',     'Kolkata', 82.0, FALSE),
('Sophia',   'Hussain',  '2000-04-11', 'Female', 4, '9852631455', 'sophia.h@mail.com',    'Kolkata', 58.0, TRUE),
('Arun',     'Mishra',   '1983-08-03', 'Male',   7, '9455561111', 'Arun.m@mail.com',      'Kolkata', 77.0, TRUE),
('Avani',    'Jha',      '1997-02-14', 'Female', 1, '6280506116', 'ava.ni@mail.com',      'Kolkata', 65.0, TRUE),
('Eshan',    'Kanjilal', '1980-05-20', 'Male',   3, '9847582113', 'eshan.K@mail.com',     'Kolkata', 88.0, TRUE),
('Ishani',   'Kumari',   '1993-10-07', 'Female', 7, '9663306114', 'isa.k@mail.com',       'Kolkata', 59.0, TRUE);

-- Donor Health Screenings
INSERT INTO DonorHealthScreening
(donor_id, screening_date, hemoglobin_level, blood_pressure_sys, blood_pressure_dia,
 pulse_rate, temperature_f, has_hiv, has_hepatitis_b, has_hepatitis_c,
 has_syphilis, has_malaria, is_eligible, notes, screened_by)
VALUES
(1,  '2024-01-10', 14.5, 118, 76, 72, 98.4, FALSE, FALSE, FALSE, FALSE, FALSE, TRUE,  NULL,                                    'Dr. Patel'),
(2,  '2024-01-12', 13.1, 112, 70, 68, 98.6, FALSE, FALSE, FALSE, FALSE, FALSE, TRUE,  NULL,                                    'Dr. Patel'),
(3,  '2024-01-15', 15.0, 125, 80, 78, 98.2, FALSE, FALSE, FALSE, FALSE, FALSE, TRUE,  NULL,                                    'Dr. Saha'),
(4,  '2024-01-18', 12.8, 108, 68, 65, 98.5, FALSE, FALSE, FALSE, FALSE, FALSE, TRUE,  NULL,                                    'Dr. Saha'),
(5,  '2024-01-20', 16.0, 130, 85, 80, 98.7, FALSE, FALSE, FALSE, FALSE, FALSE, TRUE,  NULL,                                    'Dr. Patel'),
(6,  '2024-02-01', 13.5, 115, 72, 70, 98.3, FALSE, FALSE, FALSE, FALSE, FALSE, TRUE,  NULL,                                    'Dr. Patel'),
(7,  '2024-02-05', 14.0, 120, 78, 74, 98.6, FALSE, TRUE,  FALSE, FALSE, FALSE, FALSE, 'Hepatitis B positive — deferred',       'Dr. Saha'),
(8,  '2024-02-08', 12.5, 110, 68, 66, 98.4, FALSE, FALSE, FALSE, FALSE, FALSE, TRUE,  NULL,                                    'Dr. Saha'),
(9,  '2024-02-10', 14.2, 119, 75, 71, 98.5, FALSE, FALSE, FALSE, FALSE, FALSE, TRUE,  NULL,                                    'Dr. Patel'),
(10, '2024-02-15', 13.8, 114, 71, 69, 98.6, FALSE, FALSE, TRUE,  FALSE, FALSE, FALSE, 'Hepatitis C detected — deferred',       'Dr. Saha'),
(11, '2024-03-01', 15.5, 122, 79, 76, 98.3, FALSE, FALSE, FALSE, FALSE, FALSE, TRUE,  NULL,                                    'Dr. Patel'),
(12, '2024-03-05', 13.0, 111, 69, 67, 98.6, FALSE, FALSE, FALSE, FALSE, FALSE, TRUE,  NULL,                                    'Dr. Saha'),
(1,  '2024-06-15', 14.8, 117, 75, 71, 98.4, FALSE, FALSE, FALSE, FALSE, FALSE, TRUE,  NULL,                                    'Dr. Patel'),
(3,  '2024-07-20', 15.2, 124, 82, 77, 98.2, FALSE, FALSE, FALSE, FALSE, FALSE, TRUE,  NULL,                                    'Dr. Saha');

-- Donations
INSERT INTO Donations (donor_id, screening_id, donation_date, units_donated, donation_type, collected_by) VALUES
(1,  1,  '2024-01-10', 1.00, 'Whole Blood', 'Nurse Kaur'),
(2,  2,  '2024-01-12', 1.00, 'Whole Blood', 'Nurse Tamang'),
(3,  3,  '2024-01-15', 1.00, 'Plasma',      'Nurse Kaur'),
(4,  4,  '2024-01-18', 1.00, 'Whole Blood', 'Nurse Tamang'),
(5,  5,  '2024-01-20', 1.00, 'Platelets',   'Nurse Kaur'),
(6,  6,  '2024-02-01', 1.00, 'Whole Blood', 'Nurse Tamang'),
(8,  8,  '2024-02-08', 1.00, 'Whole Blood', 'Nurse Kaur'),
(9,  9,  '2024-02-10', 1.00, 'Whole Blood', 'Nurse Tamang'),
(11, 11, '2024-03-01', 1.00, 'Plasma',      'Nurse Kaur'),
(12, 12, '2024-03-05', 1.00, 'Whole Blood', 'Nurse Tamang'),
(1,  13, '2024-06-15', 1.00, 'Whole Blood', 'Nurse Kaur'),
(3,  14, '2024-07-20', 1.00, 'Whole Blood', 'Nurse Tamang');

-- Blood Inventory
INSERT INTO BloodInventory
(donation_id, blood_type_id, donation_type, units_available, collection_date, expiry_date, storage_location, is_contaminated, status)
VALUES
(1,  7, 'Whole Blood', 1.00, '2024-01-10', '2024-02-21', 'Fridge-A1',  FALSE, 'Used'),
(2,  1, 'Whole Blood', 1.00, '2024-01-12', '2024-02-23', 'Fridge-A2',  FALSE, 'Used'),
(3,  3, 'Plasma',      1.00, '2024-01-15', '2025-01-15', 'Freezer-B1', FALSE, 'Available'),
(4,  8, 'Whole Blood', 1.00, '2024-01-18', '2024-02-29', 'Fridge-A3',  FALSE, 'Expired'),
(5,  5, 'Platelets',   1.00, '2024-01-20', '2024-01-25', 'Fridge-C1',  FALSE, 'Expired'),
(6,  2, 'Whole Blood', 1.00, '2024-02-01', '2024-03-14', 'Fridge-A4',  FALSE, 'Used'),
(7,  4, 'Whole Blood', 1.00, '2024-02-08', '2024-03-21', 'Fridge-A5',  TRUE,  'Discarded'),
(8,  7, 'Whole Blood', 1.00, '2024-02-10', '2024-03-23', 'Fridge-A6',  FALSE, 'Used'),
(9,  6, 'Plasma',      1.00, '2024-03-01', '2025-03-01', 'Freezer-B2', FALSE, 'Available'),
(10, 7, 'Whole Blood', 1.00, '2024-03-05', '2024-04-16', 'Fridge-A7',  FALSE, 'Available'),
(11, 7, 'Whole Blood', 1.00, '2024-06-15', '2024-07-27', 'Fridge-A8',  FALSE, 'Available'),
(12, 3, 'Whole Blood', 1.00, '2024-07-20', '2024-08-31', 'Fridge-B3',  FALSE, 'Available');

-- Recipients
INSERT INTO Recipients (first_name, last_name, date_of_birth, gender, blood_type_id, phone, city, hospital_id, medical_condition) VALUES
('Alina',     'Maurya',  '1955-06-20', 'Female', 7, '7980606118', 'Kolkata', 1, 'Anemia'),
('Bikash',    'Thakur',  '1942-09-13', 'Male',   1, '9839101722', 'Kolkata', 2, 'Surgery - Hip Replacement'),
('Chandrika', 'Saha',    '1970-11-28', 'Female', 3, '6283566316', 'Kolkata', 3, 'Trauma'),
('Dan',       'Harris',  '1990-02-05', 'Male',   5, '9856114727', 'Kolkata', 4, 'Sickle Cell Disease'),
('Eva',       'Shaw',    '2005-08-17', 'Female', 8, '6288566316', 'Kolkata', 4, 'Leukemia - Pediatric'),
('Pradeep',   'Mandal',  '1965-04-29', 'Male',   7, '9899117723', 'Kolkata', 1, 'GI Bleeding'),
('Garima',    'Kumari',  '1980-12-01', 'Female', 2, '6280786311', 'Kolkata', 5, 'Ectopic Pregnancy'),
('Ritesh',    'Tiwari',  '1938-07-14', 'Male',   6, '9836115729', 'Kolkata', 2, 'Cardiac Surgery');

-- Blood Requests
INSERT INTO BloodRequests
(recipient_id, hospital_id, blood_type_id, donation_type, units_requested, urgency, request_date, required_by_date, status, approved_by)
VALUES
(1,    1, 7, 'Whole Blood', 2.00, 'High',     '2024-02-12', '2024-02-14', 'Fulfilled', 'Dr. Patel'),
(2,    2, 1, 'Whole Blood', 1.00, 'Medium',   '2024-02-14', '2024-02-20', 'Fulfilled', 'Dr. Saha'),
(3,    3, 3, 'Whole Blood', 1.00, 'Critical', '2024-02-10', '2024-02-10', 'Fulfilled', 'Dr. Patel'),
(4,    4, 5, 'Plasma',      1.00, 'High',     '2024-03-10', '2024-03-12', 'Fulfilled', 'Dr. Saha'),
(5,    4, 8, 'Platelets',   2.00, 'Critical', '2024-02-08', '2024-02-09', 'Rejected',  'Dr. Patel'),
(6,    1, 7, 'Whole Blood', 1.00, 'High',     '2024-06-20', '2024-06-22', 'Fulfilled', 'Dr. Saha'),
(7,    5, 2, 'Whole Blood', 1.00, 'Critical', '2024-03-15', '2024-03-15', 'Fulfilled', 'Dr. Patel'),
(8,    2, 6, 'Plasma',      2.00, 'Medium',   '2024-04-01', '2024-04-05', 'Pending',   NULL),
(NULL, 3, 7, 'Whole Blood', 3.00, 'High',     '2024-07-18', '2024-07-20', 'Pending',   NULL),
(NULL, 1, 1, 'Whole Blood', 2.00, 'Medium',   '2024-08-01', '2024-08-10', 'Pending',   NULL);

-- Transfusions
INSERT INTO Transfusions
(request_id, inventory_id, recipient_id, hospital_id, transfusion_date, units_transfused, administered_by, outcome)
VALUES
(1, 1,  1, 1, '2024-02-13', 1.00, 'Dr. Singh',  'Successful'),
(1, 8,  1, 1, '2024-02-14', 1.00, 'Dr. Kumar',  'Successful'),
(2, 2,  2, 2, '2024-02-15', 1.00, 'Dr. Anwar',  'Successful'),
(3, 3,  3, 3, '2024-02-10', 1.00, 'Dr. Kumar',  'Successful'),
(4, 9,  4, 4, '2024-03-11', 1.00, 'Dr. Anwar',  'Successful'),
(6, 11, 6, 1, '2024-06-21', 1.00, 'Dr. Singh',  'Successful'),
(7, 6,  7, 5, '2024-03-15', 1.00, 'Dr. Kumar',  'Adverse Reaction');

-- Quick verify all tables
SELECT * FROM BloodTypes;
SELECT * FROM Hospitals;
SELECT * FROM Donors;
SELECT * FROM DonorHealthScreening;
SELECT * FROM Donations;
SELECT * FROM BloodInventory;
SELECT * FROM Recipients;
SELECT * FROM BloodRequests;
SELECT * FROM Transfusions;


-- ============================================================
-- SECTION 3: ANALYTICAL QUERIES  (All fixed for MySQL 8.0)
-- ============================================================

-- ─────────────────────────────────────────────────────────
-- Q1. Current blood availability by blood group and type
-- ─────────────────────────────────────────────────────────
SELECT
    bt.blood_group,
    bi.donation_type,
    COUNT(bi.inventory_id)  AS units_in_stock,
    SUM(bi.units_available) AS total_units,
    MIN(bi.expiry_date)     AS earliest_expiry
FROM BloodInventory bi
JOIN BloodTypes bt ON bi.blood_type_id = bt.blood_type_id
WHERE bi.status         = 'Available'
  AND bi.is_contaminated = FALSE
  AND bi.expiry_date    >= CURDATE()
GROUP BY bt.blood_group, bi.donation_type
ORDER BY bt.blood_group, bi.donation_type;


-- ─────────────────────────────────────────────────────────
-- Q2. Stock vs pending requests — supply vs demand
-- ─────────────────────────────────────────────────────────
WITH Supply AS (
    SELECT bt.blood_group,
           SUM(bi.units_available) AS available_units
    FROM BloodInventory bi
    JOIN BloodTypes bt ON bi.blood_type_id = bt.blood_type_id
    WHERE bi.status         = 'Available'
      AND bi.is_contaminated = FALSE
      AND bi.expiry_date    >= CURDATE()
    GROUP BY bt.blood_group
),
Demand AS (
    SELECT bt.blood_group,
           SUM(br.units_requested) AS requested_units
    FROM BloodRequests br
    JOIN BloodTypes bt ON br.blood_type_id = bt.blood_type_id
    WHERE br.status = 'Pending'
    GROUP BY bt.blood_group
),
-- Simulate FULL OUTER JOIN using LEFT + RIGHT UNION
Combined AS (
    SELECT s.blood_group                          AS blood_group,
           COALESCE(s.available_units, 0)         AS available_units,
           COALESCE(d.requested_units, 0)         AS requested_units
    FROM Supply s
    LEFT JOIN Demand d ON s.blood_group = d.blood_group

    UNION

    SELECT d.blood_group                          AS blood_group,
           COALESCE(s.available_units, 0)         AS available_units,
           COALESCE(d.requested_units, 0)         AS requested_units
    FROM Supply s
    RIGHT JOIN Demand d ON s.blood_group = d.blood_group
)
SELECT
    blood_group,
    available_units,
    requested_units                               AS pending_request_units,
    available_units - requested_units             AS net_balance,
    CASE
        WHEN available_units = 0
             THEN 'OUT OF STOCK'
        WHEN available_units < requested_units
             THEN 'SHORTAGE'
        ELSE 'Sufficient'
    END AS stock_status
FROM Combined
ORDER BY net_balance;


-- ─────────────────────────────────────────────────────────
-- Q3. Donors with blood-borne diseases
-- ─────────────────────────────────────────────────────────
SELECT
    d.donor_id,
    CONCAT(d.first_name, ' ', d.last_name)   AS donor_name,
    bt.blood_group,
    dhs.screening_date,
    TRIM(
        CONCAT(
            CASE WHEN dhs.has_hiv         = TRUE THEN 'HIV '         ELSE '' END,
            CASE WHEN dhs.has_hepatitis_b = TRUE THEN 'Hepatitis-B ' ELSE '' END,
            CASE WHEN dhs.has_hepatitis_c = TRUE THEN 'Hepatitis-C ' ELSE '' END,
            CASE WHEN dhs.has_syphilis    = TRUE THEN 'Syphilis '    ELSE '' END,
            CASE WHEN dhs.has_malaria     = TRUE THEN 'Malaria'      ELSE '' END
        )
    )                                         AS detected_diseases,
    dhs.is_eligible,
    dhs.notes
FROM DonorHealthScreening dhs
JOIN Donors    d  ON dhs.donor_id     = d.donor_id
JOIN BloodTypes bt ON d.blood_type_id = bt.blood_type_id
WHERE dhs.has_hiv         = TRUE
   OR dhs.has_hepatitis_b = TRUE
   OR dhs.has_hepatitis_c = TRUE
   OR dhs.has_syphilis    = TRUE
   OR dhs.has_malaria     = TRUE
ORDER BY dhs.screening_date DESC;


-- ─────────────────────────────────────────────────────────
-- Q4. Contaminated blood units in inventory
-- ─────────────────────────────────────────────────────────
SELECT
    bi.inventory_id,
    bt.blood_group,
    bi.donation_type,
    bi.collection_date,
    bi.expiry_date,
    bi.contamination_reason,
    bi.status,
    CONCAT(d.first_name, ' ', d.last_name)  AS donor_name
FROM BloodInventory bi
JOIN BloodTypes bt ON bi.blood_type_id  = bt.blood_type_id
JOIN Donations  don ON bi.donation_id   = don.donation_id
JOIN Donors     d   ON don.donor_id     = d.donor_id
WHERE bi.is_contaminated = TRUE
ORDER BY bi.collection_date DESC;


-- ─────────────────────────────────────────────────────────
-- Q5. Blood units expiring within the next 10 days
-- ─────────────────────────────────────────────────────────
SELECT
    bi.inventory_id,
    bt.blood_group,
    bi.donation_type,
    bi.units_available,
    bi.expiry_date,
    DATEDIFF(bi.expiry_date, CURDATE()) AS days_until_expiry,
    bi.storage_location
FROM BloodInventory bi
JOIN BloodTypes bt ON bi.blood_type_id = bt.blood_type_id
WHERE bi.status         = 'Available'
  AND bi.is_contaminated = FALSE
  AND bi.expiry_date    BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 10 DAY)
ORDER BY bi.expiry_date ASC;


-- ─────────────────────────────────────────────────────────
-- Q6. Donor donation history & eligibility check
-- ─────────────────────────────────────────────────────────
SELECT
    d.donor_id,
    CONCAT(d.first_name, ' ', d.last_name)         AS donor_name,
    bt.blood_group,
    d.is_active,
    COUNT(don.donation_id)                          AS total_donations,
    MAX(don.donation_date)                          AS last_donation_date,
    DATEDIFF(CURDATE(), MAX(don.donation_date))     AS days_since_last_donation,
    CASE
        WHEN d.is_active = FALSE                                        THEN 'Inactive'
        WHEN DATEDIFF(CURDATE(), MAX(don.donation_date)) < 56           THEN 'Too Soon (< 56 days)'
        ELSE 'Eligible to Donate'
    END AS eligibility_status
FROM Donors d
JOIN BloodTypes bt  ON d.blood_type_id = bt.blood_type_id
LEFT JOIN Donations don ON d.donor_id  = don.donor_id
GROUP BY d.donor_id, d.first_name, d.last_name, bt.blood_group, d.is_active
ORDER BY last_donation_date DESC;


-- ─────────────────────────────────────────────────────────
-- Q7. Hospital-wise blood request analysis
-- ─────────────────────────────────────────────────────────
SELECT
    h.hospital_name,
    h.city,
    COUNT(br.request_id)                                            AS total_requests,
    SUM(br.units_requested)                                         AS total_units_requested,
    SUM(CASE WHEN br.status = 'Fulfilled' THEN 1 ELSE 0 END)       AS fulfilled,
    SUM(CASE WHEN br.status = 'Pending'   THEN 1 ELSE 0 END)       AS pending,
    SUM(CASE WHEN br.status = 'Rejected'  THEN 1 ELSE 0 END)       AS rejected,
    ROUND(
        100.0 * SUM(CASE WHEN br.status = 'Fulfilled' THEN 1 ELSE 0 END)
              / COUNT(br.request_id),
    1)                                                              AS fulfillment_rate_pct
FROM Hospitals h
LEFT JOIN BloodRequests br ON h.hospital_id = br.hospital_id
GROUP BY h.hospital_id, h.hospital_name, h.city
ORDER BY total_requests DESC;


-- ─────────────────────────────────────────────────────────
-- Q8. Critical & high-urgency unfulfilled requests
-- ─────────────────────────────────────────────────────────
SELECT
    br.request_id,
    h.hospital_name,
    bt.blood_group,
    br.donation_type,
    br.units_requested,
    br.urgency,
    br.request_date,
    br.required_by_date,
    DATEDIFF(br.required_by_date, CURDATE())        AS days_remaining,
    CONCAT(r.first_name, ' ', r.last_name)          AS recipient_name,
    r.medical_condition
FROM BloodRequests br
JOIN  Hospitals  h  ON br.hospital_id  = h.hospital_id
JOIN  BloodTypes bt ON br.blood_type_id = bt.blood_type_id
LEFT JOIN Recipients r ON br.recipient_id = r.recipient_id
WHERE br.status = 'Pending'
  AND br.urgency IN ('Critical', 'High')
ORDER BY br.urgency, br.required_by_date;


-- ─────────────────────────────────────────────────────────
-- Q9. Transfusion outcome report
-- ─────────────────────────────────────────────────────────
SELECT
    t.transfusion_id,
    CONCAT(r.first_name, ' ', r.last_name)  AS recipient_name,
    h.hospital_name,
    bt.blood_group,
    bi.donation_type,
    t.units_transfused,
    t.transfusion_date,
    t.administered_by,
    t.outcome,
    r.medical_condition
FROM Transfusions   t
JOIN Recipients     r  ON t.recipient_id   = r.recipient_id
JOIN Hospitals      h  ON t.hospital_id    = h.hospital_id
JOIN BloodInventory bi ON t.inventory_id   = bi.inventory_id
JOIN BloodTypes     bt ON bi.blood_type_id = bt.blood_type_id
ORDER BY t.transfusion_date DESC;


-- ─────────────────────────────────────────────────────────
-- Q10. Monthly donation trends
-- ─────────────────────────────────────────────────────────
SELECT
    DATE_FORMAT(don.donation_date, '%Y-%m')                                 AS month,
    COUNT(don.donation_id)                                                  AS total_donations,
    SUM(don.units_donated)                                                  AS total_units_collected,
    COUNT(DISTINCT don.donor_id)                                            AS unique_donors,
    SUM(CASE WHEN bi.is_contaminated = TRUE  THEN 1 ELSE 0 END)            AS contaminated_units,
    SUM(CASE WHEN bi.is_contaminated = FALSE THEN 1 ELSE 0 END)            AS clean_units
FROM Donations don
JOIN BloodInventory bi ON don.donation_id = bi.donation_id
GROUP BY DATE_FORMAT(don.donation_date, '%Y-%m')
ORDER BY month;


-- ─────────────────────────────────────────────────────────
-- Q11. Blood compatibility check for a recipient
--   A+  recipient → IN ('A+','A-','O+','O-')
--   A-  recipient → IN ('A-','O-')
--   B+  recipient → IN ('B+','B-','O+','O-')
--   B-  recipient → IN ('B-','O-')
--   AB+ recipient → IN ('A+','A-','B+','B-','AB+','AB-','O+','O-')
--   AB- recipient → IN ('A-','B-','AB-','O-')
--   O+  recipient → IN ('O+','O-')
--   O-  recipient → IN ('O-')
-- ─────────────────────────────────────────────────────────
SELECT
    bi.inventory_id,
    bt_inv.blood_group              AS blood_group_in_stock,
    bi.donation_type,
    bi.units_available,
    bi.expiry_date,
    DATEDIFF(bi.expiry_date, CURDATE()) AS days_until_expiry,
    bi.storage_location
FROM BloodInventory bi
JOIN BloodTypes bt_inv ON bi.blood_type_id = bt_inv.blood_type_id
WHERE bi.status          = 'Available'
  AND bi.is_contaminated  = FALSE
  AND bi.expiry_date     >= CURDATE()
  AND bt_inv.blood_group IN ('B+', 'B-', 'O+', 'O-')   -- compatible groups for B+ recipient
ORDER BY bi.expiry_date ASC;


-- ─────────────────────────────────────────────────────────
-- Q12. Top donors by total units donated
-- ─────────────────────────────────────────────────────────
SELECT
    CONCAT(d.first_name, ' ', d.last_name)  AS donor_name,
    bt.blood_group,
    COUNT(don.donation_id)                  AS donation_count,
    SUM(don.units_donated)                  AS total_units_donated,
    MAX(don.donation_date)                  AS latest_donation,
    d.is_active
FROM Donors d
JOIN BloodTypes bt ON d.blood_type_id = bt.blood_type_id
JOIN Donations don ON d.donor_id      = don.donor_id
GROUP BY d.donor_id,
         CONCAT(d.first_name, ' ', d.last_name),   -- fixed: use expression not alias
         bt.blood_group,
         d.is_active
ORDER BY total_units_donated DESC, donation_count DESC;


-- ─────────────────────────────────────────────────────────
-- Q13. Inventory audit — units by status
-- ─────────────────────────────────────────────────────────
SELECT
    bi.status,
    bt.blood_group,
    bi.donation_type,
    COUNT(bi.inventory_id)   AS unit_count,
    SUM(bi.units_available)  AS total_volume
FROM BloodInventory bi
JOIN BloodTypes bt ON bi.blood_type_id = bt.blood_type_id
GROUP BY bi.status, bt.blood_group, bi.donation_type
ORDER BY bi.status, bt.blood_group;


-- ─────────────────────────────────────────────────────────
-- Q14. Donor deferral report
-- ─────────────────────────────────────────────────────────
SELECT
    CONCAT(d.first_name, ' ', d.last_name)                  AS donor_name,
    bt.blood_group,
    dhs.screening_date,
    dhs.notes                                                AS deferral_reason,
    CASE WHEN dhs.has_hiv         = TRUE THEN 'YES' ELSE 'NO' END AS HIV,
    CASE WHEN dhs.has_hepatitis_b = TRUE THEN 'YES' ELSE 'NO' END AS Hepatitis_B,
    CASE WHEN dhs.has_hepatitis_c = TRUE THEN 'YES' ELSE 'NO' END AS Hepatitis_C,
    CASE WHEN dhs.has_syphilis    = TRUE THEN 'YES' ELSE 'NO' END AS Syphilis,
    CASE WHEN dhs.has_malaria     = TRUE THEN 'YES' ELSE 'NO' END AS Malaria,
    dhs.screened_by
FROM DonorHealthScreening dhs
JOIN Donors    d  ON dhs.donor_id     = d.donor_id
JOIN BloodTypes bt ON d.blood_type_id = bt.blood_type_id
WHERE dhs.is_eligible = FALSE
ORDER BY dhs.screening_date DESC;


-- ─────────────────────────────────────────────────────────
-- Q15. Stored Procedure: Register a new donation end-to-end
-- ─────────────────────────────────────────────────────────
DROP PROCEDURE IF EXISTS RegisterDonation;

DELIMITER $$
CREATE PROCEDURE RegisterDonation(
    IN  p_donor_id      INT,
    IN  p_hgb           DECIMAL(4,1),
    IN  p_bp_sys        INT,
    IN  p_bp_dia        INT,
    IN  p_pulse         INT,
    IN  p_temp          DECIMAL(4,1),
    IN  p_has_hiv       BOOLEAN,
    IN  p_has_hep_b     BOOLEAN,
    IN  p_has_hep_c     BOOLEAN,
    IN  p_has_syphilis  BOOLEAN,
    IN  p_has_malaria   BOOLEAN,
    IN  p_donation_type VARCHAR(20),
    IN  p_collected_by  VARCHAR(100),
    OUT p_message       VARCHAR(255)
)
BEGIN
    DECLARE v_eligible      BOOLEAN DEFAULT TRUE;
    DECLARE v_screening_id  INT;
    DECLARE v_donation_id   INT;
    DECLARE v_blood_type_id INT;
    DECLARE v_expiry_date   DATE;

    -- Determine eligibility
    IF p_has_hiv OR p_has_hep_b OR p_has_hep_c OR p_has_syphilis OR p_has_malaria THEN
        SET v_eligible = FALSE;
    END IF;
    IF p_hgb < 12.5 THEN
        SET v_eligible = FALSE;
    END IF;

    -- Step 1: Insert health screening record
    INSERT INTO DonorHealthScreening
        (donor_id, screening_date, hemoglobin_level,
         blood_pressure_sys, blood_pressure_dia, pulse_rate, temperature_f,
         has_hiv, has_hepatitis_b, has_hepatitis_c,
         has_syphilis, has_malaria, is_eligible, screened_by)
    VALUES
        (p_donor_id, CURDATE(), p_hgb,
         p_bp_sys, p_bp_dia, p_pulse, p_temp,
         p_has_hiv, p_has_hep_b, p_has_hep_c,
         p_has_syphilis, p_has_malaria, v_eligible, p_collected_by);

    SET v_screening_id = LAST_INSERT_ID();

    IF NOT v_eligible THEN
        SET p_message = 'Donor deferred: failed health screening.';
    ELSE
        -- Step 2: Insert donation record
        INSERT INTO Donations
            (donor_id, screening_id, donation_date, units_donated, donation_type, collected_by)
        VALUES
            (p_donor_id, v_screening_id, CURDATE(), 1.00, p_donation_type, p_collected_by);

        SET v_donation_id = LAST_INSERT_ID();

        -- Get donor's blood type
        SELECT blood_type_id INTO v_blood_type_id
        FROM Donors WHERE donor_id = p_donor_id;

        -- Calculate expiry date based on donation type
        SET v_expiry_date = CASE p_donation_type
            WHEN 'Whole Blood' THEN DATE_ADD(CURDATE(), INTERVAL 42  DAY)
            WHEN 'Plasma'      THEN DATE_ADD(CURDATE(), INTERVAL 365 DAY)
            WHEN 'Platelets'   THEN DATE_ADD(CURDATE(), INTERVAL 5   DAY)
            WHEN 'Red Cells'   THEN DATE_ADD(CURDATE(), INTERVAL 42  DAY)
            ELSE                    DATE_ADD(CURDATE(), INTERVAL 42  DAY)
        END;

        -- Step 3: Add to blood inventory
        INSERT INTO BloodInventory
            (donation_id, blood_type_id, donation_type, units_available,
             collection_date, expiry_date, storage_location, is_contaminated, status)
        VALUES
            (v_donation_id, v_blood_type_id, p_donation_type, 1.00,
             CURDATE(), v_expiry_date, 'Pending Assignment', FALSE, 'Available');

        SET p_message = CONCAT('Donation registered. Inventory ID: ', LAST_INSERT_ID());
    END IF;
END$$
DELIMITER ;

-- Example call (uncomment to test):
-- CALL RegisterDonation(1, 14.5, 118, 76, 72, 98.4, FALSE, FALSE, FALSE, FALSE, FALSE, 'Whole Blood', 'Nurse Adams', @msg);
-- SELECT @msg;


-- ─────────────────────────────────────────────────────────
-- Q16. View: Real-time blood availability dashboard
-- ─────────────────────────────────────────────────────────
DROP VIEW IF EXISTS vw_BloodAvailability;

CREATE VIEW vw_BloodAvailability AS
SELECT
    bt.blood_group,
    bi.donation_type,
    COUNT(bi.inventory_id)                                                          AS bags_available,
    SUM(bi.units_available)                                                         AS total_units,
    MIN(bi.expiry_date)                                                             AS next_expiry,
    SUM(CASE WHEN DATEDIFF(bi.expiry_date, CURDATE()) <= 7 THEN 1 ELSE 0 END)      AS expiring_within_7_days
FROM BloodInventory bi
JOIN BloodTypes bt ON bi.blood_type_id = bt.blood_type_id
WHERE bi.status         = 'Available'
  AND bi.is_contaminated = FALSE
  AND bi.expiry_date    >= CURDATE()
GROUP BY bt.blood_group, bi.donation_type;

-- Query the view
SELECT * FROM vw_BloodAvailability ORDER BY blood_group, donation_type;


-- ─────────────────────────────────────────────────────────
-- Q17. View: Donor eligibility summary
-- ─────────────────────────────────────────────────────────
DROP VIEW IF EXISTS vw_DonorEligibility;

CREATE VIEW vw_DonorEligibility AS
SELECT
    d.donor_id,
    CONCAT(d.first_name, ' ', d.last_name)                  AS donor_name,
    bt.blood_group,
    d.is_active,
    MAX(don.donation_date)                                   AS last_donation,
    DATEDIFF(CURDATE(), MAX(don.donation_date))              AS days_since_donation,
    (SELECT is_eligible
     FROM DonorHealthScreening
     WHERE donor_id = d.donor_id
     ORDER BY screening_date DESC
     LIMIT 1)                                                AS last_screening_eligible,
    CASE
        WHEN d.is_active = FALSE
             THEN 'Inactive'
        WHEN (SELECT is_eligible
              FROM DonorHealthScreening
              WHERE donor_id = d.donor_id
              ORDER BY screening_date DESC
              LIMIT 1) = FALSE
             THEN 'Deferred - Disease Detected'
        WHEN DATEDIFF(CURDATE(), MAX(don.donation_date)) < 56
             THEN 'Too Soon'
        ELSE 'Eligible'
    END AS eligibility_status
FROM Donors d
JOIN BloodTypes bt   ON d.blood_type_id = bt.blood_type_id
LEFT JOIN Donations don ON d.donor_id   = don.donor_id
GROUP BY d.donor_id, d.first_name, d.last_name, bt.blood_group, d.is_active;

-- Query the view
SELECT * FROM vw_DonorEligibility ORDER BY eligibility_status, donor_name;


-- ============================================================
-- END OF BLOOD BANK MANAGEMENT SYSTEM 
-- ============================================================
