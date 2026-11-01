USE EnterpriseBI_DW
GO

SELECT
    IsCurrentAssignment,
    COUNT(*) AS AssignmentCount,
    SUM(
        CASE WHEN EndDateKey IS NULL THEN 1 ELSE 0 END
    ) AS NullEndDateCount,
    SUM(
        CASE WHEN EndDateKey IS NOT NULL THEN 1 ELSE 0 END
    ) AS CompletedAssignmentCount
FROM Fact.FactEmployeeDepartmentHistory
GROUP BY IsCurrentAssignment
ORDER BY IsCurrentAssignment;