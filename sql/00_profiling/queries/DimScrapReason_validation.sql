USE EnterpriseBI_DW
GO

-- Validating the DimScrapReason table:

-- 1. Checking row count and key uniqueness
SELECT
    COUNT(*) AS TotalRows,
    COUNT(DISTINCT ScrapReasonKey) AS DistinctScrapReasonKeys,
    COUNT(DISTINCT ScrapReasonID) AS DistinctScrapReasonIDs,
    COUNT(DISTINCT ScrapReasonName) AS DistinctScrapReasonNames,
    COUNT(*) - COUNT(ScrapReasonKey) AS NullScrapReasonKeys
FROM Dim.DimScrapReason;

-- 2. Checking the duplicate scrap reason IDs
SELECT
    ScrapReasonID,
    COUNT(*) AS DuplicateCount
FROM Dim.DimScrapReason
GROUP BY ScrapReasonID
HAVING COUNT(*) > 1;

-- 3. Checking duplicate scrap reason names
SELECT
    ScrapReasonName,
    COUNT(*) AS DuplicateCount
FROM Dim.DimScrapReason
GROUP BY ScrapReasonName
HAVING COUNT(*) > 1;

-- 4. Checking missing values
SELECT *
FROM Dim.DimScrapReason
WHERE ScrapReasonName IS NULL;