USE EnterpriseBI_DW;
GO


--Create DimEmployee table
IF SCHEMA_ID('Dim') IS NULL
    EXEC('CREATE SCHEMA Dim');
GO

IF OBJECT_ID('Dim.DimEmployee', 'U') IS NULL
BEGIN

    SELECT
        IDENTITY(INT, 1, 1) AS EmployeeKey,

        E.BusinessEntityID AS EmployeeID,

        P.FirstName,
        P.MiddleName,
        P.LastName,

        CONCAT(
            P.FirstName,
            ' ',
            COALESCE(P.MiddleName + ' ', ''),
            P.LastName
        ) AS EmployeeName,

        E.JobTitle,
        E.BirthDate,
        E.MaritalStatus,
        E.Gender,
        E.HireDate,
        E.SalariedFlag,
        E.VacationHours,
        E.SickLeaveHours,
        E.CurrentFlag,
        E.ModifiedDate

    INTO Dim.DimEmployee

    FROM AdventureWorks2025.HumanResources.Employee E

    INNER JOIN AdventureWorks2025.Person.Person P
        ON E.BusinessEntityID = P.BusinessEntityID;

END;
GO

--Add primary key and unique constraint
USE EnterpriseBI_DW;
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.key_constraints
    WHERE parent_object_id = OBJECT_ID('Dim.DimEmployee')
      AND type = 'PK'
)
BEGIN
    ALTER TABLE Dim.DimEmployee
    ADD CONSTRAINT PK_DimEmployee
    PRIMARY KEY (EmployeeKey);
END;
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.key_constraints
    WHERE parent_object_id = OBJECT_ID('Dim.DimEmployee')
      AND name = 'UQ_DimEmployee_EmployeeID'
)
BEGIN
    ALTER TABLE Dim.DimEmployee
    ADD CONSTRAINT UQ_DimEmployee_EmployeeID
    UNIQUE (EmployeeID);
END;
GO

--Validate DimEmployee
SELECT TOP 20 *
FROM Dim.DimEmployee;
GO

SELECT
    COUNT(*) AS TotalEmployees,
    COUNT(DISTINCT EmployeeID) AS UniqueEmployees,
    SUM(CASE WHEN EmployeeID IS NULL THEN 1 ELSE 0 END)
        AS NullEmployeeIDs
FROM Dim.DimEmployee;
GO

--Check whether any source Employee is missing
SELECT
    E.BusinessEntityID
FROM AdventureWorks2025.HumanResources.Employee E
LEFT JOIN Dim.DimEmployee DE
    ON E.BusinessEntityID = DE.EmployeeID
WHERE DE.EmployeeID IS NULL;
GO