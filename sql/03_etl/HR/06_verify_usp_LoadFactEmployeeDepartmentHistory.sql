USE EnterpriseBI_DW;
GO

-- 1. Verifying warehouse and source row counts

SELECT
    'FactEmployeeDepartmentHistory' AS TableName,
    COUNT(*) AS WarehouseRows
FROM Fact.FactEmployeeDepartmentHistory;

SELECT
    'EmployeeDepartmentHistory' AS SourceTable,
    COUNT(*) AS SourceRows
FROM AdventureWorks2025.HumanResources.EmployeeDepartmentHistory;

-- 2. Checking duplicate records

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

-- 3. Checking missing employee mappings

SELECT edh.BusinessEntityID AS MissingEmployeeID
FROM AdventureWorks2025.HumanResources.EmployeeDepartmentHistory AS edh
LEFT JOIN Dim.DimEmployee AS de
    ON de.EmployeeID = edh.BusinessEntityID
WHERE de.EmployeeKey IS NULL;

-- 4. Checking missing department mappings

SELECT edh.DepartmentID AS MissingDepartmentID
FROM AdventureWorks2025.HumanResources.EmployeeDepartmentHistory AS edh
LEFT JOIN Dim.DimDepartment AS dd
    ON dd.DepartmentID = edh.DepartmentID
WHERE dd.DepartmentKey IS NULL;

-- 5. Checking missing shift mappings

SELECT edh.ShiftID AS MissingShiftID
FROM AdventureWorks2025.HumanResources.EmployeeDepartmentHistory AS edh
LEFT JOIN Dim.DimShift AS ds
    ON ds.ShiftID = edh.ShiftID
WHERE ds.ShiftKey IS NULL;

-- 6. Checking missing start and end date mappings

SELECT edh.BusinessEntityID, edh.StartDate AS MissingStartDate
FROM AdventureWorks2025.HumanResources.EmployeeDepartmentHistory AS edh
LEFT JOIN Dim.DimDate AS dd
    ON dd.FullDate = CONVERT(date, edh.StartDate)
WHERE dd.DateKey IS NULL;

SELECT edh.BusinessEntityID, edh.EndDate AS MissingEndDate
FROM AdventureWorks2025.HumanResources.EmployeeDepartmentHistory AS edh
LEFT JOIN Dim.DimDate AS dd
    ON dd.FullDate = CONVERT(date, edh.EndDate)
WHERE edh.EndDate IS NOT NULL
  AND dd.DateKey IS NULL;

-- 7. Checking NULL foreign keys in fact table

SELECT *
FROM Fact.FactEmployeeDepartmentHistory
WHERE EmployeeKey IS NULL
   OR DepartmentKey IS NULL
   OR ShiftKey IS NULL
   OR StartDateKey IS NULL;

GO