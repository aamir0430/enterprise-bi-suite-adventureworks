USE EnterpriseBI_DW
GO

-- 1. Verifying all HR warehouse row counts

SELECT 'DimDepartment' AS TableName, COUNT(*) AS TotalRows
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

-- 2. Verifying duplicate records

SELECT EmployeeKey, COUNT(*) AS DuplicateCount
FROM Fact.FactEmployeeSnapshot
GROUP BY EmployeeKey
HAVING COUNT(*) > 1;

SELECT EmployeeKey, DepartmentKey, ShiftKey, StartDateKey,
       COUNT(*) AS DuplicateCount
FROM Fact.FactEmployeeDepartmentHistory
GROUP BY EmployeeKey, DepartmentKey, ShiftKey, StartDateKey
HAVING COUNT(*) > 1;

SELECT EmployeeKey, PayFrequencyKey, RateChangeDateKey,
       COUNT(*) AS DuplicateCount
FROM Fact.FactEmployeePayHistory
GROUP BY EmployeeKey, PayFrequencyKey, RateChangeDateKey
HAVING COUNT(*) > 1;
GO