USE EnterpriseBI_DW
GO

-- Investigating unusual values:

-- 1. CurrentFlag
SELECT
    CurrentFlag,
    COUNT(*) AS EmployeeCount
FROM Dim.DimEmployee
GROUP BY CurrentFlag;

-- 2. ModifiedDate
SELECT
    ModifiedDate,
    COUNT(*) AS EmployeeCount
FROM Dim.DimEmployee
GROUP BY ModifiedDate
ORDER BY ModifiedDate;

-- 3. VacationHours and SickLeaveHours
SELECT
    MIN(VacationHours) AS MinVacationHours,
    MAX(VacationHours) AS MaxVacationHours,
    MIN(SickLeaveHours) AS MinSickLeaveHours,
    MAX(SickLeaveHours) AS MaxSickLeaveHours
FROM Dim.DimEmployee;