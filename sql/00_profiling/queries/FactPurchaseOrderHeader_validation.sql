USE EnterpriseBI_DW
GO

-- Validating the table in SQL Server:

-- 1. Checking row count and primary-key uniqueness
SELECT
    COUNT(*) AS TotalRows,
    COUNT(DISTINCT PurchaseOrderHeaderKey) AS DistinctHeaderKeys,
    COUNT(DISTINCT PurchaseOrderID) AS DistinctPurchaseOrderIDs,
    COUNT(*) - COUNT(PurchaseOrderHeaderKey) AS NullHeaderKeys,
    COUNT(*) - COUNT(PurchaseOrderID) AS NullPurchaseOrderIDs
FROM Fact.FactPurchaseOrderHeader;

-- 2. Checking duplicate purchase orders
SELECT
    PurchaseOrderID,
    COUNT(*) AS DuplicateCount
FROM Fact.FactPurchaseOrderHeader
GROUP BY PurchaseOrderID
HAVING COUNT(*) > 1;

-- 3. Checking foreign-key integrity
SELECT 'VendorKey' AS ColumnName, COUNT(*) AS InvalidRows
FROM Fact.FactPurchaseOrderHeader f
LEFT JOIN Dim.DimVendor d
    ON f.VendorKey = d.VendorKey
WHERE d.VendorKey IS NULL

UNION ALL

SELECT 'EmployeeKey', COUNT(*)
FROM Fact.FactPurchaseOrderHeader f
LEFT JOIN Dim.DimEmployee d
    ON f.EmployeeKey = d.EmployeeKey
WHERE d.EmployeeKey IS NULL

UNION ALL

SELECT 'ShipMethodKey', COUNT(*)
FROM Fact.FactPurchaseOrderHeader f
LEFT JOIN Dim.DimShipMethod d
    ON f.ShipMethodKey = d.ShipMethodKey
WHERE d.ShipMethodKey IS NULL

UNION ALL

SELECT 'OrderDateKey', COUNT(*)
FROM Fact.FactPurchaseOrderHeader f
LEFT JOIN Dim.DimDate d
    ON f.OrderDateKey = d.DateKey
WHERE d.DateKey IS NULL

UNION ALL

SELECT 'ShipDateKey', COUNT(*)
FROM Fact.FactPurchaseOrderHeader f
LEFT JOIN Dim.DimDate d
    ON f.ShipDateKey = d.DateKey
WHERE d.DateKey IS NULL;

-- 4. Validating financial calculations
SELECT *
FROM Fact.FactPurchaseOrderHeader
WHERE ABS(TotalDue - (Subtotal + TaxAmt + Freight)) > 0.01;

-- 5. Checking date sequence
SELECT *
FROM Fact.FactPurchaseOrderHeader
WHERE ShipDateKey < OrderDateKey;

-- 6. Checking monetary values
SELECT *
FROM Fact.FactPurchaseOrderHeader
WHERE Subtotal < 0
   OR TaxAmt < 0
   OR Freight < 0
   OR TotalDue < 0;