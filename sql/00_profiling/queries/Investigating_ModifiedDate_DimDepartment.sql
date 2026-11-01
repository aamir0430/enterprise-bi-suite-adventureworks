USE EnterpriseBI_DW
GO

SELECT
    ModifiedDate,
    COUNT(*) AS DepartmentCount
FROM Dim.DimDepartment
GROUP BY ModifiedDate;