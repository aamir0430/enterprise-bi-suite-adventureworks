USE EnterpriseBI_DW
GO

-- Validation of FactInventorySnapshot table:

-- 1. Checking row count and key uniqueness
SELECT
    COUNT(*) AS TotalRows,
    COUNT(DISTINCT InventorySnapshotKey) AS DistinctSnapshotKeys,
    COUNT(DISTINCT ProductKey) AS DistinctProducts,
    COUNT(DISTINCT LocationKey) AS DistinctLocations,
    COUNT(DISTINCT SnapshotDateKey) AS DistinctSnapshotDates
FROM Fact.FactInventorySnapshot;

-- 2. Checking duplicate inventory snapshot keys
SELECT
    InventorySnapshotKey,
    COUNT(*) AS DuplicateCount
FROM Fact.FactInventorySnapshot
GROUP BY InventorySnapshotKey
HAVING COUNT(*) > 1;

-- Checking duplicate inventory grain
SELECT
    ProductKey,
    LocationKey,
    SnapshotDateKey,
    Shelf,
    Bin,
    COUNT(*) AS DuplicateCount
FROM Fact.FactInventorySnapshot
GROUP BY
    ProductKey,
    LocationKey,
    SnapshotDateKey,
    Shelf,
    Bin
HAVING COUNT(*) > 1;

-- 4. Checking missing values
SELECT *
FROM Fact.FactInventorySnapshot
WHERE InventorySnapshotKey IS NULL
   OR ProductKey IS NULL
   OR LocationKey IS NULL
   OR SnapshotDateKey IS NULL
   OR Shelf IS NULL
   OR Bin IS NULL
   OR Quantity IS NULL;

-- 5. Checking negative and zero quantities
SELECT
    SUM(CASE WHEN Quantity < 0 THEN 1 ELSE 0 END) AS NegativeQuantityRows,
    SUM(CASE WHEN Quantity = 0 THEN 1 ELSE 0 END) AS ZeroQuantityRows,
    MIN(Quantity) AS MinimumQuantity,
    MAX(Quantity) AS MaximumQuantity
FROM Fact.FactInventorySnapshot;

-- 6. Checking dimension foreign keys
-- Product key validation
SELECT F.ProductKey
FROM Fact.FactInventorySnapshot F
LEFT JOIN Dim.DimProduct D
    ON F.ProductKey = D.ProductKey
WHERE D.ProductKey IS NULL;

-- Location key validation
SELECT F.LocationKey
FROM Fact.FactInventorySnapshot F
LEFT JOIN Dim.DimLocation D
    ON F.LocationKey = D.LocationKey
WHERE D.LocationKey IS NULL;

-- Snapshot date validation
SELECT F.SnapshotDateKey
FROM Fact.FactInventorySnapshot F
LEFT JOIN Dim.DimDate D
    ON F.SnapshotDateKey = D.DateKey
WHERE D.DateKey IS NULL;