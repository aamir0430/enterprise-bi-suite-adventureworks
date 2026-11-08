USE EnterpriseBI_DW
GO

-- 1. Verifying all Supply Chain warehouse row counts

SELECT 'DimLocation' AS TableName, COUNT(*) AS TotalRows
FROM Dim.DimLocation

UNION ALL

SELECT 'DimScrapReason', COUNT(*)
FROM Dim.DimScrapReason

UNION ALL

SELECT 'DimTransactionType', COUNT(*)
FROM Dim.DimTransactionType

UNION ALL

SELECT 'FactInventorySnapshot', COUNT(*)
FROM Fact.FactInventorySnapshot

UNION ALL

SELECT 'FactInventoryTransaction', COUNT(*)
FROM Fact.FactInventoryTransaction

UNION ALL

SELECT 'FactWorkOrder', COUNT(*)
FROM Fact.FactWorkOrder;
GO

-- 2. Verifying duplicate records

/* Inventory snapshot */
SELECT ProductKey, LocationKey, Shelf, Bin,
       COUNT(*) AS DuplicateCount
FROM Fact.FactInventorySnapshot
GROUP BY ProductKey, LocationKey, Shelf, Bin
HAVING COUNT(*) > 1;

/* Inventory transactions */
SELECT TransactionID, COUNT(*) AS DuplicateCount
FROM Fact.FactInventoryTransaction
GROUP BY TransactionID
HAVING COUNT(*) > 1;

/* Work orders */
SELECT WorkOrderID, COUNT(*) AS DuplicateCount
FROM Fact.FactWorkOrder
GROUP BY WorkOrderID
HAVING COUNT(*) > 1;
GO