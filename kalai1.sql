
/*
Case Study A
student 1 
Database: campusequipmentrental
*/

/* =====================================================
   TASK 1 – DATABASE DESIGN
   ===================================================== */


/* TABLE 1: EquipmentCategories */

CREATE TABLE EquipmentCategories (
    CategoryID VARCHAR(4) PRIMARY KEY,
    CategoryName VARCHAR(100) NOT NULL UNIQUE,
    StandardDailyRate DECIMAL(10,2) NOT NULL,
    Deposit DECIMAL(10,2) NOT NULL,
    CHECK (StandardDailyRate > 0),
    CHECK (Deposit >= 0)
);

/* TABLE 2: StorageLocation */


CREATE TABLE StorageLocations (
    LocationID VARCHAR(4) PRIMARY KEY,
    LocationCode VARCHAR(20) NOT NULL UNIQUE,
    LocationName VARCHAR(100) NOT NULL,
    LocationDescription VARCHAR(255)
);

/* TABLE 3: Equipment*/


CREATE TABLE Equipment (
    EquipmentID VARCHAR(5) PRIMARY KEY,
    AssetIdentifier VARCHAR(50) NOT NULL UNIQUE,
    CategoryID VARCHAR(4) NOT NULL,
    LocationID VARCHAR(4) NOT NULL,
    EquipmentCondition VARCHAR(10) NOT NULL DEFAULT 'GOOD',
    ItemDetails VARCHAR(255),
    CONSTRAINT fk_equipment_category
        FOREIGN KEY (CategoryID)
        REFERENCES EquipmentCategories(CategoryID),
    CONSTRAINT fk_equipment_location
        FOREIGN KEY (LocationID)
        REFERENCES StorageLocations(LocationID),
    CONSTRAINT chk_equipment_condition
        CHECK (EquipmentCondition IN ('GOOD', 'FAIR', 'DAMAGED'))
);

/* TABLE 4: Maintenance */


CREATE TABLE Maintenance (
    MaintenanceID VARCHAR(5) PRIMARY KEY,
    EquipmentID VARCHAR(5) NOT NULL,
    IssueDescription VARCHAR(255) NOT NULL,
    ReportedDate DATE NOT NULL,
    ResolutionDate DATE DEFAULT NULL,
    Status VARCHAR(10) NOT NULL DEFAULT 'OPEN',
    CONSTRAINT fk_maintenance_equipment
        FOREIGN KEY (EquipmentID)
        REFERENCES Equipment(EquipmentID),
    CONSTRAINT chk_maintenance_status
        CHECK (Status IN ('OPEN', 'RESOLVED')),
    CONSTRAINT chk_maintenance_dates
        CHECK (
            ResolutionDate IS NULL
            OR ResolutionDate >= ReportedDate
        ),
    CONSTRAINT chk_maintenance_resolution
        CHECK (
            (Status = 'OPEN' AND ResolutionDate IS NULL)
            OR
            (Status = 'RESOLVED' AND ResolutionDate IS NOT NULL)
        )
);



/* ALTER TABLE AND DROP TABLE DEMONSTRATION */

CREATE TABLE Student1_Demo (
    DemoID INT PRIMARY KEY,
    DemoName VARCHAR(50) NOT NULL
);

ALTER TABLE Student1_Demo
ADD DemoDescription VARCHAR(100);

DESCRIBE Student1_Demo;

DROP TABLE Student1_Demo;


/* =====================================================
   TASK 2 – DATA MANIPULATION AND FILTERING
   ===================================================== */


/* INSERT 4 EQUIPMENT CATEGORIES */

INSERT INTO EquipmentCategories
    (CategoryID, CategoryName, StandardDailyRate, Deposit)
VALUES
    ('CAT1', 'Laptop', 50.00, 100.00),
    ('CAT2', 'Projector', 40.00, 80.00),
    ('CAT3', 'Camera', 60.00, 120.00),
    ('CAT4', 'Audio Equipment', 35.00, 70.00);


/* INSERT 4 STORAGE LOCATIONS */
INSERT INTO StorageLocations
    (LocationID, LocationCode, LocationName, LocationDescription)
VALUES
    ('LOC1', 'LOC001', 'Main Store', 'Main equipment storage room'),
    ('LOC2', 'LOC002', 'IT Store', 'IT equipment storage room'),
    ('LOC3', 'LOC003', 'Media Room', 'Media equipment storage room'),
    ('LOC4', 'LOC004', 'Lab Store', 'Laboratory equipment storage room');


