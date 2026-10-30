USE EnterpriseBI_DW;
GO

IF OBJECT_ID('Fact.FactPurchaseOrderHeader', 'U') IS NULL
BEGIN
    SELECT
        IDENTITY(BIGINT, 1, 1) AS PurchaseOrderHeaderKey,

        H.PurchaseOrderID,
        H.RevisionNumber,

        DV.VendorKey,
        DE.EmployeeKey,
        DSM.ShipMethodKey,

        CONVERT(INT, CONVERT(CHAR(8), H.OrderDate, 112))
            AS OrderDateKey,

        CASE
            WHEN H.ShipDate IS NOT NULL
            THEN CONVERT(INT, CONVERT(CHAR(8), H.ShipDate, 112))
            ELSE NULL
        END AS ShipDateKey,

        H.Status,
        H.SubTotal,
        H.TaxAmt,
        H.Freight,
        H.TotalDue,
        H.ModifiedDate

    INTO Fact.FactPurchaseOrderHeader

    FROM AdventureWorks2025.Purchasing.PurchaseOrderHeader H

    LEFT JOIN Dim.DimVendor DV
        ON H.VendorID = DV.VendorID

    LEFT JOIN Dim.DimEmployee DE
        ON H.EmployeeID = DE.EmployeeID

    LEFT JOIN Dim.DimShipMethod DSM
        ON H.ShipMethodID = DSM.ShipMethodID;
END;
GO

--Add a primary key
IF NOT EXISTS
(
    SELECT 1
    FROM sys.key_constraints
    WHERE parent_object_id =
          OBJECT_ID('Fact.FactPurchaseOrderHeader')
      AND type = 'PK'
)
BEGIN

    ALTER TABLE Fact.FactPurchaseOrderHeader
    ADD CONSTRAINT PK_FactPurchaseOrderHeader
    PRIMARY KEY (PurchaseOrderHeaderKey);

END;
GO

--Add a unique constraint
IF NOT EXISTS
(
    SELECT 1
    FROM sys.key_constraints
    WHERE parent_object_id =
          OBJECT_ID('Fact.FactPurchaseOrderHeader')
      AND name = 'UQ_FactPurchaseOrderHeader_PurchaseOrderID'
)
BEGIN

    ALTER TABLE Fact.FactPurchaseOrderHeader
    ADD CONSTRAINT UQ_FactPurchaseOrderHeader_PurchaseOrderID
    UNIQUE (PurchaseOrderID);

END;
GO

--Add foreign keys
IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys
    WHERE name = 'FK_FactPOHeader_Vendor'
)
ALTER TABLE Fact.FactPurchaseOrderHeader
ADD CONSTRAINT FK_FactPOHeader_Vendor
FOREIGN KEY (VendorKey)
REFERENCES Dim.DimVendor(VendorKey);
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys
    WHERE name = 'FK_FactPOHeader_Employee'
)
ALTER TABLE Fact.FactPurchaseOrderHeader
ADD CONSTRAINT FK_FactPOHeader_Employee
FOREIGN KEY (EmployeeKey)
REFERENCES Dim.DimEmployee(EmployeeKey);
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys
    WHERE name = 'FK_FactPOHeader_ShipMethod'
)
ALTER TABLE Fact.FactPurchaseOrderHeader
ADD CONSTRAINT FK_FactPOHeader_ShipMethod
FOREIGN KEY (ShipMethodKey)
REFERENCES Dim.DimShipMethod(ShipMethodKey);
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys
    WHERE name = 'FK_FactPOHeader_OrderDate'
)
ALTER TABLE Fact.FactPurchaseOrderHeader
ADD CONSTRAINT FK_FactPOHeader_OrderDate
FOREIGN KEY (OrderDateKey)
REFERENCES Dim.DimDate(DateKey);
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys
    WHERE name = 'FK_FactPOHeader_ShipDate'
)
ALTER TABLE Fact.FactPurchaseOrderHeader
ADD CONSTRAINT FK_FactPOHeader_ShipDate
FOREIGN KEY (ShipDateKey)
REFERENCES Dim.DimDate(DateKey);
GO