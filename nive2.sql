/*TASK 1 : DATABASE CREATION & CONSTRAINTS */
CREATE TABLE Borrower (
    borrower_id VARCHAR(5) PRIMARY KEY,
    matric_no VARCHAR(20) NOT NULL UNIQUE,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone_no VARCHAR(12) NULL
);

CREATE TABLE Rental (
    rental_id VARCHAR(7) PRIMARY KEY,
    borrower_id VARCHAR(5) NOT NULL,
    rental_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    remarks TEXT NULL,
    CONSTRAINT fk_rental_borrower
        FOREIGN KEY (borrower_id)
        REFERENCES Borrower(borrower_id)
);

CREATE TABLE RentalItem (
    rental_item_id VARCHAR(6) PRIMARY KEY,
    rental_id VARCHAR(7) NOT NULL,
    equipment_id INT NOT NULL,
    agreed_daily_rate DECIMAL(8,2) NOT NULL,
    start_date DATE NOT NULL,
    due_date DATE NOT NULL,
    act_return_date DATE NULL DEFAULT NULL,

    CONSTRAINT fk_item_rental
        FOREIGN KEY (rental_id)
        REFERENCES Rental(rental_id),
    CONSTRAINT check_daily_rate 
        CHECK (agreed_daily_rate > 0),
    CONSTRAINT check_due_date 
        CHECK (due_date > start_date),
    CONSTRAINT check_return_date 
        CHECK (act_return_date IS NULL OR act_return_date >= start_date),
    CONSTRAINT unique_rental_equipment 
        UNIQUE (rental_id, equipment_id)
);

CREATE TABLE Payment (
    payment_id INT PRIMARY KEY,
    rental_id VARCHAR(7) NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    payment_method ENUM('CASH', 'FPX', 'CARD', 'TNG') NOT NULL,
    payment_date DATE NOT NULL DEFAULT (CURRENT_DATE),

    CONSTRAINT fk_payment_rental
        FOREIGN KEY (rental_id)
        REFERENCES Rental(rental_id),
    CONSTRAINT check_amount 
        CHECK (amount > 0)
);

/*Demonstration Table for ALTER TABLE & DROP TABLE*/
CREATE TABLE DemoTable (
    id INT PRIMARY KEY,
    name VARCHAR(20) NOT NULL,
    age INT NOT NULL
);

DESCRIBE DemoTable;

ALTER TABLE DemoTable 
ADD COLUMN telephone VARCHAR(12) NOT NULL AFTER age,
ADD COLUMN postcode VARCHAR(6) NOT NULL AFTER telephone;

ALTER TABLE DemoTable
MODIFY COLUMN name VARCHAR(30) NOT NULL;

ALTER TABLE DemoTable
CHANGE COLUMN telephone phone_no VARCHAR(12) NOT NULL;

ALTER TABLE DemoTable
ADD CONSTRAINT age_limit CHECK (age >= 18);

INSERT INTO DemoTable (id, name, age, phone_no, postcode)
VALUES (1, 'Sarah', 17, '0123456789', '43000');

DESCRIBE DemoTable;

DROP TABLE DemoTable;
SHOW TABLES;

/*Invalid Operations Tests*/

/*Insert Test Data */
INSERT INTO Borrower (borrower_id, matric_no, full_name, email, phone_no) 
VALUES ('B7777', 'A23CS0004', 'Harry Potter', 'harry@gmail.com', '0123456789');

INSERT INTO Rental (rental_id, borrower_id, rental_date, remarks) 
VALUES ('I000423', 'B7777', '2026-06-01', ''),
       ('I000999', 'B7777', '2026-06-01', ''),
       ('I004569', 'B7777', '2026-06-01', '');

/* Test 1: Non Existant Borrower in Borrower Table added to Rental Table*/
INSERT INTO Rental(rental_id, borrower_id, rental_date, remarks) 
VALUES ('I000334', 'B7776', '2026-06-01', '');

/* Test 2: Invalid Due Date (Due Date is before Start Date)*/
INSERT INTO RentalItem(rental_item_id, rental_id, equipment_id, agreed_daily_rate, start_date, due_date) 
VALUES ('RT0456', 'I000423', 102, 15.00, '2026-06-05', '2026-06-01');

/* Test 3: Duplicate Equipment (Same equipment added twice in same rental transaction*/
INSERT INTO RentalItem(rental_item_id, rental_id, equipment_id, agreed_daily_rate, start_date, due_date) 
VALUES ('RT0234', 'I000999', 102, 15.00, '2026-06-01', '2026-06-05');

