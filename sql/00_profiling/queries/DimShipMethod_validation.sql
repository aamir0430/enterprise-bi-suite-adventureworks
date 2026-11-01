USE EnterpriseBI_DW
GO

-- Validating primary and business keys:

-- 1. Validating row count and keys
SELECT
    COUNT(*) AS TotalRows,
    COUNT(DISTINCT ShipMethodKey) AS DistinctShipMethodKeys,
    COUNT(DISTINCT ShipMethodID) AS DistinctShipMethodIDs,
    SUM(CASE WHEN ShipMethodKey IS NULL THEN 1 ELSE 0 END)
        AS NullShipMethodKeys,
    SUM(CASE WHEN ShipMethodID IS NULL THEN 1 ELSE 0 END)
        AS NullShipMethodIDs
FROM Dim.DimShipMethod;

-- 2. Checking duplicate shipping method IDs
SELECT
    ShipMethodID,
    COUNT(*) AS DuplicateCount
FROM Dim.DimShipMethod
GROUP BY ShipMethodID
HAVING COUNT(*) > 1;

-- 3. Checking duplicate shipping method names
SELECT
    ShipMethodName,
    COUNT(*) AS DuplicateCount
FROM Dim.DimShipMethod
GROUP BY ShipMethodName
HAVING COUNT(*) > 1;

-- Validating shipping costs

-- 1. Checking negative shipping costs
SELECT *
FROM Dim.DimShipMethod
WHERE ShipBase < 0
   OR ShipRate < 0;

-- 2. Reviewing shipping cost values
SELECT
    ShipMethodID,
    ShipMethodName,
    ShipBase,
    ShipRate
FROM Dim.DimShipMethod
ORDER BY ShipMethodID;