USE EnterpriseBI_DW;
GO

-- 1. Verifying warehouse and source row counts

SELECT
    'FactEmployeePayHistory' AS TableName,
    COUNT(*) AS WarehouseRows
FROM Fact.FactEmployeePayHistory;

SELECT
    'EmployeePayHistory' AS SourceTable,
    COUNT(*) AS SourceRows
FROM AdventureWorks2025.HumanResources.EmployeePayHistory;

-- 2. Checking duplicate records

SELECT
    EmployeeKey,
    PayFrequencyKey,
    RateChangeDateKey,
    COUNT(*) AS DuplicateCount
FROM Fact.FactEmployeePayHistory
GROUP BY
    EmployeeKey,
    PayFrequencyKey,
    RateChangeDateKey
HAVING COUNT(*) > 1;

-- 3. Checking missing employee mappings

SELECT
    eph.BusinessEntityID AS MissingEmployeeID
FROM AdventureWorks2025.HumanResources.EmployeePayHistory AS eph
LEFT JOIN Dim.DimEmployee AS de
    ON de.EmployeeID = eph.BusinessEntityID
WHERE de.EmployeeKey IS NULL;

-- 4. Checking missing pay frequency mappings

SELECT
    eph.PayFrequency AS MissingPayFrequency
FROM AdventureWorks2025.HumanResources.EmployeePayHistory AS eph
LEFT JOIN Dim.DimPayFrequency AS dpf
    ON dpf.PayFrequencyCode = eph.PayFrequency
WHERE dpf.PayFrequencyKey IS NULL;

-- 5. Checking missing rate change date mappings

SELECT
    eph.BusinessEntityID,
    eph.RateChangeDate AS MissingRateChangeDate
FROM AdventureWorks2025.HumanResources.EmployeePayHistory AS eph
LEFT JOIN Dim.DimDate AS dd
    ON dd.FullDate = CONVERT(date, eph.RateChangeDate)
WHERE dd.DateKey IS NULL;

-- 6. Checking NULL foreign keys and rate values

SELECT *
FROM Fact.FactEmployeePayHistory
WHERE EmployeeKey IS NULL
   OR PayFrequencyKey IS NULL
   OR RateChangeDateKey IS NULL
   OR Rate IS NULL;

-- 7. Checking invalid or non-positive pay rates

SELECT *
FROM Fact.FactEmployeePayHistory
WHERE Rate <= 0;

GO