INSERT INTO RentalItem(rental_item_id, rental_id, equipment_id, agreed_daily_rate, start_date, due_date) 
VALUES ('RT0567', 'I000999', 102, 15.00, '2026-06-02', '2026-06-06');

/* Test 4: Invalid Payment Amount (Negative Value)*/
INSERT INTO Payment(payment_id, rental_id, amount, payment_method, payment_date)
VALUES (11202, 'I004569', -45.0, 'CASH', '2026-06-01');

/* Clean Test data*/
DELETE FROM RentalItem
WHERE rental_item_id IN ('RT0234', 'RT0567');

DELETE FROM Payment
WHERE payment_id = 11202;

DELETE FROM Rental 
WHERE rental_id IN ('I000334', 'I000423', 'I000999', 'I004569');

DELETE FROM Equipment 
WHERE equipment_id = 102;

DELETE FROM Borrower 
WHERE borrower_id = 'B7777';

/*TASK 2: DATA MANIPULATION & FILTERING*/

INSERT INTO Borrower (borrower_id, matric_no, full_name, email, phone_no)
VALUES
    ('B0001', 'A24CS1034', 'Theven', 'theven@graduate.utm.my', '0123456790'),
    ('B0002', 'A23CS1064', 'Sarah Safiyah', 'sarah.safiyah@graduate.utm.my', '0128764321'),
    ('B0003', 'A23CS2023', 'Lee Hui Ying', 'leehuiying@graduate.utm.my', '0112345678'),
    ('B0004', 'A24CS1111', 'Priya Ganesan', 'priya.ganesan@graduate.utm.my', '0125543210'),
    ('B0005', 'A24CS1352', 'Muhammad Hamzah', 'm.hamzah@graduate.utm.my', '0178504991'),
    ('B0006', 'A25CS2578', 'Nurul Hidayah', 'nurulhidayah@graduate.utm.my', '0142021334'),
    ('B0007', 'A24CS2031', 'Iffah Batrisyah', 'iffah.batrisyah@graduate.utm.my', '0177450882'),
    ('B0008', 'A24CS1203', 'Ranjith Prabhu', 'ranjith.prabhu@graduate.utm.my', '0143234945'),
    ('B0009', 'A25CS2222', 'Hafiz', 'hafiz.a25@graduate.utm.my', '0129876543'),
    ('B0010', 'A24CS1099', 'Parvathy', 'parvathy@graduate.utm.my', '0175739201'),
    ('B0011', 'A25CS1101', 'Chong Wei', 'chongwei@graduate.utm.my', '0118532205'),
    ('B0012', 'A25CS2844', 'Fernandez', 'fernandez@graduate.utm.my', '0170012485'),
    ('B0013', 'A22CS2339', 'Kevin Ong', 'kevin.ong@graduate.utm.my', '0148402332'),
    ('B0014', 'A23CS1234', 'Aishah', 'aishah.a23@graduate.utm.my', '0120473174'),
    ('B0015', 'A24CS1989', 'Siddarth', 'siddarth@graduate.utm.my', '0144038567');

INSERT INTO Rental (rental_id, borrower_id, rental_date, remarks)
VALUES
    ('I000001', 'B0001', '2026-05-01', NULL),
    ('I000002', 'B0006', '2026-05-03', NULL),
    ('I000003', 'B0002', '2026-05-05', NULL),
    ('I000004', 'B0005', '2026-05-08', NULL),
    ('I000005', 'B0004', '2026-05-10', NULL),
    ('I000006', 'B0007', '2026-05-12', NULL),
    ('I000007', 'B0006', '2026-05-15', NULL),
    ('I000008', 'B0010', '2026-05-18', NULL),
    ('I000009', 'B0009', '2026-05-20', 'need manual book'),
    ('I000010', 'B0007', '2026-05-22', NULL),
    ('I000011', 'B0012', '2026-05-25', NULL),
    ('I000012', 'B0011', '2026-05-28', NULL),
    ('I000013', 'B0015', '2026-06-01', 'extra charger'),
    ('I000014', 'B0013', '2026-06-02', NULL),
    ('I000015', 'B0014', '2026-06-05', NULL),
    ('I000016', 'B0001', '2026-06-06', NULL),
    ('I000017', 'B0004', '2026-06-08', 'need manual book'),
    ('I000018', 'B0007', '2026-06-10', NULL),
    ('I000019', 'B0002', '2026-06-12', NULL),
    ('I000020', 'B0005', '2026-06-14', NULL);

