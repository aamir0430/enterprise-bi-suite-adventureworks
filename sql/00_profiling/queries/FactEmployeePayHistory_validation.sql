USE EnterpriseBI_DW
GO

-- Validation of FactEmployeePayHistory table:

-- 1. Checking row count and key uniqueness
SELECT
    COUNT(*) AS TotalRows,
    COUNT(DISTINCT PayHistoryFactKey) AS DistinctFactKeys,
    COUNT(DISTINCT EmployeeKey) AS DistinctEmployees,
    COUNT(DISTINCT PayFrequencyKey) AS DistinctPayFrequencies,
    COUNT(DISTINCT RateChangeDateKey) AS DistinctRateChangeDates
FROM Fact.FactEmployeePayHistory;

-- 2. Checking duplicate fact keys
SELECT
    PayHistoryFactKey,
    COUNT(*) AS DuplicateCount
FROM Fact.FactEmployeePayHistory
GROUP BY PayHistoryFactKey
HAVING COUNT(*) > 1;

-- 3. Checking duplicate employee/date combinations
SELECT
    EmployeeKey,
    RateChangeDateKey,
    COUNT(*) AS DuplicateCount
FROM Fact.FactEmployeePayHistory
GROUP BY
    EmployeeKey,
    RateChangeDateKey
HAVING COUNT(*) > 1;

-- 4. Validating foreign-key relationships
SELECT
    'EmployeeKey' AS ColumnName,
    COUNT(*) AS InvalidRows
FROM Fact.FactEmployeePayHistory F
LEFT JOIN Dim.DimEmployee D
    ON F.EmployeeKey = D.EmployeeKey
WHERE D.EmployeeKey IS NULL

UNION ALL

SELECT
    'PayFrequencyKey',
    COUNT(*)
FROM Fact.FactEmployeePayHistory F
LEFT JOIN Dim.DimPayFrequency D
    ON F.PayFrequencyKey = D.PayFrequencyKey
WHERE D.PayFrequencyKey IS NULL

UNION ALL

SELECT
    'RateChangeDateKey',
    COUNT(*)
FROM Fact.FactEmployeePayHistory F
LEFT JOIN Dim.DimDate D
    ON F.RateChangeDateKey = D.DateKey
WHERE D.DateKey IS NULL;

-- 5. Checking rate values
SELECT *
FROM Fact.FactEmployeePayHistory
WHERE Rate <= 0;

-- 6. Checking the rate distribution
SELECT
    MIN(Rate) AS MinimumRate,
    MAX(Rate) AS MaximumRate,
    AVG(Rate) AS AverageRate,
    COUNT(DISTINCT Rate) AS DistinctRates
FROM Fact.FactEmployeePayHistory;

-- 7. Checking pay frequency distribution
SELECT
    D.PayFrequencyCode,
    D.PayFrequencyName,
    COUNT(*) AS PayHistoryRecords,
    COUNT(DISTINCT F.EmployeeKey) AS Employees
FROM Fact.FactEmployeePayHistory F
INNER JOIN Dim.DimPayFrequency D
    ON F.PayFrequencyKey = D.PayFrequencyKey
GROUP BY
    D.PayFrequencyCode,
    D.PayFrequencyName
ORDER BY D.PayFrequencyCode;