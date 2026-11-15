
/*CONSTRAINTS*/

/* TEST 1: DUPLICATE PRIMARY KEY */

INSERT INTO EquipmentCategories
    (CategoryID, CategoryName, StandardDailyRate, Deposit)
SELECT
    CategoryID,
    CONCAT(CategoryName, '_DUPLICATE_PK'),
    10.00,
    0.00
FROM EquipmentCategories
LIMIT 1;


/* TEST 2: DUPLICATE UNIQUE CATEGORY NAME */

INSERT INTO EquipmentCategories
    (CategoryID, CategoryName, StandardDailyRate, Deposit)
SELECT
    'CAT9',
    CategoryName,
    10.00,
    0.00
FROM EquipmentCategories
LIMIT 1;


/* TEST 3: INVALID EQUIPMENT CONDITION */

INSERT INTO Equipment
    (EquipmentID, AssetIdentifier, CategoryID, LocationID, EquipmentCondition, ItemDetails)
SELECT
    'EQ998',
    'INVALID-TEST-001',
    c.CategoryID,
    l.LocationID,
    'POOR',
    'Invalid condition test'
FROM EquipmentCategories c
CROSS JOIN StorageLocations l
LIMIT 1;


/* TEST 4: INVALID FOREIGN KEY */

INSERT INTO Equipment
    (EquipmentID, AssetIdentifier, CategoryID, LocationID, EquipmentCondition, ItemDetails)
SELECT
    'EQ999',
    'INVALID-FK-001',
    'CAT99', -- Non-existent category ID
    LocationID,
    'GOOD',
    'Invalid foreign key test'
FROM StorageLocations
LIMIT 1;

/*STUDENT 2 */
/*Insert Test Data */
INSERT INTO Borrower (borrower_id, matric_no, full_name, email, phone_no) 
VALUES ('B7777', 'A23CS0004', 'Harry Potter', 'harry@gmail.com', '0123456789');

INSERT INTO Rental (rental_id, borrower_id, rental_date, remarks) 
VALUES ('I000423', 'B7777', '2026-02-01', ''),
       ('I000999', 'B7777', '2026-02-01', ''),
       ('I004569', 'B7777', '2026-02-01', '');
       
/* Test 1: Non Existant Borrower in Borrower Table added to Rental Table*/
INSERT INTO Rental(rental_id, borrower_id, rental_date, remarks) 
VALUES ('I000334', 'B7776', '2026-02-01', '');

/* Test 2: Invalid Due Date (Due Date is before Start Date)*/
INSERT INTO RentalItem(rental_item_id, rental_id, equipment_id, agreed_daily_rate, start_date, due_date) 
VALUES ('RT0456', 'I000423', 'EQ001', 15.00, '2026-02-05', '2026-02-01');

/* Test 3: Duplicate Equipment (Same equipment added twice in same rental transaction*/
INSERT INTO RentalItem(rental_item_id, rental_id, equipment_id, agreed_daily_rate, start_date, due_date) 
VALUES ('RT0234', 'I000999', 'EQ001', 15.00, '2026-02-01', '2026-02-05');

INSERT INTO RentalItem(rental_item_id, rental_id, equipment_id, agreed_daily_rate, start_date, due_date) 
VALUES ('RT0567', 'I000999', 'EQ001', 15.00, '2026-02-02', '2026-02-06');

/* Test 4: Invalid Payment Amount (Negative Value)*/
INSERT INTO Payment(payment_id, rental_id, amount, payment_method, payment_date)
VALUES ('P011202', 'I004569', -45.0, 'CASH', '2026-02-01');
SELECT rental_id, borrower_id, rental_date, remarks
FROM Rental
WHERE borrower_id IN ('B0006', 'B0007') OR rental_date > '2026-02-11';

/* Clean Test data*/
DELETE FROM RentalItem
WHERE rental_item_id IN ('RT0234', 'RT0567');

DELETE FROM Payment
WHERE payment_id = 'P011202';

