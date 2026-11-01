USE EnterpriseBI_DW
GO

SELECT
    ModifiedDate,
    COUNT(*) AS ShiftCount
FROM Dim.DimShift
GROUP BY ModifiedDate;