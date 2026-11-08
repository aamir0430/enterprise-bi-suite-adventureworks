
USE EnterpriseBI_DW;
GO

SELECT 'Employee' AS SourceTable, COUNT_BIG(*) AS TotalRows
FROM AdventureWorks2025.HumanResources.Employee

UNION ALL
SELECT 'Department', COUNT_BIG(*)
FROM AdventureWorks2025.HumanResources.Department

UNION ALL
SELECT 'Shift', COUNT_BIG(*)
FROM AdventureWorks2025.HumanResources.Shift

UNION ALL
SELECT 'EmployeeDepartmentHistory', COUNT_BIG(*)
FROM AdventureWorks2025.HumanResources.EmployeeDepartmentHistory

UNION ALL
SELECT 'EmployeePayHistory', COUNT_BIG(*)
FROM AdventureWorks2025.HumanResources.EmployeePayHistory;
GO