DELETE FROM Rental 
WHERE rental_id IN ('I000334', 'I000423', 'I000999', 'I004569');

DELETE FROM Borrower 
WHERE borrower_id = 'B7777';

/*Overlap & Touching Endpoints Test*/
/*Overlapping*/ 
SELECT * FROM rental_overlap; 

/*Add overlapping Data*/
INSERT INTO Rental (rental_id, borrower_id, rental_date, remarks)
VALUES ('I900001', 'B0003', '2026-02-10', 'test data1');
INSERT INTO RentalItem (rental_item_id, rental_id, equipment_id, agreed_daily_rate, start_date, due_date, act_return_date)
VALUES ('RT9001', 'I900001', 'EQ004', 20.00, '2026-02-10', '2026-02-15', '2026-02-15');


INSERT INTO Rental (rental_id, borrower_id, rental_date, remarks)
VALUES ('I900002', 'B0008',  '2026-02-12', 'test data 2');
INSERT INTO RentalItem (rental_item_id, rental_id, equipment_id, agreed_daily_rate, start_date, due_date, act_return_date)
VALUES ('RT9002', 'I900002', 'EQ004', 20.00, '2026-02-12', '2026-02-18', '2026-02-18');

/*Display the overlapping data*/
SELECT * FROM rental_overlap; 

/*Clean test data 2 only*/
DELETE FROM RentalItem WHERE rental_item_id = 'RT9002';
DELETE FROM Rental WHERE rental_id = 'I900002';

/* Touching Endpoints */
INSERT INTO Rental (rental_id, borrower_id, rental_date, remarks)
VALUES ('I900003', 'B0008', '2026-02-15', 'test data 3');
INSERT INTO RentalItem (rental_item_id, rental_id, equipment_id, agreed_daily_rate, start_date, due_date, act_return_date)
VALUES ('RT9003', 'I900003', 'EQ004', 20.00, '2026-02-15', '2026-02-20', '2026-02-20');

/*Display the overlapping data (No overlap happens here)*/
SELECT * FROM rental_overlap; 
DELETE FROM RentalItem WHERE rental_item_id IN ('RT9003', 'RT9001');
DELETE FROM Rental WHERE rental_id IN ('I900003', 'I900001');

/*Clean test data 1 and 3 */
DELETE FROM RentalItem WHERE rental_item_id IN ('RT9003', 'RT9001');
DELETE FROM Rental WHERE rental_id IN ('I900003', 'I900001');

/*BUSINESS RULES*/
/* VALIDATION 1: Rental date cannot be later than item start date */

SELECT r.rental_id, 
       r.rental_date,
       ri.rental_item_id, 
       ri.start_date
FROM Rental r
INNER JOIN RentalItem ri
    ON r.rental_id = ri.rental_id
WHERE r.rental_date > ri.start_date; 

/* VALIDATION 2: Payment date cannot precede rental date */

SELECT p.payment_id, 
       p.payment_date,
       r.rental_id, 
       r.rental_date
FROM Payment p
INNER JOIN Rental r
    ON p.rental_id = r.rental_id
WHERE p.payment_date < r.rental_date; 

/*VERIFICATION */
/*Case 1, no related records*/
/*Borrower Records */
SELECT b.borrower_id, b.matric_no, b.full_name, b.email
FROM Borrower b
LEFT JOIN Rental r ON b.borrower_id = r.borrower_id
WHERE r.rental_id IS NULL;

/*Rental Records */
SELECT * 
FROM financial_report 
WHERE rental_id = 'I000015';

/*Case 2, multiple items and payments: I000001*/
SELECT * 
FROM financial_report 
WHERE rental_id = 'I000001'
ORDER BY rental_item_id;

/*Case 3, partial payment and the cutoff date: I000020.*/
SELECT * 
FROM financial_report 
WHERE rental_id = 'I000020';

/*Case 4, Multiple items and multiple payments partially paid*/
SELECT * 
FROM financial_report 
WHERE rental_id = 'I000003'
ORDER BY rental_item_id;