INSERT INTO RentalItem (rental_item_id, rental_id, equipment_id, agreed_daily_rate, start_date, due_date, act_return_date)
VALUES
    ('RI0001', 'I000001', 01, 20.00, '2026-05-01', '2026-05-05', '2026-05-04'),
    ('RI0002', 'I000001', 02, 15.50, '2026-05-01', '2026-05-05', '2026-05-05'),
    ('RI0003', 'I000002', 03, 50.00, '2026-05-03', '2026-05-10', '2026-05-09'),
    ('RI0004', 'I000003', 01, 20.00, '2026-05-05', '2026-05-08', '2026-05-07'),
    ('RI0005', 'I000003', 04, 30.00, '2026-05-05', '2026-05-08', '2026-05-08'),
    ('RI0006', 'I000004', 05, 12.00, '2026-05-08', '2026-05-12', '2026-05-12'),
    ('RI0007', 'I000005', 06, 45.00, '2026-05-10', '2026-05-15', '2026-05-14'),
    ('RI0008', 'I000006', 07, 10.00, '2026-05-12', '2026-05-14', '2026-05-14'),
    ('RI0009', 'I000007', 02, 15.50, '2026-05-15', '2026-05-20', '2026-05-19'),
    ('RI0010', 'I000007', 08, 60.00, '2026-05-15', '2026-05-20', '2026-05-20'),
    ('RI0011', 'I000008', 09, 25.00, '2026-05-18', '2026-05-22', '2026-05-21'),
    ('RI0012', 'I000009', 10, 35.00, '2026-05-20', '2026-05-25', '2026-05-25'),
    ('RI0013', 'I000010', 03, 50.00, '2026-05-22', '2026-05-28', '2026-05-27'),
    ('RI0014', 'I000011', 11, 18.00, '2026-05-25', '2026-06-01', NULL),
    ('RI0015', 'I000011', 01, 20.00, '2026-05-25', '2026-06-01', NULL),
    ('RI0016', 'I000012', 04, 30.00, '2026-05-28', '2026-06-02', '2026-06-02'),
    ('RI0017', 'I000013', 12, 40.00, '2026-06-01', '2026-06-05', NULL),
    ('RI0018', 'I000014', 06, 45.00, '2026-06-02', '2026-06-06', NULL),
    ('RI0019', 'I000015', 05, 12.00, '2026-06-05', '2026-06-10', NULL),
    ('RI0020', 'I000016', 07, 10.00, '2026-06-06', '2026-06-09', '2026-06-08'),
    ('RI0021', 'I000016', 09, 25.00, '2026-06-06', '2026-06-09', '2026-06-08'),
    ('RI0022', 'I000017', 08, 60.00, '2026-06-08', '2026-06-12', NULL),
    ('RI0023', 'I000018', 10, 35.00, '2026-06-10', '2026-06-15', NULL),
    ('RI0024', 'I000019', 02, 15.50, '2026-06-12', '2026-06-18', NULL),
    ('RI0025', 'I000020', 03, 50.00, '2026-06-14', '2026-06-20', NULL),
    ('RI0026', 'I000002', 11, 18.00, '2026-05-04', '2026-05-09', '2026-05-09'),
    ('RI0027', 'I000004', 12, 40.00, '2026-05-09', '2026-05-13', '2026-05-13'),
    ('RI0028', 'I000006', 01, 20.00, '2026-05-13', '2026-05-16', '2026-05-16'),
    ('RI0029', 'I000009', 05, 12.00, '2026-05-21', '2026-05-26', '2026-05-26'),
    ('RI0030', 'I000012', 06, 45.00, '2026-05-29', '2026-06-03', '2026-06-01');

