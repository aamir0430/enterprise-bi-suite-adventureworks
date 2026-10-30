USE EnterpriseBI_DW;
GO

--Creating the dimension table DimShift

IF OBJECT_ID('Dim.DimShift', 'U') IS NULL
BEGIN
    CREATE TABLE Dim.DimShift
    (
        ShiftKey INT IDENTITY(1,1) NOT NULL,
        ShiftID TINYINT NOT NULL,
        ShiftName NVARCHAR(50) NOT NULL,
        StartTime TIME NOT NULL,
        EndTime TIME NOT NULL,
        ModifiedDate DATETIME NOT NULL
    );
END;
GO

--Adding the primary key

IF NOT EXISTS
(
    SELECT 1
    FROM sys.key_constraints
    WHERE parent_object_id = OBJECT_ID('Dim.DimShift')
      AND type = 'PK'
)
BEGIN
    ALTER TABLE Dim.DimShift
    ADD CONSTRAINT PK_DimShift
        PRIMARY KEY CLUSTERED (ShiftKey);
END;
GO

--Adding a unique constraint on the source ID

IF NOT EXISTS
(
    SELECT 1
    FROM sys.indexes
    WHERE object_id = OBJECT_ID('Dim.DimShift')
      AND name = 'UQ_DimShift_ShiftID'
)
BEGIN
    CREATE UNIQUE INDEX UQ_DimShift_ShiftID
    ON Dim.DimShift (ShiftID);
END;
GO

--Inserting source records that do not already exist

INSERT INTO Dim.DimShift
(
    ShiftID,
    ShiftName,
    StartTime,
    EndTime,
    ModifiedDate
)
SELECT
    S.ShiftID,
    S.Name,
    S.StartTime,
    S.EndTime,
    S.ModifiedDate
FROM AdventureWorks2025.HumanResources.Shift S
WHERE NOT EXISTS
(
    SELECT 1
    FROM Dim.DimShift D
    WHERE D.ShiftID = S.ShiftID
);
GO

--Displaying the final dimension records

SELECT
    ShiftKey,
    ShiftID,
    ShiftName,
    StartTime,
    EndTime,
    ModifiedDate
FROM Dim.DimShift
ORDER BY ShiftID;
GO