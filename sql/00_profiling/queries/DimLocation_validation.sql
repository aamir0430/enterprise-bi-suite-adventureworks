USE EnterpriseBI_DW
GO

-- Validation of DimLocation table:

-- 1. Checking row count and key uniqueness
SELECT
    COUNT(*) AS TotalRows,
    COUNT(DISTINCT LocationKey) AS DistinctLocationKeys,
    COUNT(DISTINCT LocationID) AS DistinctLocationIDs,
    COUNT(*) - COUNT(LocationKey) AS NullLocationKeys,
    COUNT(*) - COUNT(LocationID) AS NullLocationIDs
FROM Dim.DimLocation;

-- 2. Checking duplicate location IDs
SELECT
    LocationID,
    COUNT(*) AS DuplicateCount
FROM Dim.DimLocation
GROUP BY LocationID
HAVING COUNT(*) > 1;

-- 3. Checking duplicate location names
SELECT
    LocationName,
    COUNT(*) AS DuplicateCount
FROM Dim.DimLocation
GROUP BY LocationName
HAVING COUNT(*) > 1;

-- 4. Checking missing attributes
SELECT *
FROM Dim.DimLocation
WHERE LocationName IS NULL
   OR CostRate IS NULL
   OR Availability IS NULL;