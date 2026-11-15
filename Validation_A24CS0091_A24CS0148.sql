
/*CONSTRAINTS*/
/* Test 1 : Duplicate Primary Key */
INSERT INTO EquipmentCategories
    (CategoryID, CategoryName, StandardDailyRate, Deposit)
SELECT
    CategoryID,
    CONCAT(CategoryName, '_DUPLICATE_PK'),
    10.00,
    0.00
FROM EquipmentCategories
LIMIT 1;

/* Test 2 : Duplicate Unique Category Key */
INSERT INTO EquipmentCategories
    (CategoryName, StandardDailyRate, Deposit)
SELECT
    CategoryName,
    10.00,
    0.00
FROM EquipmentCategories
LIMIT 1;

/* Test 3 : Invalid Equipment Condition */
INSERT INTO Equipment
    (AssetIdentifier, CategoryID, LocationID,
     EquipmentCondition, ItemDetails)
SELECT
    'INVALID-TEST-001',
    c.CategoryID,
    l.LocationID,
    'POOR',
    'Invalid condition test'
FROM EquipmentCategories c
CROSS JOIN StorageLocations l
LIMIT 1;

/* Test 4 : Invalid Foreign Key */
INSERT INTO Equipment
    (AssetIdentifier, CategoryID, LocationID,
     EquipmentCondition, ItemDetails)
SELECT
    'INVALID-FK-001',
    -999,
    LocationID,
    'GOOD',
    'Invalid foreign key test'
FROM StorageLocations
LIMIT 1;

/*STUDENT 2 */
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
SELECT rental_id, borrower_id, rental_date, remarks
FROM Rental
WHERE borrower_id IN ('B0006', 'B0007') OR rental_date > '2026-06-11';

/* VALIDATION 1: Rental date cannot be later than item start date */

SELECT r.rental_id, 
       r.rental_date,
       ri.rental_item_id, 
       ri.start_date
FROM Rental r
INNER JOIN RentalItem ri
    ON r.rental_id = ri.rental_id
WHERE r.rental_date > ri.start_date; */

/* VALIDATION 2: Payment date cannot precede rental date */

SELECT p.payment_id, 
       p.payment_date,
       r.rental_id, 
       r.rental_date
FROM Payment p
INNER JOIN Rental r
    ON p.rental_id = r.rental_id
WHERE p.payment_date < r.rental_date; 

/*Overlap & Touching Endpoints Test*/
/*Overlapping*/ 
SELECT * FROM rental_overlap; 

/*Add overlapping Data*/
INSERT INTO Rental (rental_id, borrower_id, rental_date, remarks)
VALUES ('I900001', 'B0003', '2026-06-01', 'test data1');
INSERT INTO RentalItem (rental_item_id, rental_id, equipment_id, agreed_daily_rate, start_date, due_date, act_return_date)
VALUES ('RT9001', 'I900001', 13, 20.00, '2026-06-01', '2026-06-05', '2026-06-05');


INSERT INTO Rental (rental_id, borrower_id, rental_date, remarks)
VALUES ('I900002', 'B0008', '2026-06-03', 'test data 2');
INSERT INTO RentalItem (rental_item_id, rental_id, equipment_id, agreed_daily_rate, start_date, due_date, act_return_date)
VALUES ('RT9002', 'I900002', 13, 20.00, '2026-06-03', '2026-06-08', '2026-06-08');

/*Display the overlapping data*/
SELECT * FROM rental_overlap; 

/*Clean test data 2 only*/
DELETE FROM RentalItem WHERE rental_item_id = 'RT9002';
DELETE FROM Rental WHERE rental_id = 'I900002';

/* Touching Endpoints */
INSERT INTO Rental (rental_id, borrower_id, rental_date, remarks)
VALUES ('I900003', 'B0008', '2026-06-05', 'test data 3');
INSERT INTO RentalItem (rental_item_id, rental_id, equipment_id, agreed_daily_rate, start_date, due_date, act_return_date)
VALUES ('RT9003', 'I900003', 13, 20.00, '2026-06-05', '2026-06-09', '2026-06-09');

/*Display the overlapping data (No overlap happens here)*/
SELECT * FROM rental_overlap; 
DELETE FROM RentalItem WHERE rental_item_id IN ('RT9003', 'RT9001');
DELETE FROM Rental WHERE rental_id IN ('I900003', 'I900001');

/*Clean test data 1 and 3 */
DELETE FROM RentalItem WHERE rental_item_id IN ('RT9003', 'RT9001');
DELETE FROM Rental WHERE rental_id IN ('I900003', 'I900001');
