USE EnterpriseBI_DW;
GO

IF OBJECT_ID('Dim.DimDepartment', 'U') IS NULL
BEGIN
    CREATE TABLE Dim.DimDepartment
    (
        DepartmentKey INT IDENTITY(1,1) NOT NULL,
        DepartmentID INT NOT NULL,
        DepartmentName NVARCHAR(50) NOT NULL,
        DepartmentGroup NVARCHAR(50) NOT NULL,
        ModifiedDate DATETIME NOT NULL,

        CONSTRAINT PK_DimDepartment
            PRIMARY KEY (DepartmentKey),

        CONSTRAINT UQ_DimDepartment_DepartmentID
            UNIQUE (DepartmentID)
    );

    INSERT INTO Dim.DimDepartment
    (
        DepartmentID,
        DepartmentName,
        DepartmentGroup,
        ModifiedDate
    )
    SELECT
        DepartmentID,
        Name,
        GroupName,
        ModifiedDate
    FROM AdventureWorks2025.HumanResources.Department;
END;
GO

--Adding the primary key
IF NOT EXISTS
(
    SELECT 1
    FROM sys.key_constraints
    WHERE parent_object_id = OBJECT_ID('Dim.DimDepartment')
      AND type = 'PK'
)
BEGIN
    ALTER TABLE Dim.DimDepartment
    ADD CONSTRAINT PK_DimDepartment
        PRIMARY KEY (DepartmentKey);
END;
GO

--Adding a unique constraint on the source ID
IF NOT EXISTS
(
    SELECT 1
    FROM sys.indexes
    WHERE object_id = OBJECT_ID('Dim.DimDepartment')
      AND name = 'UQ_DimDepartment_DepartmentID'
)
BEGIN
    CREATE UNIQUE INDEX UQ_DimDepartment_DepartmentID
    ON Dim.DimDepartment(DepartmentID);
END;
GO

--Validating the dimension
SELECT *
FROM Dim.DimDepartment
ORDER BY DepartmentKey;
GO

SELECT
    COUNT(*) AS TotalDepartments,
    COUNT(DISTINCT DepartmentID) AS UniqueDepartmentIDs
FROM Dim.DimDepartment;
GO