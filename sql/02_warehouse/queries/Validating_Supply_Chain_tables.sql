USE EnterpriseBI_DW;
GO

--Checking dimension and fact row counts
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
FROM Fact.FactWorkOrder

UNION ALL
SELECT 'FactPurchaseOrders', COUNT(*)
FROM Fact.FactPurchaseOrders;
GO

--Comparing source and warehouse record counts
SELECT
    'Inventory Snapshot' AS DataArea,
    (SELECT COUNT(*)
     FROM AdventureWorks2025.Production.ProductInventory) AS SourceRows,
    (SELECT COUNT(*)
     FROM Fact.FactInventorySnapshot) AS WarehouseRows

UNION ALL

SELECT
    'Inventory Transactions',
    (SELECT COUNT(*)
     FROM AdventureWorks2025.Production.TransactionHistory),
    (SELECT COUNT(*)
     FROM Fact.FactInventoryTransaction)

UNION ALL

SELECT
    'Work Orders',
    (SELECT COUNT(*)
     FROM AdventureWorks2025.Production.WorkOrder),
    (SELECT COUNT(*)
     FROM Fact.FactWorkOrder)

UNION ALL

SELECT
    'Purchase Order Lines',
    (SELECT COUNT(*)
     FROM AdventureWorks2025.Purchasing.PurchaseOrderDetail),
    (SELECT COUNT(*)
     FROM Fact.FactPurchaseOrders);
GO

--Checking missing dimension keys
SELECT COUNT(*) AS MissingProductKeys
FROM Fact.FactInventorySnapshot
WHERE ProductKey IS NULL;

SELECT COUNT(*) AS MissingLocationKeys
FROM Fact.FactInventorySnapshot
WHERE LocationKey IS NULL;

SELECT COUNT(*) AS MissingTransactionTypeKeys
FROM Fact.FactInventoryTransaction
WHERE TransactionTypeKey IS NULL;

SELECT COUNT(*) AS MissingWorkOrderProductKeys
FROM Fact.FactWorkOrder
WHERE ProductKey IS NULL;
GO

--Validating inventory quantities
SELECT
    SUM(Quantity) AS TotalInventoryQuantity,
    COUNT(*) AS InventoryRecords,
    COUNT(DISTINCT ProductKey) AS Products,
    COUNT(DISTINCT LocationKey) AS Locations
FROM Fact.FactInventorySnapshot;
GO

--Validating inventory transactions
SELECT
    D.TransactionTypeName,
    COUNT(*) AS TotalTransactions,
    SUM(F.Quantity) AS TotalQuantity,
    SUM(F.ActualCost) AS TotalActualCost
FROM Fact.FactInventoryTransaction F
INNER JOIN Dim.DimTransactionType D
    ON F.TransactionTypeKey = D.TransactionTypeKey
GROUP BY D.TransactionTypeName;
GO

--Validating work orders
SELECT
    COUNT(*) AS TotalWorkOrders,
    SUM(OrderQty) AS TotalOrderedQuantity,
    SUM(StockedQty) AS TotalStockedQuantity,
    SUM(ScrappedQty) AS TotalScrappedQuantity,
    AVG(ProductionDurationDays) AS AverageProductionDays
FROM Fact.FactWorkOrder;
GO

--Checking invalid production dates
SELECT *
FROM Fact.FactWorkOrder
WHERE EndDateKey IS NOT NULL
  AND EndDateKey < StartDateKey;
GO

--Checking date coverage
SELECT F.SnapshotDateKey
FROM Fact.FactInventorySnapshot F
LEFT JOIN Dim.DimDate D
    ON F.SnapshotDateKey = D.DateKey
WHERE D.DateKey IS NULL;

SELECT F.TransactionDateKey
FROM Fact.FactInventoryTransaction F
LEFT JOIN Dim.DimDate D
    ON F.TransactionDateKey = D.DateKey
WHERE D.DateKey IS NULL;

SELECT F.StartDateKey
FROM Fact.FactWorkOrder F
LEFT JOIN Dim.DimDate D
    ON F.StartDateKey = D.DateKey
WHERE D.DateKey IS NULL;
GO