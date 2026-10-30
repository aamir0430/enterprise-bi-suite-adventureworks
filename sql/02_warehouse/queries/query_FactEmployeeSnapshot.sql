USE EnterpriseBI_DW;
GO

IF OBJECT_ID('Fact.FactEmployeeSnapshot', 'U') IS NULL
BEGIN

    CREATE TABLE Fact.FactEmployeeSnapshot
    (
        EmployeeSnapshotKey BIGINT IDENTITY(1,1) NOT NULL,
        EmployeeKey INT NOT NULL,
        DepartmentKey INT NULL,
        ShiftKey INT NULL,
        SnapshotDateKey INT NOT NULL,
        EmployeeID INT NOT NULL,
        HireDate DATE,
        DaysEmployed INT,
        SalariedFlag BIT,
        VacationHours SMALLINT,
        SickLeaveHours SMALLINT,
        CurrentFlag BIT,
        JobTitle NVARCHAR(50),
        Gender NCHAR(1),
        MaritalStatus NCHAR(1),
        BirthDate DATE,
        ModifiedDate DATETIME,

        -- Primary Key: uniquely identifies each snapshot record
        CONSTRAINT PK_FactEmployeeSnapshot
            PRIMARY KEY (EmployeeSnapshotKey),

        -- Unique Constraint: one employee per snapshot date
        CONSTRAINT UQ_EmployeeSnapshot
            UNIQUE (EmployeeKey, SnapshotDateKey),

        -- Foreign Keys: connect the fact to shared dimensions
        CONSTRAINT FK_Snapshot_Employee
            FOREIGN KEY (EmployeeKey)
            REFERENCES Dim.DimEmployee(EmployeeKey),

        CONSTRAINT FK_Snapshot_Department
            FOREIGN KEY (DepartmentKey)
            REFERENCES Dim.DimDepartment(DepartmentKey),

        CONSTRAINT FK_Snapshot_Shift
            FOREIGN KEY (ShiftKey)
            REFERENCES Dim.DimShift(ShiftKey),

        CONSTRAINT FK_Snapshot_Date
            FOREIGN KEY (SnapshotDateKey)
            REFERENCES Dim.DimDate(DateKey)
    );

    -- Insert employee snapshot records
    INSERT INTO Fact.FactEmployeeSnapshot
    (
        EmployeeKey, DepartmentKey, ShiftKey,
        SnapshotDateKey, EmployeeID, HireDate,
        DaysEmployed, SalariedFlag, VacationHours,
        SickLeaveHours, CurrentFlag, JobTitle,
        Gender, MaritalStatus, BirthDate, ModifiedDate
    )
    SELECT
        DE.EmployeeKey,
        DD.DepartmentKey,
        DS.ShiftKey,
        CONVERT(INT, CONVERT(CHAR(8), GETDATE(), 112)),
        E.BusinessEntityID,
        E.HireDate,
        DATEDIFF(DAY, E.HireDate, GETDATE()),
        E.SalariedFlag,
        E.VacationHours,
        E.SickLeaveHours,
        E.CurrentFlag,
        E.JobTitle,
        E.Gender,
        E.MaritalStatus,
        E.BirthDate,
        E.ModifiedDate

    FROM AdventureWorks2025.HumanResources.Employee E

    INNER JOIN Dim.DimEmployee DE
        ON E.BusinessEntityID = DE.EmployeeID

    OUTER APPLY
    (
        -- Select only the latest current department assignment
        SELECT TOP 1 *
        FROM AdventureWorks2025.HumanResources.EmployeeDepartmentHistory H
        WHERE H.BusinessEntityID = E.BusinessEntityID
          AND H.EndDate IS NULL
        ORDER BY H.StartDate DESC
    ) H

    LEFT JOIN Dim.DimDepartment DD
        ON H.DepartmentID = DD.DepartmentID

    LEFT JOIN Dim.DimShift DS
        ON H.ShiftID = DS.ShiftID;

END;
GO