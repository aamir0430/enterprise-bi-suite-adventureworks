
USE EnterpriseBI_DW;
GO

SELECT 'DimEmployee' AS TableName, COUNT_BIG(*) AS TotalRows
FROM Dim.DimEmployee

UNION ALL
SELECT 'DimDepartment', COUNT_BIG(*)
FROM Dim.DimDepartment

UNION ALL
SELECT 'DimShift', COUNT_BIG(*)
FROM Dim.DimShift

UNION ALL
SELECT 'DimPayFrequency', COUNT_BIG(*)
FROM Dim.DimPayFrequency

UNION ALL
SELECT 'DimDate', COUNT_BIG(*)
FROM Dim.DimDate

UNION ALL
SELECT 'FactEmployeeSnapshot', COUNT_BIG(*)
FROM Fact.FactEmployeeSnapshot

UNION ALL
SELECT 'FactEmployeeDepartmentHistory', COUNT_BIG(*)
FROM Fact.FactEmployeeDepartmentHistory

UNION ALL
SELECT 'FactEmployeePayHistory', COUNT_BIG(*)
FROM Fact.FactEmployeePayHistory;
GO
