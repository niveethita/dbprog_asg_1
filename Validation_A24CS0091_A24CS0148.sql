
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