/* INSERT 15 EQUIPMENT ITEMS */
INSERT INTO Equipment
    (EquipmentID, AssetIdentifier, CategoryID, LocationID, EquipmentCondition, ItemDetails)
VALUES
    ('EQ001', 'LAP001', 'CAT1', 'LOC1', 'GOOD', 'Dell Latitude Laptop'),
    ('EQ002', 'LAP002', 'CAT1', 'LOC1', 'GOOD', 'HP EliteBook Laptop'),
    ('EQ003', 'LAP003', 'CAT1', 'LOC2', 'FAIR', 'Lenovo ThinkPad Laptop'),
    ('EQ004', 'LAP004', 'CAT1', 'LOC2', 'GOOD', 'Acer Aspire Laptop'),
    ('EQ005', 'LAP005', 'CAT1', 'LOC3', 'GOOD', 'ASUS VivoBook Laptop'),

    ('EQ006', 'PRO001', 'CAT2', 'LOC3', 'GOOD', 'Epson Multimedia Projector'),
    ('EQ007', 'PRO002', 'CAT2', 'LOC3', 'FAIR', 'BenQ Digital Projector'),
    ('EQ008', 'PRO003', 'CAT2', 'LOC4', 'GOOD', 'Sony Portable Projector'),
    ('EQ009', 'PRO004', 'CAT2', 'LOC4', 'DAMAGED', 'Optoma Projector'),

    ('EQ010', 'CAM001', 'CAT3', 'LOC2', 'GOOD', 'Canon DSLR Camera'),
    ('EQ011', 'CAM002', 'CAT3', 'LOC2', 'FAIR', 'Nikon Digital Camera'),
    ('EQ012', 'CAM003', 'CAT3', 'LOC3', 'GOOD', 'Sony Mirrorless Camera'),

    ('EQ013', 'AUD001', 'CAT4', 'LOC4', 'GOOD', 'Wireless Microphone Set'),
    ('EQ014', 'AUD002', 'CAT4', 'LOC4', 'DAMAGED', 'JBL Portable Speaker'),
    ('EQ015', 'AUD003', 'CAT4', 'LOC1', 'GOOD', 'Audio Mixing Console');

/* INSERT 15 MAINTENANCE EVENTS */
INSERT INTO Maintenance
    (MaintenanceID, EquipmentID, IssueDescription, ReportedDate, ResolutionDate, Status)
VALUES
    ('M001', 'EQ002', 'Laptop battery not charging', '2026-01-05', '2026-01-07', 'RESOLVED'),
    ('M002', 'EQ003', 'Keyboard not responding', '2026-01-08', '2026-01-10', 'RESOLVED'),
    ('M003', 'EQ004', 'Screen flickering', '2026-01-12', NULL, 'OPEN'),
    ('M004', 'EQ005', 'Operating system error', '2026-01-15', '2026-01-17', 'RESOLVED'),
    ('M005', 'EQ007', 'Projector lamp failure', '2026-01-18', '2026-01-20', 'RESOLVED'),
    ('M006', 'EQ008', 'Image display problem', '2026-01-21', '2026-02-10', 'RESOLVED'),
    ('M007', 'EQ010', 'Camera autofocus failure', '2026-01-23', '2026-01-25', 'RESOLVED'),
    ('M008', 'EQ011', 'Camera lens issue', '2026-01-26', '2026-01-28', 'RESOLVED'),
    ('M009', 'EQ013', 'Microphone connection issue', '2026-01-29', NULL, 'OPEN'),
    ('M010', 'EQ014', 'Microphone connection issue', '2026-02-01', '2026-02-03', 'RESOLVED'),
    ('M011', 'EQ015', 'Speaker sound distortion', '2026-02-04', NULL, 'OPEN'),
    ('M012', 'EQ015', 'Audio console power failure', '2026-02-06', '2026-02-08', 'RESOLVED'),
    ('M013', 'EQ002', 'Laptop fan noise', '2026-02-10', '2026-02-11', 'RESOLVED'),
    ('M014', 'EQ003', 'Laptop charging port issue', '2026-02-12', '2026-02-20', 'RESOLVED'),
    ('M015', 'EQ007', 'Projector remote malfunction', '2026-02-14', '2026-02-15', 'RESOLVED');

