/*combine both*/

CREATE TABLE EquipmentCategories (
    CategoryID VARCHAR(4) PRIMARY KEY,
    CategoryName VARCHAR(100) NOT NULL UNIQUE,
    StandardDailyRate DECIMAL(10,2) NOT NULL,
    Deposit DECIMAL(10,2) NOT NULL,
    CHECK (StandardDailyRate > 0),
    CHECK (Deposit >= 0)
);

CREATE TABLE StorageLocations (
    LocationID VARCHAR(4) PRIMARY KEY,
    LocationCode VARCHAR(20) NOT NULL UNIQUE,
    LocationName VARCHAR(100) NOT NULL,
    LocationDescription VARCHAR(255)
);

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

/*STUDENT 2*/
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
    equipment_id VARCHAR(5) NOT NULL,
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
        UNIQUE (rental_id, equipment_id),
    CONSTRAINT fk_equipment_id
        FOREIGN KEY (equipment_id)
        REFERENCES Equipment(EquipmentID)
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
/* equipment-status view (OUTPUT 4)*/
CREATE VIEW equipment_status AS
SELECT e.EquipmentID, e.AssetIdentifier, c.CategoryName, l.LocationCode, l.LocationName, e.EquipmentCondition,

    CASE
        WHEN m.open_maintenance_count IS NULL THEN 0
        ELSE m.open_maintenance_count
    END AS open_maintenance_count,

    CASE
        WHEN r.active_rental_count IS NULL THEN 0
        ELSE r.active_rental_count
    END AS active_rental_count,

    CASE
        WHEN e.EquipmentCondition IN ('GOOD', 'FAIR')
             AND (m.open_maintenance_count IS NULL OR m.open_maintenance_count = 0)
             AND (r.active_rental_count IS NULL OR r.active_rental_count = 0)
        THEN 'AVAILABLE'
        ELSE 'UNAVAILABLE'
    END AS equipment_status

FROM Equipment e
INNER JOIN EquipmentCategories c ON e.CategoryID = c.CategoryID
INNER JOIN StorageLocations l ON e.LocationID = l.LocationID

LEFT JOIN (
    SELECT EquipmentID, COUNT(*) AS open_maintenance_count
    FROM Maintenance
    WHERE ReportedDate <= '2026-02-28'
      AND (ResolutionDate IS NULL OR ResolutionDate > '2026-02-28')
    GROUP BY EquipmentID
) m ON e.EquipmentID = m.EquipmentID

LEFT JOIN (
    SELECT equipment_id, COUNT(*) AS active_rental_count
    FROM RentalItem
    WHERE start_date <= '2026-02-28'
      AND (act_return_date IS NULL OR act_return_date > '2026-02-28')
    GROUP BY equipment_id
) r ON e.EquipmentID = r.equipment_id;

SELECT *
FROM equipment_status
ORDER BY EquipmentID;

/*INPUT DATA*/
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
    ('M003', 'EQ004', 'Screen flickering', '2026-01-12', '2026-01-14', 'RESOLVED'),
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

/*student 2*/
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
    ('B9999', 'A24CS9999', 'Test User', 'test.user@graduate.utm.my', '0123456789');

INSERT INTO Rental (rental_id, borrower_id, rental_date, remarks)
VALUES
    ('I000001', 'B0001', '2026-01-01', NULL),
    ('I000002', 'B0006', '2026-01-03', NULL),
    ('I000003', 'B0002', '2026-01-05', NULL),
    ('I000004', 'B0005', '2026-01-08', NULL),
    ('I000005', 'B0004', '2026-01-10', NULL),
    ('I000006', 'B0007', '2026-01-12', NULL),
    ('I000007', 'B0006', '2026-01-15', NULL),
    ('I000008', 'B0010', '2026-01-18', NULL),
    ('I000009', 'B0009', '2026-01-20', 'need manual book'),
    ('I000010', 'B0007', '2026-01-22', NULL),
    ('I000011', 'B0012', '2026-01-25', NULL),
    ('I000012', 'B0011', '2026-01-28', NULL),
    ('I000013', 'B0015', '2026-02-01', 'extra charger'),
    ('I000014', 'B0013', '2026-02-02', NULL),
    ('I000015', 'B0014', '2026-02-05', NULL),
    ('I000016', 'B0001', '2026-02-06', NULL),
    ('I000017', 'B0004', '2026-02-08', 'need manual book'),
    ('I000018', 'B0007', '2026-02-10', NULL),
    ('I000019', 'B0002', '2026-02-12', NULL),
    ('I000020', 'B0005', '2026-02-14', NULL);

