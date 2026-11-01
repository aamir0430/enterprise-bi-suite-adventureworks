USE EnterpriseBI_DW
GO

-- Validating FactPurchaseOrders table:

-- 1. Checking row count and key uniqueness
SELECT
    COUNT(*) AS TotalRows,
    COUNT(DISTINCT PurchaseFactKey) AS DistinctFactKeys,
    COUNT(DISTINCT PurchaseOrderDetailID) AS DistinctDetailIDs,
    COUNT(DISTINCT PurchaseOrderID) AS DistinctPurchaseOrders
FROM Fact.FactPurchaseOrders;

-- 2. Checking duplicate detail IDs
SELECT
    PurchaseOrderDetailID,
    COUNT(*) AS DuplicateCount
FROM Fact.FactPurchaseOrders
GROUP BY PurchaseOrderDetailID
HAVING COUNT(*) > 1;

-- 3. Validating foreign keys
SELECT 'VendorKey' AS ColumnName, COUNT(*) AS InvalidRows
FROM Fact.FactPurchaseOrders f
LEFT JOIN Dim.DimVendor d
    ON f.VendorKey = d.VendorKey
WHERE d.VendorKey IS NULL

UNION ALL

SELECT 'ProductKey', COUNT(*)
FROM Fact.FactPurchaseOrders f
LEFT JOIN Dim.DimProduct d
    ON f.ProductKey = d.ProductKey
WHERE d.ProductKey IS NULL

UNION ALL

SELECT 'ShipMethodKey', COUNT(*)
FROM Fact.FactPurchaseOrders f
LEFT JOIN Dim.DimShipMethod d
    ON f.ShipMethodKey = d.ShipMethodKey
WHERE d.ShipMethodKey IS NULL

UNION ALL

SELECT 'OrderDateKey', COUNT(*)
FROM Fact.FactPurchaseOrders f
LEFT JOIN Dim.DimDate d
    ON f.OrderDateKey = d.DateKey
WHERE d.DateKey IS NULL

UNION ALL

SELECT 'DueDateKey', COUNT(*)
FROM Fact.FactPurchaseOrders f
LEFT JOIN Dim.DimDate d
    ON f.DueDateKey = d.DateKey
WHERE d.DateKey IS NULL;

-- 4. Validating quantity calculations
SELECT *
FROM Fact.FactPurchaseOrders
WHERE OrderQty < 0
   OR ReceivedQty < 0
   OR RejectedQty < 0
   OR StockedQty < 0
   OR ReceivedQty > OrderQty
   OR RejectedQty > ReceivedQty
   OR StockedQty > ReceivedQty;

-- 5. Validating monetary calculations
SELECT *
FROM Fact.FactPurchaseOrders
WHERE ABS(LineTotal - (OrderQty * UnitPrice)) > 0.01
   OR ABS(OrderedAmount - LineTotal) > 0.01;

-- Checking due dates
SELECT *
FROM Fact.FactPurchaseOrders
WHERE DueDateKey < OrderDateKey;