/* =====================================================
   FOUR INVALID OPERATIONS (Updated for VARCHAR IDs)
   ===================================================== */

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


/* =====================================================
   TWO UPDATE OPERATIONS
   ===================================================== */

/* UPDATE 1: Change LAP001 condition to FAIR. */

UPDATE Equipment
SET EquipmentCondition = 'FAIR'
WHERE AssetIdentifier = 'LAP001';


/* UPDATE 2: Resolve OPEN maintenance event for EquipmentID EQ004. */

UPDATE Maintenance
SET Status = 'RESOLVED',
    ResolutionDate = '2026-01-14'
WHERE EquipmentID = 'EQ004'
AND Status = 'OPEN';


/* =====================================================
   ONE DELETE OPERATION
   ===================================================== */

/* Insert a temporary record before deleting it. */

INSERT INTO Maintenance
    (MaintenanceID, EquipmentID, IssueDescription, ReportedDate, ResolutionDate, Status)
VALUES
    ('M999', 'EQ006', 'Temporary maintenance test record', '2026-03-01', NULL, 'OPEN');


/* Delete the temporary record. */

DELETE FROM Maintenance
WHERE IssueDescription = 'Temporary maintenance test record';


/* =====================================================
   FIVE FILTERING QUERIES
   ===================================================== */

/* QUERY 1: BETWEEN */

SELECT *
FROM Equipment
WHERE EquipmentID BETWEEN 'EQ002' AND 'EQ008';


/* QUERY 2: LIKE */

SELECT *
FROM Equipment
WHERE AssetIdentifier LIKE 'LAP%';


/* QUERY 3: IN AND AND */

SELECT *
FROM Equipment
WHERE EquipmentCondition IN ('GOOD', 'FAIR')
AND CategoryID IN ('CAT1', 'CAT2');


/* QUERY 4: OR AND NOT */

SELECT *
FROM Equipment
WHERE EquipmentCondition = 'DAMAGED'
OR NOT EquipmentCondition = 'GOOD';


/* QUERY 5: IS NULL */

SELECT *
FROM Maintenance
WHERE ResolutionDate IS NULL;


/* =====================================================
   THREE ORDER BY QUERIES
   ===================================================== */

/* QUERY 1: ORDER BY CONDITION ASCENDING */

SELECT EquipmentID, AssetIdentifier, EquipmentCondition
FROM Equipment
ORDER BY EquipmentCondition ASC;


/* QUERY 2: ORDER BY ASSET IDENTIFIER DESCENDING */

SELECT EquipmentID, AssetIdentifier, CategoryID
FROM Equipment
ORDER BY AssetIdentifier DESC;


/* QUERY 3: ORDER BY TWO ATTRIBUTES */

SELECT EquipmentID, AssetIdentifier,
       CategoryID, EquipmentCondition
FROM Equipment
ORDER BY CategoryID ASC,
         EquipmentCondition DESC;


/* =====================================================
   TASK 3 – SQL FUNCTIONS, JOINS, REPORTS AND VIEWS
   ===================================================== */


/* STRING FUNCTION */

SELECT
    EquipmentID,
    UPPER(AssetIdentifier) AS UppercaseAssetIdentifier,
    LENGTH(AssetIdentifier) AS IdentifierLength
FROM Equipment;


/* NUMERIC FUNCTION */

SELECT
    CategoryID,
    CategoryName,
    StandardDailyRate,
    Deposit,
    ROUND(StandardDailyRate + Deposit, 2) AS TotalAmount
FROM EquipmentCategories;


/* AGGREGATE FUNCTIONS */

SELECT
    COUNT(*) AS TotalEquipment,
    SUM(StandardDailyRate) AS TotalDailyRates,
    AVG(StandardDailyRate) AS AverageDailyRate,
    MIN(StandardDailyRate) AS LowestDailyRate,
    MAX(StandardDailyRate) AS HighestDailyRate
FROM EquipmentCategories;


/* CASE EXPRESSION */

SELECT
    EquipmentID,
    AssetIdentifier,
    EquipmentCondition,
    CASE
        WHEN EquipmentCondition = 'GOOD'
            THEN 'Excellent Condition'
        WHEN EquipmentCondition = 'FAIR'
            THEN 'Needs Attention'
        WHEN EquipmentCondition = 'DAMAGED'
            THEN 'Requires Repair'
        ELSE 'Unknown Condition'
    END AS ConditionStatus
