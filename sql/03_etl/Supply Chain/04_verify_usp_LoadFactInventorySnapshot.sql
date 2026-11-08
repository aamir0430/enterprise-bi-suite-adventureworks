USE EnterpriseBI_DW
GO

-- 1. Verifying warehouse row counts

SELECT
    'FactInventorySnapshot' AS TableName,
    COUNT(*) AS WarehouseRows
FROM Fact.FactInventorySnapshot;

-- 2. Verifying source row counts

SELECT
    'Production.ProductInventory' AS SourceTable,
    COUNT(*) AS SourceRows
FROM AdventureWorks2025.Production.ProductInventory;
GO

-- 3. Checking duplicate inventory records

SELECT
    ProductKey,
    LocationKey,
    Shelf,
    Bin,
    COUNT(*) AS DuplicateCount
FROM Fact.FactInventorySnapshot
GROUP BY
    ProductKey,
    LocationKey,
    Shelf,
    Bin
HAVING COUNT(*) > 1;
GO

-- 4. Checking missing product mappings

SELECT
    pi.ProductID AS MissingProductID
FROM AdventureWorks2025.Production.ProductInventory AS pi
LEFT JOIN Dim.DimProduct AS dp
    ON dp.ProductID = pi.ProductID
WHERE dp.ProductKey IS NULL;
GO

-- 5. Checking missing location mappings

SELECT
    pi.LocationID AS MissingLocationID
FROM AdventureWorks2025.Production.ProductInventory AS pi
LEFT JOIN Dim.DimLocation AS dl
    ON dl.LocationID = pi.LocationID
WHERE dl.LocationKey IS NULL;
GO

-- 6. Checking NULL foreign keys and inventory values

SELECT *
FROM Fact.FactInventorySnapshot
WHERE ProductKey IS NULL
   OR LocationKey IS NULL
   OR SnapshotDateKey IS NULL
   OR Quantity IS NULL;
GO