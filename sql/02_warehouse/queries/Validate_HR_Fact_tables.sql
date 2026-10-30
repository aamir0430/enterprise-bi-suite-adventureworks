--Checking row counts
USE EnterpriseBI_DW;
GO

SELECT 'DimEmployee' AS TableName, COUNT(*) AS TotalRows
FROM Dim.DimEmployee

UNION ALL

SELECT 'DimDepartment', COUNT(*)
FROM Dim.DimDepartment

UNION ALL

SELECT 'DimShift', COUNT(*)
FROM Dim.DimShift

UNION ALL

SELECT 'DimPayFrequency', COUNT(*)
FROM Dim.DimPayFrequency

UNION ALL

SELECT 'FactEmployeeSnapshot', COUNT(*)
FROM Fact.FactEmployeeSnapshot

UNION ALL

SELECT 'FactEmployeeDepartmentHistory', COUNT(*)
FROM Fact.FactEmployeeDepartmentHistory

UNION ALL

SELECT 'FactEmployeePayHistory', COUNT(*)
FROM Fact.FactEmployeePayHistory;
GO

--Compparing source and warehouse row counts
SELECT
    'Employee' AS DataArea,
    (SELECT COUNT(*)
     FROM AdventureWorks2025.HumanResources.Employee)
        AS SourceRows,
    (SELECT COUNT(*)
     FROM Fact.FactEmployeeSnapshot)
        AS WarehouseRows

UNION ALL

SELECT
    'EmployeeDepartmentHistory',
    (SELECT COUNT(*)
     FROM AdventureWorks2025.HumanResources.EmployeeDepartmentHistory),
    (SELECT COUNT(*)
     FROM Fact.FactEmployeeDepartmentHistory)

UNION ALL

SELECT
    'EmployeePayHistory',
    (SELECT COUNT(*)
     FROM AdventureWorks2025.HumanResources.EmployeePayHistory),
    (SELECT COUNT(*)
     FROM Fact.FactEmployeePayHistory);
GO

--Checking missing dimension keys
SELECT
    COUNT(*) AS MissingEmployeeKeys
FROM Fact.FactEmployeeSnapshot
WHERE EmployeeKey IS NULL;

SELECT
    COUNT(*) AS MissingDepartmentKeys
FROM Fact.FactEmployeeSnapshot
WHERE DepartmentKey IS NULL;

SELECT
    COUNT(*) AS MissingShiftKeys
FROM Fact.FactEmployeeSnapshot
WHERE ShiftKey IS NULL;

SELECT
    COUNT(*) AS MissingPayFrequencyKeys
FROM Fact.FactEmployeePayHistory
WHERE PayFrequencyKey IS NULL;
GO

--validating employee snapshot data
SELECT TOP 20
    EmployeeID,
    EmployeeKey,
    DepartmentKey,
    ShiftKey,
    SnapshotDateKey,
    HireDate,
    DaysEmployed,
    VacationHours,
    SickLeaveHours,
    CurrentFlag
FROM Fact.FactEmployeeSnapshot
ORDER BY EmployeeID;
GO

--checking duplicate employees on the same snapshot date
SELECT
    EmployeeKey,
    SnapshotDateKey,
    COUNT(*) AS DuplicateCount
FROM Fact.FactEmployeeSnapshot
GROUP BY EmployeeKey, SnapshotDateKey
HAVING COUNT(*) > 1;
GO

--validating department history
SELECT
    BusinessEntityID,
    DepartmentID,
    ShiftID,
    StartDate,
    EndDate
FROM AdventureWorks2025.HumanResources.EmployeeDepartmentHistory
ORDER BY BusinessEntityID, StartDate;
GO

--checking current assignment
SELECT
    COUNT(*) AS CurrentAssignments
FROM Fact.FactEmployeeDepartmentHistory
WHERE IsCurrentAssignment = 1;
GO

--checking invalid date ranges
SELECT *
FROM AdventureWorks2025.HumanResources.EmployeeDepartmentHistory
WHERE EndDate IS NOT NULL
  AND EndDate < StartDate;
GO

--validating pay history
SELECT
    EmployeeKey,
    PayFrequencyKey,
    RateChangeDateKey,
    Rate
FROM Fact.FactEmployeePayHistory
ORDER BY EmployeeKey, RateChangeDateKey;
GO

--validating pay rates
SELECT
    COUNT(*) AS TotalRecords,
    MIN(Rate) AS MinimumRate,
    MAX(Rate) AS MaximumRate,
    AVG(Rate) AS AverageRate
FROM Fact.FactEmployeePayHistory;
GO

--validating pay-frequency mapping
SELECT
    F.PayFrequencyKey,
    D.PayFrequencyCode,
    D.PayFrequencyName,
    COUNT(*) AS TotalRecords
FROM Fact.FactEmployeePayHistory F
INNER JOIN Dim.DimPayFrequency D
    ON F.PayFrequencyKey = D.PayFrequencyKey
GROUP BY
    F.PayFrequencyKey,
    D.PayFrequencyCode,
    D.PayFrequencyName
ORDER BY D.PayFrequencyCode;
GO

--checking duplicate pay-history records
SELECT
    EmployeeKey,
    RateChangeDateKey,
    COUNT(*) AS DuplicateCount
FROM Fact.FactEmployeePayHistory
GROUP BY EmployeeKey, RateChangeDateKey
HAVING COUNT(*) > 1;
GO

--checking data coverage
SELECT
    'Employee Snapshot' AS FactName,
    MIN(SnapshotDateKey) AS MinimumDateKey,
    MAX(SnapshotDateKey) AS MaximumDateKey
FROM Fact.FactEmployeeSnapshot

UNION ALL

SELECT
    'Department History',
    MIN(StartDateKey),
    MAX(StartDateKey)
FROM Fact.FactEmployeeDepartmentHistory

UNION ALL

SELECT
    'Pay History',
    MIN(RateChangeDateKey),
    MAX(RateChangeDateKey)
FROM Fact.FactEmployeePayHistory;
GO

--checking for any missing date dimension records
SELECT DISTINCT F.SnapshotDateKey AS MissingDateKey
FROM Fact.FactEmployeeSnapshot F
LEFT JOIN Dim.DimDate D
    ON F.SnapshotDateKey = D.DateKey
WHERE D.DateKey IS NULL;
GO

SELECT DISTINCT F.StartDateKey AS MissingDateKey
FROM Fact.FactEmployeeDepartmentHistory F
LEFT JOIN Dim.DimDate D
    ON F.StartDateKey = D.DateKey
WHERE D.DateKey IS NULL;
GO

SELECT DISTINCT F.RateChangeDateKey AS MissingDateKey
FROM Fact.FactEmployeePayHistory F
LEFT JOIN Dim.DimDate D
    ON F.RateChangeDateKey = D.DateKey
WHERE D.DateKey IS NULL;
GO