INSERT INTO RentalItem (rental_item_id, rental_id, equipment_id, agreed_daily_rate, start_date, due_date, act_return_date)
VALUES
    ('RI0001', 'I000001', 'EQ001', 20.00, '2026-01-01', '2026-01-05', '2026-01-04'),
    ('RI0002', 'I000001', 'EQ002', 15.50, '2026-01-01', '2026-01-05', '2026-01-05'),
    ('RI0003', 'I000002', 'EQ010', 50.00, '2026-01-03', '2026-01-10', '2026-01-09'),
    ('RI0004', 'I000003', 'EQ001', 20.00, '2026-01-05', '2026-01-08', '2026-01-07'),
    ('RI0005', 'I000003', 'EQ004', 30.00, '2026-01-05', '2026-01-08', '2026-01-08'),
    ('RI0006', 'I000004', 'EQ005', 12.00, '2026-01-08', '2026-01-12', '2026-01-12'),
    ('RI0007', 'I000005', 'EQ006', 45.00, '2026-01-10', '2026-01-15', '2026-01-14'),
    ('RI0008', 'I000006', 'EQ007', 10.00, '2026-01-12', '2026-01-14', '2026-01-14'),
    ('RI0009', 'I000007', 'EQ002', 15.50, '2026-01-15', '2026-01-20', '2026-01-19'),
    ('RI0010', 'I000007', 'EQ008', 60.00, '2026-01-15', '2026-01-20', '2026-01-20'),
    ('RI0011', 'I000008', 'EQ009', 25.00, '2026-01-18', '2026-01-22', '2026-01-21'),
    ('RI0012', 'I000009', 'EQ012', 35.00, '2026-01-20', '2026-01-25', '2026-01-25'),
    ('RI0013', 'I000010', 'EQ003', 50.00, '2026-01-22', '2026-01-28', '2026-01-27'),
    ('RI0014', 'I000011', 'EQ011', 18.00, '2026-01-29', '2026-02-05', NULL),
    ('RI0015', 'I000011', 'EQ001', 20.00, '2026-01-25', '2026-02-01', NULL),
    ('RI0016', 'I000012', 'EQ004', 30.00, '2026-01-28', '2026-02-02', '2026-02-02'),
    ('RI0017', 'I000013', 'EQ012', 40.00, '2026-02-01', '2026-02-05', NULL),
    ('RI0018', 'I000014', 'EQ006', 45.00, '2026-02-02', '2026-02-06', NULL),
    ('RI0019', 'I000015', 'EQ005', 12.00, '2026-02-05', '2026-02-10', NULL),
    ('RI0020', 'I000016', 'EQ007', 10.00, '2026-02-06', '2026-02-09', '2026-02-08'),
    ('RI0021', 'I000016', 'EQ009', 25.00, '2026-02-06', '2026-02-09', '2026-02-08'),
    ('RI0022', 'I000017', 'EQ008', 60.00, '2026-02-11', '2026-02-15', NULL),
    ('RI0023', 'I000018', 'EQ010', 35.00, '2026-02-10', '2026-02-15', NULL),
    ('RI0024', 'I000019', 'EQ002', 15.50, '2026-02-12', '2026-02-18', NULL),
    ('RI0025', 'I000020', 'EQ003', 50.00, '2026-02-21', '2026-02-27', NULL),
    ('RI0026', 'I000002', 'EQ011', 18.00, '2026-01-04', '2026-01-09', '2026-01-09'),
    ('RI0027', 'I000004', 'EQ012', 40.00, '2026-01-09', '2026-01-13', '2026-01-13'),
    ('RI0028', 'I000006', 'EQ001', 20.00, '2026-01-13', '2026-01-16', '2026-01-16'),
    ('RI0029', 'I000009', 'EQ005', 12.00, '2026-01-21', '2026-01-26', '2026-01-26'),
    ('RI0030', 'I000012', 'EQ006', 45.00, '2026-01-29', '2026-02-03', '2026-02-01');

