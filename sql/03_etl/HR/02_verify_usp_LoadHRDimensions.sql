USE EnterpriseBI_DW;
GO

-- 1. Dimension row counts

SELECT 'DimDepartment' AS DimensionTable, COUNT(*) AS TotalRows
FROM Dim.DimDepartment
UNION ALL
SELECT 'DimShift', COUNT(*)
FROM Dim.DimShift
UNION ALL
SELECT 'DimPayFrequency', COUNT(*)
FROM Dim.DimPayFrequency
UNION ALL
SELECT 'DimEmployee', COUNT(*)
FROM Dim.DimEmployee
UNION ALL
SELECT 'DimDate', COUNT(*)
FROM Dim.DimDate;

-- 2. Checking duplicate business keys

SELECT DepartmentID, COUNT(*) AS Duplicates
FROM Dim.DimDepartment
GROUP BY DepartmentID
HAVING COUNT(*) > 1;

SELECT ShiftID, COUNT(*) AS Duplicates
FROM Dim.DimShift
GROUP BY ShiftID
HAVING COUNT(*) > 1;

SELECT PayFrequencyCode, COUNT(*) AS Duplicates
FROM Dim.DimPayFrequency
GROUP BY PayFrequencyCode
HAVING COUNT(*) > 1;

SELECT EmployeeID, COUNT(*) AS Duplicates
FROM Dim.DimEmployee
GROUP BY EmployeeID
HAVING COUNT(*) > 1;

SELECT FullDate, COUNT(*) AS Duplicates
FROM Dim.DimDate
GROUP BY FullDate
HAVING COUNT(*) > 1;

-- 3. Checking missing source mappings

SELECT DepartmentID
FROM AdventureWorks2025.HumanResources.Department
EXCEPT
SELECT DepartmentID
FROM Dim.DimDepartment;

SELECT ShiftID
FROM AdventureWorks2025.HumanResources.Shift
EXCEPT
SELECT ShiftID
FROM Dim.DimShift;

SELECT DISTINCT PayFrequency
FROM AdventureWorks2025.HumanResources.EmployeePayHistory
EXCEPT
SELECT PayFrequencyCode
FROM Dim.DimPayFrequency;

SELECT BusinessEntityID
FROM AdventureWorks2025.HumanResources.Employee
EXCEPT
SELECT EmployeeID
FROM Dim.DimEmployee;

-- 4. Validating all HR dates exist in DimDate

SELECT HRDates.SourceDate AS MissingDate
FROM
(
    SELECT CONVERT(date, HireDate) AS SourceDate
    FROM AdventureWorks2025.HumanResources.Employee

    UNION

    SELECT CONVERT(date, StartDate)
    FROM AdventureWorks2025.HumanResources.EmployeeDepartmentHistory

    UNION

    SELECT CONVERT(date, EndDate)
    FROM AdventureWorks2025.HumanResources.EmployeeDepartmentHistory
    WHERE EndDate IS NOT NULL

    UNION

    SELECT CONVERT(date, RateChangeDate)
    FROM AdventureWorks2025.HumanResources.EmployeePayHistory
) AS HRDates
EXCEPT
SELECT FullDate
FROM Dim.DimDate;

GO