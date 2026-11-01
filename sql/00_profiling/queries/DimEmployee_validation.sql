USE EnterpriseBI_DW
GO

-- Validating the DimEmployee table:

-- 1. Checking row count and key uniqueness
SELECT
    COUNT(*) AS TotalRows,
    COUNT(DISTINCT EmployeeKey) AS DistinctEmployeeKeys,
    COUNT(DISTINCT EmployeeID) AS DistinctEmployeeIDs,
    COUNT(*) - COUNT(EmployeeKey) AS NullEmployeeKeys,
    COUNT(*) - COUNT(EmployeeID) AS NullEmployeeIDs
FROM Dim.DimEmployee;

-- 2. Checking duplicate employee IDs
SELECT
    EmployeeID,
    COUNT(*) AS DuplicateCount
FROM Dim.DimEmployee
GROUP BY EmployeeID
HAVING COUNT(*) > 1;

-- 3. Checking missing mandatory attributes
SELECT *
FROM Dim.DimEmployee
WHERE FirstName IS NULL
   OR LastName IS NULL
   OR EmployeeName IS NULL
   OR JobTitle IS NULL
   OR BirthDate IS NULL
   OR HireDate IS NULL;

-- 4. Checking employee flags
SELECT 'SalariedFlag' AS ColumnName,
       CAST(SalariedFlag AS VARCHAR(10)) AS FlagValue,
       COUNT(*) AS EmployeeCount
FROM Dim.DimEmployee
GROUP BY SalariedFlag

UNION ALL

SELECT 'CurrentFlag',
       CAST(CurrentFlag AS VARCHAR(10)),
       COUNT(*)
FROM Dim.DimEmployee
GROUP BY CurrentFlag;

-- 5. Checking hire date and birth rate
SELECT *
FROM Dim.DimEmployee
WHERE HireDate < BirthDate;

-- 6. Checking negative leave hours
SELECT *
FROM Dim.DimEmployee
WHERE VacationHours < 0
   OR SickLeaveHours < 0;