INSERT INTO Payment (payment_id, rental_id, amount, payment_method, payment_date)
VALUES
    (101, 'I000001', 92.00, 'FPX',  '2026-01-01'),
    (102, 'I000002', 150.00, 'CARD', '2026-01-03'),
    (103, 'I000003', 80.00, 'CASH', '2026-01-05'),
    (104, 'I000004', 45.00, 'TNG',  '2026-01-08'),
    (105, 'I000005', 120.00, 'FPX',  '2026-01-10'),
    (106, 'I000006', 30.00, 'CASH', '2026-01-12'),
    (107, 'I000007', 200.00, 'CARD', '2026-01-15'),
    (108, 'I000008', 75.00, 'TNG',  '2026-01-18'),
    (109, 'I000009', 90.00, 'FPX',  '2026-01-20'),
    (110, 'I000010', 150.00, 'CARD', '2026-01-22'),
    (111, 'I000011', 216.00, 'FPX',  '2026-01-25'),
    (112, 'I000012', 60.00, 'CASH', '2026-01-28'),
    (113, 'I000013', 110.00, 'TNG',  '2026-02-01'),
    (114, 'I000014', 135.00, 'CARD', '2026-02-02'),
    (115, 'I000010', 50.00, 'CASH', '2026-01-27'),
    (116, 'I000016', 75.00, 'FPX',  '2026-02-06'),
    (117, 'I000017', 180.00, 'CARD', '2026-02-08'),
    (118, 'I000018', 95.00, 'TNG',  '2026-02-10'),
    (119, 'I000019', 70.00, 'CASH', '2026-02-12'),
    (120, 'I000020', 150.00, 'FPX',  '2026-02-14'),
    (121, 'I000001', 50.00, 'CASH', '2026-01-04'),
    (122, 'I000003', 20.00, 'TNG',  '2026-01-07'),
    (123, 'I000005', 30.00, 'CARD', '2026-01-14'),
    (124, 'I000007', 50.00, 'FPX',  '2026-01-18'),
    (125, 'I000011', 50.00, 'CASH', '2026-01-30'),
    (126, 'I000002', 50.00, 'TNG',  '2026-01-05'),
    (127, 'I000009', 40.00, 'CARD', '2026-01-22'),
    (128, 'I000013', 30.00, 'FPX',  '2026-02-03'),
    (129, 'I000016', 30.00, 'CASH', '2026-02-08'),
    (130, 'I000020', 50.00, 'TNG',  '2026-03-02');

/* financial report (OUTPUT 5)*/
CREATE VIEW financial_report AS
SELECT r.rental_id, i.rental_item_id, r.rental_date, b.borrower_id, b.matric_no, b.full_name,
    DATEDIFF(i.due_date, i.start_date) * i.agreed_daily_rate AS item_charge,
    t.transaction_charge,
    
    CASE
        WHEN p.total_payments IS NULL THEN 0
        ELSE p.total_payments
    END AS total_payments,
    
    t.transaction_charge -     
    CASE
        WHEN p.total_payments IS NULL THEN 0
        ELSE p.total_payments
    END AS outstanding_balance,
    
    CASE
        WHEN p.total_payments IS NULL OR p.total_payments = 0 THEN 'UNPAID'
        WHEN p.total_payments < t.transaction_charge THEN 'PARTIALLY PAID'
        ELSE 'PAID'
    END AS payment_status

FROM Rental r
INNER JOIN Borrower b ON r.borrower_id = b.borrower_id
INNER JOIN RentalItem i ON r.rental_id = i.rental_id
INNER JOIN (
    SELECT rental_id, SUM(DATEDIFF(due_date, start_date) * agreed_daily_rate) AS transaction_charge
    FROM RentalItem
    GROUP BY rental_id
) t ON r.rental_id = t.rental_id
LEFT JOIN (
    SELECT rental_id, SUM(amount) AS total_payments
    FROM Payment
    WHERE payment_date <= '2026-02-28'
    GROUP BY rental_id
) p ON r.rental_id = p.rental_id
WHERE r.rental_date <= '2026-02-28';

SELECT *
FROM financial_report
ORDER BY rental_id, rental_item_id;

/* query for rental overlap (OUTPUT) 6*/
CREATE VIEW rental_overlap AS
SELECT a.equipment_id, e.AssetIdentifier,
       a.rental_item_id AS item_1, 
       a.rental_id AS rental_1,
       a.start_date AS start_1, 
       a.act_return_date AS return_1,
       b.rental_item_id AS item_2, 
       b.rental_id AS rental_2,
       b.start_date AS start_2, 
       b.act_return_date AS return_2
FROM RentalItem a
INNER JOIN RentalItem b
        ON a.equipment_id = b.equipment_id
       AND a.rental_item_id < b.rental_item_id
       AND a.rental_id <> b.rental_id
INNER JOIN Equipment e ON a.equipment_id = e.EquipmentID
WHERE a.start_date <
      CASE
          WHEN b.act_return_date IS NULL THEN '9999-12-31'
          ELSE b.act_return_date
      END
  AND b.start_date <
      CASE
          WHEN a.act_return_date IS NULL THEN '9999-12-31'
          ELSE a.act_return_date
      END;

SELECT *
FROM rental_overlap;

