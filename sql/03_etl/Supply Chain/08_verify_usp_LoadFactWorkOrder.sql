USE EnterpriseBI_DW
GO

-- 1. Verifying warehouse row counts

SELECT
    'FactWorkOrder' AS TableName,
    COUNT(*) AS WarehouseRows
FROM Fact.FactWorkOrder;

-- 2. Verifying source row counts

SELECT
    'Production.WorkOrder' AS SourceTable,
    COUNT(*) AS SourceRows
FROM AdventureWorks2025.Production.WorkOrder;
GO

-- 3. Checking duplicate work orders

SELECT
    WorkOrderID,
    COUNT(*) AS DuplicateCount
FROM Fact.FactWorkOrder
GROUP BY WorkOrderID
HAVING COUNT(*) > 1;
GO

-- 4. Checking missing product mappings

SELECT
    wo.ProductID AS MissingProductID
FROM AdventureWorks2025.Production.WorkOrder AS wo
LEFT JOIN Dim.DimProduct AS dp
    ON dp.ProductID = wo.ProductID
WHERE dp.ProductKey IS NULL;
GO

-- 5. Checking missing scrap reason mappings

SELECT
    wo.ScrapReasonID AS MissingScrapReasonID
FROM AdventureWorks2025.Production.WorkOrder AS wo
LEFT JOIN Dim.DimScrapReason AS sr
    ON sr.ScrapReasonID = wo.ScrapReasonID
WHERE wo.ScrapReasonID IS NOT NULL
  AND sr.ScrapReasonKey IS NULL;
GO

-- 6. Checking missing date mappings

/* Start dates */
SELECT wo.WorkOrderID, wo.StartDate AS MissingStartDate
FROM AdventureWorks2025.Production.WorkOrder AS wo
LEFT JOIN Dim.DimDate AS dd
    ON dd.FullDate = CONVERT(date, wo.StartDate)
WHERE dd.DateKey IS NULL;

/* Due dates */
SELECT wo.WorkOrderID, wo.DueDate AS MissingDueDate
FROM AdventureWorks2025.Production.WorkOrder AS wo
LEFT JOIN Dim.DimDate AS dd
    ON dd.FullDate = CONVERT(date, wo.DueDate)
WHERE dd.DateKey IS NULL;

/* End dates */
SELECT wo.WorkOrderID, wo.EndDate AS MissingEndDate
FROM AdventureWorks2025.Production.WorkOrder AS wo
LEFT JOIN Dim.DimDate AS dd
    ON dd.FullDate = CONVERT(date, wo.EndDate)
WHERE wo.EndDate IS NOT NULL
  AND dd.DateKey IS NULL;
GO

-- 7. Checking NULL required keys and measures

SELECT *
FROM Fact.FactWorkOrder
WHERE WorkOrderID IS NULL
   OR ProductKey IS NULL
   OR StartDateKey IS NULL
   OR DueDateKey IS NULL
   OR OrderQty IS NULL
   OR StockedQty IS NULL
   OR ScrappedQty IS NULL;
GO