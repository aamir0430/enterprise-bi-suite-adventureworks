USE EnterpriseBI_DW
GO

-- Validating keys and duplicates:

-- 1. Validating the row count and keys
SELECT
    COUNT(*) AS TotalRows,
    COUNT(DISTINCT SalesPersonKey) AS DistinctSalesPersonKeys,
    COUNT(DISTINCT SalesPersonID) AS DistinctSalesPersonIDs,
    SUM(CASE WHEN SalesPersonKey IS NULL THEN 1 ELSE 0 END)
        AS NullSalesPersonKeys,
    SUM(CASE WHEN SalesPersonID IS NULL THEN 1 ELSE 0 END)
        AS NullSalesPersonIDs
FROM Dim.DimSalesPerson;

-- 2. Checking duplicate salesperson IDs
SELECT
    SalesPersonID,
    COUNT(*) AS DuplicateCount
FROM Dim.DimSalesPerson
GROUP BY SalesPersonID
HAVING COUNT(*) > 1;

-- 3. Checking duplicate salesperson names
SELECT
    SalesPersonName,
    COUNT(*) AS DuplicateCount
FROM Dim.DimSalesPerson
GROUP BY SalesPersonName
HAVING COUNT(*) > 1;

-- Validating territory and quota assignments:

-- 1. Reviewing salespeople without a territory
SELECT
    SalesPersonID,
    SalesPersonName,
    JobTitle,
    TerritoryID,
    SalesQuota
FROM Dim.DimSalesPerson
WHERE TerritoryID IS NULL;

-- 2. Reviewing salesperson without a sales quota
SELECT
    SalesPersonID,
    SalesPersonName,
    TerritoryID,
    SalesQuota
FROM Dim.DimSalesPerson
WHERE SalesQuota IS NULL;

-- 3. Checking invalid negative values
SELECT *
FROM Dim.DimSalesPerson
WHERE
    SalesQuota < 0
    OR Bonus < 0
    OR CommissionPct < 0
    OR CommissionPct > 1
    OR SalesYTD < 0
    OR SalesLastYear < 0;