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
    CONSTRAINT fk_equipment_id
        FOREIGN KEY (equipment_id)
        REFERENCES Equipment(EquipmentID),
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
    WHERE ReportedDate <= '2026-06-30'
      AND (ResolutionDate IS NULL OR ResolutionDate > '2026-06-30')
    GROUP BY EquipmentID
) m ON e.EquipmentID = m.EquipmentID

LEFT JOIN (
    SELECT equipment_id, COUNT(*) AS active_rental_count
    FROM RentalItem
    WHERE start_date <= '2026-06-30'
      AND (act_return_date IS NULL OR act_return_date > '2026-06-30')
    GROUP BY equipment_id
) r ON e.EquipmentID = r.equipment_id;

SELECT *
FROM equipment_status
ORDER BY EquipmentID;


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
    WHERE payment_date <= '2026-06-30'
    GROUP BY rental_id
) p ON r.rental_id = p.rental_id
WHERE r.rental_date <= '2026-06-30';

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

