USE EnterpriseBI_DW
GO

-- 1. Verifying FactEmployeeSnapshot table row counts

SELECT
    'FactEmployeeSnapshot' AS TableName,
    COUNT(*) AS WarehouseRows
FROM Fact.FactEmployeeSnapshot;

SELECT
    'HumanResources.Employee' AS SourceTable,
    COUNT(*) AS SourceRows
FROM AdventureWorks2025.HumanResources.Employee;
GO

-- 2. Checking duplicate employee records

SELECT
    EmployeeKey,
    COUNT(*) AS DuplicateCount
FROM Fact.FactEmployeeSnapshot
GROUP BY EmployeeKey
HAVING COUNT(*) > 1;
GO

-- 3. Checking missing employee mappings

SELECT
    e.BusinessEntityID AS MissingEmployeeID
FROM AdventureWorks2025.HumanResources.Employee AS e
LEFT JOIN Dim.DimEmployee AS de
    ON de.EmployeeID = e.BusinessEntityID
LEFT JOIN Fact.FactEmployeeSnapshot AS f
    ON f.EmployeeKey = de.EmployeeKey
WHERE f.EmployeeKey IS NULL;
GO

-- 4. Checking missing department and shift mappings

SELECT *
FROM Fact.FactEmployeeSnapshot
WHERE DepartmentKey IS NULL
   OR ShiftKey IS NULL;
GO