INSERT INTO Payment (payment_id, rental_id, amount, payment_method, payment_date)
VALUES
    (101, 'I000001', 92.00, 'FPX',  '2026-05-01'),
    (102, 'I000002', 150.00, 'CARD', '2026-05-03'),
    (103, 'I000003', 80.00, 'CASH', '2026-05-05'),
    (104, 'I000004', 45.00, 'TNG',  '2026-05-08'),
    (105, 'I000005', 120.00, 'FPX',  '2026-05-10'),
    (106, 'I000006', 30.00, 'CASH', '2026-05-12'),
    (107, 'I000007', 200.00, 'CARD', '2026-05-15'),
    (108, 'I000008', 75.00, 'TNG',  '2026-05-18'),
    (109, 'I000009', 90.00, 'FPX',  '2026-05-20'),
    (110, 'I000010', 150.00, 'CARD', '2026-05-22'),
    (111, 'I000011', 216.00, 'FPX',  '2026-05-25'),
    (112, 'I000012', 60.00, 'CASH', '2026-05-28'),
    (113, 'I000013', 110.00, 'TNG',  '2026-06-01'),
    (114, 'I000014', 135.00, 'CARD', '2026-06-02'),
    (115, 'I000010', 50.00, 'CASH', '2026-05-27'),
    (116, 'I000016', 75.00, 'FPX',  '2026-06-06'),
    (117, 'I000017', 180.00, 'CARD', '2026-06-08'),
    (118, 'I000018', 95.00, 'TNG',  '2026-06-10'),
    (119, 'I000019', 70.00, 'CASH', '2026-06-12'),
    (120, 'I000020', 150.00, 'FPX',  '2026-06-14'),
    (121, 'I000001', 50.00, 'CASH', '2026-05-04'),
    (122, 'I000003', 20.00, 'TNG',  '2026-05-07'),
    (123, 'I000005', 30.00, 'CARD', '2026-05-14'),
    (124, 'I000007', 50.00, 'FPX',  '2026-05-18'),
    (125, 'I000011', 50.00, 'CASH', '2026-05-30'),
    (126, 'I000002', 50.00, 'TNG',  '2026-05-05'),
    (127, 'I000009', 40.00, 'CARD', '2026-05-22'),
    (128, 'I000013', 30.00, 'FPX',  '2026-06-03'),
    (129, 'I000016', 30.00, 'CASH', '2026-06-08'),
    (130, 'I000020', 50.00, 'TNG',  '2026-07-02');
 
UPDATE Borrower
SET phone_no = '0111111111'
WHERE borrower_id = 'B0001';

UPDATE Rental
SET remarks = 'need some guidance'
WHERE rental_id = 'I000001';

DELETE FROM Borrower
WHERE borrower_id = 'B9999';

/**/
SELECT payment_id, rental_id, amount, payment_method
FROM Payment
WHERE amount BETWEEN 60 AND 130 
    AND payment_method NOT IN ('CASH')
ORDER BY payment_method, amount DESC;

SELECT rental_item_id, rental_id, equipment_id, agreed_daily_rate
FROM RentalItem
WHERE rental_item_id LIKE 'RI002_' 
    OR act_return_date IS NULL;

SELECT borrower_id, matric_no, full_name, email, phone_no
FROM Borrower
WHERE phone_no LIKE '012%'
    AND matric_no NOT LIKE 'A25CS%'
ORDER BY borrower_id;

SELECT rental_id, borrower_id, rental_date, remarks
FROM Rental
WHERE rental_date BETWEEN '2026-05-01' AND '2026-05-31'
ORDER BY rental_date;

SELECT rental_id, borrower_id, rental_date, remarks
FROM Rental
WHERE borrower_id IN ('B0006', 'B0007') OR rental_date > '2026-06-11';

/* VALIDATION 1: Rental date cannot be later than item start date 

SELECT r.rental_id, 
       r.rental_date,
       ri.rental_item_id, 
       ri.start_date
FROM Rental r
INNER JOIN RentalItem ri
    ON r.rental_id = ri.rental_id
WHERE r.rental_date > ri.start_date; */

/* VALIDATION 2: Payment date cannot precede rental date 

SELECT p.payment_id, 
       p.payment_date,
       r.rental_id, 
       r.rental_date
FROM Payment p
INNER JOIN Rental r
    ON p.rental_id = r.rental_id
WHERE p.payment_date < r.rental_date; */

/* TASK 3: QUERIES, REPORTING & VIEWS*/
/*String Function*/
SELECT
    borrower_id,
    UPPER(full_name) AS upper_full_name,
    SUBSTRING(matric_no, 2, 2) AS intake_batch,
    CASE 
        WHEN SUBSTRING(matric_no, 2, 2) = '25' THEN 'year 1'
        WHEN SUBSTRING(matric_no, 2, 2) = '24' THEN 'year 2'
        WHEN SUBSTRING(matric_no, 2, 2) = '23' THEN 'year 3'
        WHEN SUBSTRING(matric_no, 2, 2) = '22' THEN 'year 4'
        ELSE NULL
    END AS current_year
FROM Borrower;

/*Numeric Function*/
SELECT rental_item_id, equipment_id, agreed_daily_rate,
    DATEDIFF(due_date, start_date) AS planned_days,
    ROUND(DATEDIFF(due_date, start_date) * agreed_daily_rate, 2) AS item_charge,
    CASE
        WHEN act_return_date IS NULL THEN 'NOT RETURNED'
        WHEN act_return_date < due_date THEN 'EARLY'
        WHEN act_return_date = due_date THEN 'ON TIME'
        ELSE 'LATE'
    END AS return_status
FROM RentalItem
ORDER BY rental_item_id;

