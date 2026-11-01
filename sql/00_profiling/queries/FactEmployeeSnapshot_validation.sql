USE EnterpriseBI_DW
GO

-- Validation of FactEmployeeSnapshot table:

-- 1. Checking row count and key uniqueness
SELECT
    COUNT(*) AS TotalRows,
    COUNT(DISTINCT EmployeeSnapshotKey) AS DistinctSnapshotKeys,
    COUNT(DISTINCT EmployeeKey) AS DistinctEmployeeKeys,
    COUNT(DISTINCT EmployeeID) AS DistinctEmployeeIDs,
    COUNT(DISTINCT SnapshotDateKey) AS DistinctSnapshotDates
FROM Fact.FactEmployeeSnapshot;

-- 2. Checking duplicate employee snapshot records
SELECT
    EmployeeKey,
    SnapshotDateKey,
    COUNT(*) AS DuplicateCount
FROM Fact.FactEmployeeSnapshot
GROUP BY EmployeeKey, SnapshotDateKey
HAVING COUNT(*) > 1;

-- 3. Validating dimension relationships
SELECT 'EmployeeKey' AS ColumnName, COUNT(*) AS InvalidRows
FROM Fact.FactEmployeeSnapshot f
LEFT JOIN Dim.DimEmployee d
    ON f.EmployeeKey = d.EmployeeKey
WHERE d.EmployeeKey IS NULL

UNION ALL

SELECT 'DepartmentKey', COUNT(*)
FROM Fact.FactEmployeeSnapshot f
LEFT JOIN Dim.DimDepartment d
    ON f.DepartmentKey = d.DepartmentKey
WHERE d.DepartmentKey IS NULL

UNION ALL

SELECT 'ShiftKey', COUNT(*)
FROM Fact.FactEmployeeSnapshot f
LEFT JOIN Dim.DimShift d
    ON f.ShiftKey = d.ShiftKey
WHERE d.ShiftKey IS NULL

UNION ALL

SELECT 'SnapshotDateKey', COUNT(*)
FROM Fact.FactEmployeeSnapshot f
LEFT JOIN Dim.DimDate d
    ON f.SnapshotDateKey = d.DateKey
WHERE d.DateKey IS NULL;

-- 4. Checking EmployeeID consistency
SELECT
    f.EmployeeKey,
    f.EmployeeID AS FactEmployeeID,
    d.EmployeeID AS DimensionEmployeeID
FROM Fact.FactEmployeeSnapshot f
INNER JOIN Dim.DimEmployee d
    ON f.EmployeeKey = d.EmployeeKey
WHERE f.EmployeeID <> d.EmployeeID;

-- 5. Validating DaysEmployed column
SELECT
    EmployeeID,
    HireDate,
    DaysEmployed,
    SnapshotDateKey,
    DATEDIFF(
        DAY,
        HireDate,
        CONVERT(
            DATE,
            CONVERT(CHAR(8), SnapshotDateKey),
            112
        )
    ) AS ExpectedDaysEmployed
FROM Fact.FactEmployeeSnapshot
WHERE DaysEmployed <>
    DATEDIFF(
        DAY,
        HireDate,
        CONVERT(
            DATE,
            CONVERT(CHAR(8), SnapshotDateKey),
            112
        )
    );

-- 6. Checking employee dates
SELECT *
FROM Fact.FactEmployeeSnapshot
WHERE HireDate > CONVERT(
        DATE,
        CONVERT(CHAR(8), SnapshotDateKey),
        112
    )
   OR BirthDate > HireDate;

-- 7. Checking flags and leave hours
SELECT
    SalariedFlag,
    CurrentFlag,
    COUNT(*) AS EmployeeCount
FROM Fact.FactEmployeeSnapshot
GROUP BY SalariedFlag, CurrentFlag
ORDER BY SalariedFlag, CurrentFlag;

SELECT *
FROM Fact.FactEmployeeSnapshot
WHERE VacationHours < 0
   OR SickLeaveHours < 0;

-- 8. Checking ModifiedDate column
SELECT
    ModifiedDate,
    COUNT(*) AS EmployeeCount
FROM Fact.FactEmployeeSnapshot
GROUP BY ModifiedDate
ORDER BY ModifiedDate;