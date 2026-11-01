USE EnterpriseBI_DW
GO

-- Validating address keys and duplicates:

-- 1. Validating row count and keys
SELECT
    COUNT(*) AS TotalRows,
    COUNT(DISTINCT AddressKey) AS DistinctAddressKeys,
    COUNT(DISTINCT AddressID) AS DistinctAddressIDs,
    SUM(CASE WHEN AddressKey IS NULL THEN 1 ELSE 0 END)
        AS NullAddressKeys,
    SUM(CASE WHEN AddressID IS NULL THEN 1 ELSE 0 END)
        AS NullAddressIDs
FROM Dim.DimAddress;

-- 2. Checking duplicate AddressID values
SELECT
    AddressID,
    COUNT(*) AS DuplicateCount
FROM Dim.DimAddress
GROUP BY AddressID
HAVING COUNT(*) > 1;

-- 3. Checking duplicate AddressKey values
SELECT
    AddressKey,
    COUNT(*) AS DuplicateCount
FROM Dim.DimAddress
GROUP BY AddressKey
HAVING COUNT(*) > 1;

-- Validating geographic information:

-- 1. Checking country code and country name consistency
SELECT
    CountryRegionCode,
    COUNT(DISTINCT CountryName) AS CountryNameCount
FROM Dim.DimAddress
GROUP BY CountryRegionCode
HAVING COUNT(DISTINCT CountryName) > 1;

-- 2. Checking state/province consistency
SELECT
    StateProvinceID,
    COUNT(DISTINCT StateProvinceCode) AS CodeCount,
    COUNT(DISTINCT StateProvinceName) AS NameCount
FROM Dim.DimAddress
GROUP BY StateProvinceID
HAVING COUNT(DISTINCT StateProvinceCode) > 1
    OR COUNT(DISTINCT StateProvinceName) > 1;

-- 3. Checking missing geographic attributes
SELECT *
FROM Dim.DimAddress
WHERE City IS NULL
   OR PostalCode IS NULL
   OR CountryRegionCode IS NULL
   OR CountryName IS NULL;

-- Validating territory assignments:

SELECT DISTINCT
    A.TerritoryID
FROM Dim.DimAddress A
LEFT JOIN Dim.DimSalesTerritory T
    ON A.TerritoryID = T.TerritoryID
WHERE T.TerritoryID IS NULL;
