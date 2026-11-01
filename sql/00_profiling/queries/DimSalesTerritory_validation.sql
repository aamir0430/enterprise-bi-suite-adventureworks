USE EnterpriseBI_DW
GO

-- Validating primary keys and duplicates:

-- 1. Validating the tables and keys
SELECT
    COUNT(*) AS TotalRows,
    COUNT(DISTINCT SalesTerritoryKey) AS DistinctTerritoryKeys,
    COUNT(DISTINCT TerritoryID) AS DistinctTerritoryIDs,
    SUM(CASE WHEN SalesTerritoryKey IS NULL THEN 1 ELSE 0 END)
        AS NullTerritoryKeys,
    SUM(CASE WHEN TerritoryID IS NULL THEN 1 ELSE 0 END)
        AS NullTerritoryIDs
FROM Dim.DimSalesTerritory;

-- 2. Checking duplicate territory IDs
SELECT
    TerritoryID,
    COUNT(*) AS DuplicateCount
FROM Dim.DimSalesTerritory
GROUP BY TerritoryID
HAVING COUNT(*) > 1;

-- 3. Checking duplicate territory names
SELECT
    TerritoryName,
    COUNT(*) AS DuplicateCount
FROM Dim.DimSalesTerritory
GROUP BY TerritoryName
HAVING COUNT(*) > 1;

-- Validating sales and cost values:

-- 1. Checking whether any financial values are negative
SELECT *
FROM Dim.DimSalesTerritory
WHERE
    SalesYTD < 0
    OR SalesLastYear < 0
    OR CostYTD < 0
    OR CostLastYear < 0;

-- 2. Investigating the identical cost values
SELECT
    CostYTD,
    CostLastYear,
    COUNT(*) AS TerritoryCount
FROM Dim.DimSalesTerritory
GROUP BY CostYTD, CostLastYear;

-- 3. Comparing the territory count in the previous investigating result with the source table
SELECT
    TerritoryID,
    Name,
    CostYTD,
    CostLastYear
FROM AdventureWorks2025.Sales.SalesTerritory
ORDER BY TerritoryID;

