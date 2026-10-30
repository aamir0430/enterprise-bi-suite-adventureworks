USE EnterpriseBI_DW;
GO

IF OBJECT_ID('Fact.FactEmployeeDepartmentHistory', 'U') IS NULL
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

        -- Primary Key: uniquely identifies each assignment record
        CONSTRAINT PK_FactEmployeeDepartmentHistory
            PRIMARY KEY (DepartmentHistoryFactKey),

        -- Unique Constraint: prevents duplicate assignment records
        CONSTRAINT UQ_EmployeeDepartmentHistory
            UNIQUE (EmployeeKey, DepartmentKey, ShiftKey, StartDateKey),

        -- Foreign Keys: connect employee, department and shift dimensions
        CONSTRAINT FK_DeptHistory_Employee
            FOREIGN KEY (EmployeeKey)
            REFERENCES Dim.DimEmployee(EmployeeKey),

        CONSTRAINT FK_DeptHistory_Department
            FOREIGN KEY (DepartmentKey)
            REFERENCES Dim.DimDepartment(DepartmentKey),

        CONSTRAINT FK_DeptHistory_Shift
            FOREIGN KEY (ShiftKey)
            REFERENCES Dim.DimShift(ShiftKey),

        -- Foreign Keys: connect assignment dates to DimDate
        CONSTRAINT FK_DeptHistory_StartDate
            FOREIGN KEY (StartDateKey)
            REFERENCES Dim.DimDate(DateKey),

        CONSTRAINT FK_DeptHistory_EndDate
            FOREIGN KEY (EndDateKey)
            REFERENCES Dim.DimDate(DateKey)
    );

    -- Insert department assignment history
    INSERT INTO Fact.FactEmployeeDepartmentHistory
    (
        EmployeeKey, DepartmentKey, ShiftKey,
        StartDateKey, EndDateKey,
        IsCurrentAssignment, AssignmentDurationDays
    )
    SELECT
        DE.EmployeeKey,
        DD.DepartmentKey,
        DS.ShiftKey,
        CONVERT(INT, CONVERT(CHAR(8), H.StartDate, 112)),

        CASE
            WHEN H.EndDate IS NOT NULL
            THEN CONVERT(INT, CONVERT(CHAR(8), H.EndDate, 112))
            ELSE NULL
        END,

        CASE WHEN H.EndDate IS NULL THEN 1 ELSE 0 END,

        DATEDIFF
        (
            DAY,
            H.StartDate,
            ISNULL(H.EndDate, CAST(GETDATE() AS DATE))
        )

    FROM AdventureWorks2025.HumanResources.EmployeeDepartmentHistory H

    INNER JOIN Dim.DimEmployee DE
        ON H.BusinessEntityID = DE.EmployeeID

    INNER JOIN Dim.DimDepartment DD
        ON H.DepartmentID = DD.DepartmentID

    INNER JOIN Dim.DimShift DS
        ON H.ShiftID = DS.ShiftID;

END;
GO