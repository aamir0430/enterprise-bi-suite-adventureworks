USE EnterpriseBI_DW
GO

-- Validating the shift dimension:

-- 1. Checking row count and key uniqueness
SELECT
    COUNT(*) AS TotalRows,
    COUNT(DISTINCT ShiftKey) AS DistinctShiftKeys,
    COUNT(DISTINCT ShiftID) AS DistinctShiftIDs,
    COUNT(*) - COUNT(ShiftKey) AS NullShiftKeys,
    COUNT(*) - COUNT(ShiftID) AS NullShiftIDs
FROM Dim.DimShift;

-- 2. Checking duplicate shift IDs
SELECT
    ShiftID,
    COUNT(*) AS DuplicateCount
FROM Dim.DimShift
GROUP BY ShiftID
HAVING COUNT(*) > 1;

-- 3. Checking duplicate shift names
SELECT
    ShiftName,
    COUNT(*) AS DuplicateCount
FROM Dim.DimShift
GROUP BY ShiftName
HAVING COUNT(*) > 1;

-- 4. Checking missing values
SELECT *
FROM Dim.DimShift
WHERE ShiftName IS NULL
   OR StartTime IS NULL
   OR EndTime IS NULL;

-- 5. Checking time consistency
SELECT *
FROM Dim.DimShift
WHERE StartTime = EndTime;