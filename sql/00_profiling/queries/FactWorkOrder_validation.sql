USE EnterpriseBI_DW
GO

-- Validation of FactWorkOrder table:

-- 1. Checking row count and key uniqueness
SELECT
    COUNT(*) AS TotalRows,
    COUNT(DISTINCT WorkOrderFactKey) AS DistinctFactKeys,
    COUNT(DISTINCT WorkOrderID) AS DistinctWorkOrderIDs,
    COUNT(DISTINCT ProductKey) AS DistinctProducts,
    COUNT(DISTINCT ScrapReasonKey) AS DistinctScrapReasons
FROM Fact.FactWorkOrder;

-- 2. Checking duplicate work orders
SELECT
    WorkOrderID,
    COUNT(*) AS DuplicateCount
FROM Fact.FactWorkOrder
GROUP BY WorkOrderID
HAVING COUNT(*) > 1;

-- 3. Checking missing mandatory values
SELECT *
FROM Fact.FactWorkOrder
WHERE WorkOrderFactKey IS NULL
   OR WorkOrderID IS NULL
   OR ProductKey IS NULL
   OR StartDateKey IS NULL
   OR EndDateKey IS NULL
   OR DueDateKey IS NULL
   OR OrderQty IS NULL
   OR StockedQty IS NULL
   OR ScrappedQty IS NULL
   OR ProductionDurationDays IS NULL;

-- 4. Validating product relationships
SELECT F.ProductKey
FROM Fact.FactWorkOrder F
LEFT JOIN Dim.DimProduct D
    ON F.ProductKey = D.ProductKey
WHERE D.ProductKey IS NULL;

-- 5. Validating scrap reason relationships 
SELECT DISTINCT F.ScrapReasonKey
FROM Fact.FactWorkOrder F
LEFT JOIN Dim.DimScrapReason D
    ON F.ScrapReasonKey = D.ScrapReasonKey
WHERE F.ScrapReasonKey IS NOT NULL
  AND D.ScrapReasonKey IS NULL;

-- 6. Validating all three date relationships
-- Start date
SELECT F.StartDateKey
FROM Fact.FactWorkOrder F
LEFT JOIN Dim.DimDate D
    ON F.StartDateKey = D.DateKey
WHERE D.DateKey IS NULL;

-- End date
SELECT F.EndDateKey
FROM Fact.FactWorkOrder F
LEFT JOIN Dim.DimDate D
    ON F.EndDateKey = D.DateKey
WHERE D.DateKey IS NULL;

-- Due date
SELECT F.DueDateKey
FROM Fact.FactWorkOrder F
LEFT JOIN Dim.DimDate D
    ON F.DueDateKey = D.DateKey
WHERE D.DateKey IS NULL;

-- 7. Checking production quantity consistency
SELECT *
FROM Fact.FactWorkOrder
WHERE OrderQty < 0
   OR StockedQty < 0
   OR ScrappedQty < 0
   OR StockedQty + ScrappedQty > OrderQty;

-- 8. Checking date consistency
SELECT *
FROM Fact.FactWorkOrder
WHERE StartDateKey > DueDateKey
   OR StartDateKey > EndDateKey
   OR EndDateKey > DueDateKey;

-- Verifying EndDateKey against the original source:
USE AdventureWorks2025
GO

SELECT
    COUNT(*) AS TotalWorkOrders,
    SUM(CASE WHEN EndDate IS NULL THEN 1 ELSE 0 END)
        AS WorkOrdersWithoutEndDate,
    SUM(CASE WHEN EndDate IS NOT NULL THEN 1 ELSE 0 END)
        AS WorkOrdersWithEndDate
FROM Production.WorkOrder;

USE EnterpriseBI_DW
GO

SELECT
    COUNT(*) AS TotalWarehouseRows,
    SUM(CASE WHEN EndDateKey IS NULL THEN 1 ELSE 0 END)
        AS RowsWithoutEndDateKey,
    SUM(CASE WHEN EndDateKey IS NOT NULL THEN 1 ELSE 0 END)
        AS RowsWithEndDateKey
FROM Fact.FactWorkOrder;

