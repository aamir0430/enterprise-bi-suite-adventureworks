USE EnterpriseBI_DW;
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

IF OBJECT_ID(
    'Fact.FactEmployeeDepartmentHistory', 'U'
) IS NULL
BEGIN

    CREATE TABLE Fact.FactEmployeeDepartmentHistory
    (
        DepartmentHistoryFactKey BIGINT IDENTITY(1,1) NOT NULL,

        EmployeeKey INT NOT NULL,
        DepartmentKey INT NOT NULL,
        ShiftKey INT NOT NULL,

        StartDateKey INT NOT NULL,
        EndDateKey INT NULL,

        IsCurrentAssignment BIT,
        AssignmentDurationDays INT,

        CONSTRAINT PK_FactEmployeeDepartmentHistory
            PRIMARY KEY (DepartmentHistoryFactKey),

        CONSTRAINT UQ_EmployeeDepartmentHistory
            UNIQUE
            (
                EmployeeKey,
                DepartmentKey,
                ShiftKey,
                StartDateKey
            ),

        CONSTRAINT FK_DeptHistory_Employee
            FOREIGN KEY (EmployeeKey)
            REFERENCES Dim.DimEmployee(EmployeeKey),

        CONSTRAINT FK_DeptHistory_Department
            FOREIGN KEY (DepartmentKey)
            REFERENCES Dim.DimDepartment(DepartmentKey),

        CONSTRAINT FK_DeptHistory_Shift
            FOREIGN KEY (ShiftKey)
            REFERENCES Dim.DimShift(ShiftKey),

        CONSTRAINT FK_DeptHistory_StartDate
            FOREIGN KEY (StartDateKey)
            REFERENCES Dim.DimDate(DateKey),

        CONSTRAINT FK_DeptHistory_EndDate
            FOREIGN KEY (EndDateKey)
            REFERENCES Dim.DimDate(DateKey)
    );

    PRINT 'FactEmployeeDepartmentHistory table created.';

END
ELSE
BEGIN

    PRINT 'FactEmployeeDepartmentHistory table already exists.';

END;
GO


IF EXISTS
(
    SELECT 1
    FROM AdventureWorks2025.HumanResources.EmployeeDepartmentHistory H

    LEFT JOIN Dim.DimEmployee E
        ON H.BusinessEntityID = E.EmployeeID

    LEFT JOIN Dim.DimDepartment D
        ON H.DepartmentID = D.DepartmentID

    LEFT JOIN Dim.DimShift S
        ON H.ShiftID = S.ShiftID

    LEFT JOIN Dim.DimDate SD
        ON CONVERT(INT, CONVERT(CHAR(8), H.StartDate, 112))
           = SD.DateKey

    LEFT JOIN Dim.DimDate ED
        ON CONVERT(INT, CONVERT(CHAR(8), H.EndDate, 112))
           = ED.DateKey

    WHERE E.EmployeeKey IS NULL
       OR D.DepartmentKey IS NULL
       OR S.ShiftKey IS NULL
       OR SD.DateKey IS NULL
       OR (H.EndDate IS NOT NULL AND ED.DateKey IS NULL)
)
BEGIN

    THROW 50001,
    'ETL stopped: One or more source records have missing dimension or date matches. Check DimDate and the dimension mappings.',
    1;

END;

PRINT 'All source records successfully match the required dimensions.';
GO

BEGIN TRY

    BEGIN TRANSACTION;

    INSERT INTO Fact.FactEmployeeDepartmentHistory
    (
        EmployeeKey,
        DepartmentKey,
        ShiftKey,
        StartDateKey,
        EndDateKey,
        IsCurrentAssignment,
        AssignmentDurationDays
    )

    SELECT
        E.EmployeeKey,
        D.DepartmentKey,
        S.ShiftKey,

        CONVERT(
            INT,
            CONVERT(CHAR(8), H.StartDate, 112)
        ),

        CASE
            WHEN H.EndDate IS NOT NULL
            THEN CONVERT(
                INT,
                CONVERT(CHAR(8), H.EndDate, 112)
            )
            ELSE NULL
        END,

        CASE
            WHEN H.EndDate IS NULL THEN 1
            ELSE 0
        END,

        DATEDIFF
        (
            DAY,
            H.StartDate,
            ISNULL(H.EndDate, CAST(GETDATE() AS DATE))
        )

    FROM AdventureWorks2025.HumanResources.EmployeeDepartmentHistory H

    INNER JOIN Dim.DimEmployee E
        ON H.BusinessEntityID = E.EmployeeID

    INNER JOIN Dim.DimDepartment D
        ON H.DepartmentID = D.DepartmentID

    INNER JOIN Dim.DimShift S
        ON H.ShiftID = S.ShiftID

    INNER JOIN Dim.DimDate SD
        ON CONVERT(INT, CONVERT(CHAR(8), H.StartDate, 112))
           = SD.DateKey

    LEFT JOIN Dim.DimDate ED
        ON CONVERT(INT, CONVERT(CHAR(8), H.EndDate, 112))
           = ED.DateKey

    WHERE NOT EXISTS
    (
        SELECT 1
        FROM Fact.FactEmployeeDepartmentHistory F
        WHERE F.EmployeeKey = E.EmployeeKey
          AND F.DepartmentKey = D.DepartmentKey
          AND F.ShiftKey = S.ShiftKey
          AND F.StartDateKey =
              CONVERT(INT, CONVERT(CHAR(8), H.StartDate, 112))
    );

    DECLARE @InsertedRows INT = @@ROWCOUNT;

    COMMIT TRANSACTION;

    PRINT 'Employee department history loading completed successfully.';

    SELECT
        @InsertedRows AS NewlyInsertedRows;

END TRY

BEGIN CATCH

    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    THROW;

END CATCH;
GO

SELECT
    COUNT(*) AS TotalWarehouseRows,

    COUNT(DISTINCT DepartmentHistoryFactKey)
        AS DistinctFactKeys,

    COUNT(DISTINCT EmployeeKey)
        AS DistinctEmployees,

    SUM(
        CASE
            WHEN IsCurrentAssignment = 1 THEN 1
            ELSE 0
        END
    ) AS CurrentAssignments,

    SUM(
        CASE
            WHEN EndDateKey IS NULL THEN 1
            ELSE 0
        END
    ) AS OngoingAssignments

FROM Fact.FactEmployeeDepartmentHistory;
GO