FROM Equipment;


/* INNER JOIN */

SELECT
    e.EquipmentID,
    e.AssetIdentifier,
    e.EquipmentCondition,
    c.CategoryName,
    c.StandardDailyRate
FROM Equipment e
INNER JOIN EquipmentCategories c
    ON e.CategoryID = c.CategoryID
ORDER BY e.EquipmentID;


/* LEFT JOIN */

SELECT
    e.EquipmentID,
    e.AssetIdentifier,
    e.EquipmentCondition,
    m.MaintenanceID,
    m.IssueDescription,
    m.Status
FROM Equipment e
LEFT JOIN Maintenance m
    ON e.EquipmentID = m.EquipmentID
ORDER BY e.EquipmentID;


/* JOIN INVOLVING THREE TABLES */

SELECT
    e.EquipmentID,
    e.AssetIdentifier,
    c.CategoryName,
    c.StandardDailyRate,
    s.LocationCode,
    s.LocationName,
    e.EquipmentCondition
FROM Equipment e
INNER JOIN EquipmentCategories c
    ON e.CategoryID = c.CategoryID
INNER JOIN StorageLocations s
    ON e.LocationID = s.LocationID
ORDER BY e.EquipmentID;


/* GROUP BY REPORT 1: TOTAL EQUIPMENT BY CATEGORY */

SELECT
    c.CategoryID,
    c.CategoryName,
    COUNT(e.EquipmentID) AS TotalEquipment
FROM EquipmentCategories c
INNER JOIN Equipment e
    ON c.CategoryID = e.CategoryID
GROUP BY
    c.CategoryID,
    c.CategoryName
ORDER BY TotalEquipment DESC;


/* GROUP BY REPORT 2 WITH HAVING */

SELECT
    Status,
    COUNT(*) AS TotalMaintenance
FROM Maintenance
GROUP BY Status
HAVING COUNT(*) > 3
ORDER BY TotalMaintenance DESC;


/* UNION ALL */

SELECT
    AssetIdentifier AS RecordDescription,
    'Equipment' AS RecordType
FROM Equipment

UNION ALL

SELECT
    IssueDescription AS RecordDescription,
    'Maintenance' AS RecordType
FROM Maintenance;


/* CREATE INDIVIDUAL VIEW */

CREATE VIEW Student1_EquipmentView AS
SELECT
    e.EquipmentID,
    e.AssetIdentifier,
    c.CategoryName,
    s.LocationCode,
    s.LocationName,
    e.EquipmentCondition,
    COUNT(m.MaintenanceID) AS TotalMaintenance
FROM Equipment e
INNER JOIN EquipmentCategories c
    ON e.CategoryID = c.CategoryID
INNER JOIN StorageLocations s
    ON e.LocationID = s.LocationID
LEFT JOIN Maintenance m
    ON e.EquipmentID = m.EquipmentID
GROUP BY
    e.EquipmentID,
    e.AssetIdentifier,
    c.CategoryName,
    s.LocationCode,
    s.LocationName,
    e.EquipmentCondition;


/* DISPLAY THE VIEW */

SELECT *
FROM Student1_EquipmentView;


/* DISPLAY EQUIPMENT WITHOUT MAINTENANCE HISTORY */

SELECT *
FROM Student1_EquipmentView
WHERE TotalMaintenance = 0;


/* =====================================================
   STUDENT 1 – REQUIRED MANAGEMENT OUTPUT
   EQUIPMENT DETAILS REPORT
   ===================================================== */

SELECT
    e.EquipmentID,
    e.AssetIdentifier,
    c.CategoryName,
    s.LocationName,
    e.EquipmentCondition,
    COUNT(m.MaintenanceID) AS TotalMaintenance
FROM Equipment e
INNER JOIN EquipmentCategories c
    ON e.CategoryID = c.CategoryID
INNER JOIN StorageLocations s
    ON e.LocationID = s.LocationID
LEFT JOIN Maintenance m
    ON e.EquipmentID = m.EquipmentID
GROUP BY
    e.EquipmentID,
    e.AssetIdentifier,
    c.CategoryName,
    s.LocationName,
    e.EquipmentCondition
ORDER BY e.EquipmentID;