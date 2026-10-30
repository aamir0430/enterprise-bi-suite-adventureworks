USE EnterpriseBI_DW;
GO

-- Ensure the Dim schema exists
IF SCHEMA_ID('Dim') IS NULL
BEGIN
    EXEC('CREATE SCHEMA Dim');
END;
GO

-- Create the Vendor dimension only if it does not already exist
IF OBJECT_ID('Dim.DimVendor', 'U') IS NULL
BEGIN
    SELECT
        IDENTITY(INT, 1, 1) AS VendorKey,
        V.BusinessEntityID AS VendorID,
        V.AccountNumber,
        V.Name AS VendorName,
        V.CreditRating,
        V.PreferredVendorStatus,
        V.ActiveFlag,
        V.PurchasingWebServiceURL,
        V.ModifiedDate AS SourceModifiedDate
    INTO Dim.DimVendor
    FROM AdventureWorks2025.Purchasing.Vendor AS V;

    PRINT 'Dim.DimVendor created successfully.';
END
ELSE
BEGIN
    PRINT 'Dim.DimVendor already exists. No table was created.';
END;
GO

USE EnterpriseBI_DW;
GO

-- Adding primary key
IF NOT EXISTS (
    SELECT 1
    FROM sys.key_constraints
    WHERE parent_object_id = OBJECT_ID('Dim.DimVendor')
      AND type = 'PK'
)
BEGIN
    ALTER TABLE Dim.DimVendor
    ADD CONSTRAINT PK_DimVendor
    PRIMARY KEY (VendorKey);

    PRINT 'Primary key created.';
END
ELSE
BEGIN
    PRINT 'Primary key already exists.';
END;
GO

-- Adding unique constraint
IF NOT EXISTS (
    SELECT 1
    FROM sys.key_constraints
    WHERE parent_object_id = OBJECT_ID('Dim.DimVendor')
      AND name = 'UQ_DimVendor_VendorID'
)
BEGIN
    ALTER TABLE Dim.DimVendor
    ADD CONSTRAINT UQ_DimVendor_VendorID
    UNIQUE (VendorID);

    PRINT 'Unique VendorID constraint created.';
END
ELSE
BEGIN
    PRINT 'Unique VendorID constraint already exists.';
END;
GO

--Validating the DimVendor table
--Check the loaded row count
SELECT
    (SELECT COUNT(*)
     FROM AdventureWorks2025.Purchasing.Vendor) AS SourceVendorCount,

    (SELECT COUNT(*)
     FROM Dim.DimVendor) AS WarehouseVendorCount;
GO

--Check for duplicate business keys
SELECT
    VendorID,
    COUNT(*) AS DuplicateCount
FROM Dim.DimVendor
GROUP BY VendorID
HAVING COUNT(*) > 1;
GO

--Check missing vendor keys and names
SELECT *
FROM Dim.DimVendor
WHERE VendorKey IS NULL
   OR VendorID IS NULL
   OR VendorName IS NULL
   OR LTRIM(RTRIM(VendorName)) = '';
GO