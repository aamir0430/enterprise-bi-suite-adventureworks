USE EnterpriseBI_DW
GO

-- Validating the DimDepartment table:

-- 1. Checking row count and key uniqueness
SELECT
    COUNT(*) AS TotalRows,
    COUNT(DISTINCT DepartmentKey) AS DistinctDepartmentKeys,
    COUNT(DISTINCT DepartmentID) AS DistinctDepartmentIDs,
    COUNT(*) - COUNT(DepartmentKey) AS NullDepartmentKeys,
    COUNT(*) - COUNT(DepartmentID) AS NullDepartmentIDs
FROM Dim.DimDepartment;

-- 2. Checking duplicate department IDs
SELECT
    DepartmentID,
    COUNT(*) AS DuplicateCount
FROM Dim.DimDepartment
GROUP BY DepartmentID
HAVING COUNT(*) > 1;

-- 3. Checking duplicate department names
SELECT
    DepartmentName,
    COUNT(*) AS DuplicateCount
FROM Dim.DimDepartment
GROUP BY DepartmentName
HAVING COUNT(*) > 1;

-- 4. Checking missing department attributes
SELECT *
FROM Dim.DimDepartment
WHERE DepartmentName IS NULL
   OR DepartmentGroup IS NULL;

-- 5. Checking department group distribution
SELECT
    DepartmentGroup,
    COUNT(*) AS DepartmentCount
FROM Dim.DimDepartment
GROUP BY DepartmentGroup
ORDER BY DepartmentGroup;