/*Aggregate*/
SELECT COUNT(*) AS total_items,
       SUM(DATEDIFF(due_date, start_date) * agreed_daily_rate) AS total_planned_charges,
       ROUND(AVG(agreed_daily_rate), 2) AS avg_daily_rate,
       MIN(agreed_daily_rate) AS min_rate,
       MAX(agreed_daily_rate) AS max_rate
FROM RentalItem;

/* Inner Join with 3 tables (Borrower, Rental, RentalItem) */
SELECT b.borrower_id, b.full_name, r.rental_id, r.rental_date,
       ri.rental_item_id, ri.equipment_id,
       DATEDIFF(ri.due_date, ri.start_date) * ri.agreed_daily_rate AS item_charge
FROM Borrower b
INNER JOIN Rental r ON b.borrower_id = r.borrower_id
INNER JOIN RentalItem ri ON r.rental_id = ri.rental_id
ORDER BY r.rental_id, ri.rental_item_id;

/* Left Join borrowers who didnt rent anything*/
/*Required Output 2*/
SELECT b.borrower_id, b.matric_no, b.full_name, b.email
FROM Borrower b
LEFT JOIN Rental r ON b.borrower_id = r.borrower_id
WHERE r.rental_id IS NULL;

/*Left Join rentals with no payment on or before reporting date */
SELECT r.rental_id, r.borrower_id, r.rental_date
FROM Rental r
LEFT JOIN Payment p
       ON r.rental_id = p.rental_id
      AND p.payment_date <= '2026-06-30'
WHERE r.rental_date <= '2026-06-30'
  AND p.payment_id IS NULL;

/* First grouped report for borrowers with 2 or more rentals*/
SELECT b.borrower_id, b.full_name, COUNT(r.rental_id) AS rental_count
FROM Borrower b
INNER JOIN Rental r ON b.borrower_id = r.borrower_id
GROUP BY b.borrower_id, b.full_name
HAVING COUNT(r.rental_id) >= 2
ORDER BY rental_count DESC, b.borrower_id;

/*Second grouped report for payments by method until the reporting date */
SELECT payment_method,
       COUNT(*)  AS no_of_payments,
       SUM(amount) AS total_amount,
       ROUND(AVG(amount), 2) AS avg_amount
FROM Payment
WHERE payment_date <= '2026-06-30'
GROUP BY payment_method
ORDER BY total_amount DESC;

/*required output 3*/

/*Union borrower who rented in both months */
SELECT borrower_id 
FROM Rental 
WHERE rental_date 
BETWEEN '2026-05-01' AND '2026-05-31'

UNION

SELECT borrower_id 
FROM Rental 
WHERE rental_date 
BETWEEN '2026-06-01' AND '2026-06-30';

/* Union All for borrower who rented in both months*/
SELECT borrower_id 
FROM Rental 
WHERE rental_date 
BETWEEN '2026-05-01' AND '2026-05-31'

UNION ALL

SELECT borrower_id 
FROM Rental 
WHERE rental_date 
BETWEEN '2026-06-01' AND '2026-06-30';

/* View Borrower */

CREATE VIEW BorrowerView AS
SELECT
    b.borrower_id,
    b.matric_no,
    b.full_name,
    b.email,
    COUNT(r.rental_id) AS TotalRentals
FROM Borrower b
LEFT JOIN Rental r
    ON b.borrower_id = r.borrower_id
GROUP BY
    b.borrower_id,
    b.matric_no,
    b.full_name,
    b.email;

SELECT *
FROM BorrowerView
ORDER BY TotalRentals;

SELECT *
FROM BorrowerView
WHERE TotalRentals = 0;

/* Required Management Output 3*/
SELECT YEAR(r.rental_date) AS y,
       MONTH(r.rental_date) AS m,
       COUNT(*) AS rentals,
       SUM(rc.item_count) AS items_rented,
       SUM(rc.charge) AS total_charges,
       SUM(COALESCE(rp.paid, 0)) AS total_payments
FROM Rental r
INNER JOIN (SELECT rental_id,
                   COUNT(*) AS item_count,
                   SUM(DATEDIFF(due_date, start_date) * agreed_daily_rate) AS charge
            FROM RentalItem
            GROUP BY rental_id) rc ON r.rental_id = rc.rental_id
LEFT JOIN (SELECT rental_id, SUM(amount) AS paid
           FROM Payment
           WHERE payment_date <= '2026-06-30'
           GROUP BY rental_id) rp ON r.rental_id = rp.rental_id
WHERE r.rental_date <= '2026-06-30'
GROUP BY YEAR(r.rental_date), MONTH(r.rental_date)
ORDER BY y, m;

