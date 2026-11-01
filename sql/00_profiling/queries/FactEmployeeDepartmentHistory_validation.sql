USE EnterpriseBI_DW
GO

-- Validating the FactEmployeeDepartmentHistory table:

-- 1. Checking row count and uniqueness
SELECT
    COUNT(*) AS TotalRows,
    COUNT(DISTINCT DepartmentHistoryFactKey) AS DistinctFactKeys,
    COUNT(DISTINCT EmployeeKey) AS DistinctEmployees,
    COUNT(DISTINCT StartDateKey) AS DistinctStartDates
FROM Fact.FactEmployeeDepartmentHistory;

-- 2. Checking duplicate assignment records
SELECT
    EmployeeKey,
    DepartmentKey,
    ShiftKey,
    StartDateKey,
    COUNT(*) AS DuplicateCount
FROM Fact.FactEmployeeDepartmentHistory
GROUP BY
    EmployeeKey,
    DepartmentKey,
    ShiftKey,
    StartDateKey
HAVING COUNT(*) > 1;

-- 3. Validating foreign key relationships
SELECT 'EmployeeKey' AS ColumnName, COUNT(*) AS InvalidRows
FROM Fact.FactEmployeeDepartmentHistory F
LEFT JOIN Dim.DimEmployee D
    ON F.EmployeeKey = D.EmployeeKey
WHERE D.EmployeeKey IS NULL

UNION ALL

SELECT 'DepartmentKey', COUNT(*)
FROM Fact.FactEmployeeDepartmentHistory F
LEFT JOIN Dim.DimDepartment D
    ON F.DepartmentKey = D.DepartmentKey
WHERE D.DepartmentKey IS NULL

UNION ALL

SELECT 'ShiftKey', COUNT(*)
FROM Fact.FactEmployeeDepartmentHistory F
LEFT JOIN Dim.DimShift D
    ON F.ShiftKey = D.ShiftKey
WHERE D.ShiftKey IS NULL

UNION ALL

SELECT 'StartDateKey', COUNT(*)
FROM Fact.FactEmployeeDepartmentHistory F
LEFT JOIN Dim.DimDate D
    ON F.StartDateKey = D.DateKey
WHERE D.DateKey IS NULL

UNION ALL

SELECT 'EndDateKey', COUNT(*)
FROM Fact.FactEmployeeDepartmentHistory F
LEFT JOIN Dim.DimDate D
    ON F.EndDateKey = D.DateKey
WHERE F.EndDateKey IS NOT NULL
  AND D.DateKey IS NULL;

-- 4. Checking assignment date sequence
SELECT *
FROM Fact.FactEmployeeDepartmentHistory
WHERE EndDateKey IS NOT NULL
  AND EndDateKey < StartDateKey;