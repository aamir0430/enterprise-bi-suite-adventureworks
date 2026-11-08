/*
    Enterprise Business Intelligence Suite
    HR ETL procedures
    File: SQL/03_ETL/03_hr_etl.sql

    Source database : AdventureWorks2025
    Target database : EnterpriseBI_DW

    Notes:
      - DimEmployee and DimDate are shared dimensions and are not rebuilt.
      - AdventureWorks2025.HumanResources.Department uses GroupName
        (not Group) for the department group attribute.
      - HR fact tables are fully reloaded on each execution.
      - FactEmployeeSnapshot stores one current row per employee per ETL run.
      - AdventureWorks PayFrequency codes: 1 = Monthly, 2 = Biweekly.
*/

USE [EnterpriseBI_DW];
GO

/*==============================================================
  1. HR dimensions
==============================================================*/
CREATE OR ALTER PROCEDURE etl.usp_LoadHRDimensions
AS
BEGIN
    SET NOCOUNT ON;

    /* Department dimension */
    UPDATE tgt
       SET tgt.DepartmentName  = src.Name,
           tgt.DepartmentGroup = src.GroupName,
           tgt.ModifiedDate    = src.ModifiedDate
    FROM Dim.DimDepartment AS tgt
    INNER JOIN AdventureWorks2025.HumanResources.Department AS src
        ON src.DepartmentID = tgt.DepartmentID;

    INSERT INTO Dim.DimDepartment
        (DepartmentID, DepartmentName, DepartmentGroup, ModifiedDate)
    SELECT
        src.DepartmentID,
        src.Name,
        src.GroupName,
        src.ModifiedDate
    FROM AdventureWorks2025.HumanResources.Department AS src
    WHERE NOT EXISTS
    (
        SELECT 1
        FROM Dim.DimDepartment AS tgt
        WHERE tgt.DepartmentID = src.DepartmentID
    );

    /* Shift dimension */
    UPDATE tgt
       SET tgt.ShiftName    = src.Name,
           tgt.StartTime    = src.StartTime,
           tgt.EndTime      = src.EndTime,
           tgt.ModifiedDate = src.ModifiedDate
    FROM Dim.DimShift AS tgt
    INNER JOIN AdventureWorks2025.HumanResources.Shift AS src
        ON src.ShiftID = tgt.ShiftID;

    INSERT INTO Dim.DimShift
        (ShiftID, ShiftName, StartTime, EndTime, ModifiedDate)
    SELECT
        src.ShiftID,
        src.Name,
        src.StartTime,
        src.EndTime,
        src.ModifiedDate
    FROM AdventureWorks2025.HumanResources.Shift AS src
    WHERE NOT EXISTS
    (
        SELECT 1
        FROM Dim.DimShift AS tgt
        WHERE tgt.ShiftID = src.ShiftID
    );

    /* Pay frequency dimension */
    UPDATE tgt
       SET tgt.PayFrequencyName =
           CASE src.PayFrequency
               WHEN 1 THEN 'Monthly'
               WHEN 2 THEN 'Biweekly'
               ELSE CONCAT('Code ', CONVERT(varchar(10), src.PayFrequency))
           END
    FROM Dim.DimPayFrequency AS tgt
    INNER JOIN
    (
        SELECT DISTINCT PayFrequency
        FROM AdventureWorks2025.HumanResources.EmployeePayHistory
    ) AS src
        ON src.PayFrequency = tgt.PayFrequencyCode;

    INSERT INTO Dim.DimPayFrequency
        (PayFrequencyCode, PayFrequencyName)
    SELECT
        src.PayFrequency,
        CASE src.PayFrequency
            WHEN 1 THEN 'Monthly'
            WHEN 2 THEN 'Biweekly'
            ELSE CONCAT('Code ', CONVERT(varchar(10), src.PayFrequency))
        END
    FROM
    (
        SELECT DISTINCT PayFrequency
        FROM AdventureWorks2025.HumanResources.EmployeePayHistory
    ) AS src
    WHERE NOT EXISTS
    (
        SELECT 1
        FROM Dim.DimPayFrequency AS tgt
        WHERE tgt.PayFrequencyCode = src.PayFrequency
    );
END;
GO

/*==============================================================
  2. Employee snapshot fact
  Grain: one row per employee for the current ETL execution date
==============================================================*/
CREATE OR ALTER PROCEDURE etl.usp_LoadFactEmployeeSnapshot
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @SnapshotDate date = CONVERT(date, GETDATE());
    DECLARE @SnapshotDateKey int;

    SELECT @SnapshotDateKey = DateKey
    FROM Dim.DimDate
    WHERE FullDate = @SnapshotDate;

    IF @SnapshotDateKey IS NULL
    BEGIN
        ;THROW 51001, 'Snapshot date is not available in Dim.DimDate. Extend the date dimension before running HR ETL.', 1;
    END;

    DELETE FROM Fact.FactEmployeeSnapshot;

    ;WITH CurrentAssignment AS
    (
        SELECT
            edh.BusinessEntityID,
            edh.DepartmentID,
            edh.ShiftID,
            ROW_NUMBER() OVER
            (
                PARTITION BY edh.BusinessEntityID
                ORDER BY
                    CASE WHEN edh.EndDate IS NULL THEN 0 ELSE 1 END,
                    edh.StartDate DESC,
                    edh.DepartmentID DESC
            ) AS rn
        FROM AdventureWorks2025.HumanResources.EmployeeDepartmentHistory AS edh
    )
    INSERT INTO Fact.FactEmployeeSnapshot
    (
        EmployeeKey,
        DepartmentKey,
        ShiftKey,
        SnapshotDateKey,
        EmployeeID,
        HireDate,
        DaysEmployed,
        SalariedFlag,
        VacationHours,
        SickLeaveHours,
        CurrentFlag,
        JobTitle,
        Gender,
        MaritalStatus,
        BirthDate,
        ModifiedDate
    )
    SELECT
        de.EmployeeKey,
        dd.DepartmentKey,
        ds.ShiftKey,
        @SnapshotDateKey,
        e.BusinessEntityID,
        e.HireDate,
        DATEDIFF(DAY, e.HireDate, @SnapshotDate),
        e.SalariedFlag,
        e.VacationHours,
        e.SickLeaveHours,
        e.CurrentFlag,
        e.JobTitle,
        e.Gender,
        e.MaritalStatus,
        e.BirthDate,
        e.ModifiedDate
    FROM AdventureWorks2025.HumanResources.Employee AS e
    INNER JOIN Dim.DimEmployee AS de
        ON de.EmployeeID = e.BusinessEntityID
    LEFT JOIN CurrentAssignment AS ca
        ON ca.BusinessEntityID = e.BusinessEntityID
       AND ca.rn = 1
    LEFT JOIN Dim.DimDepartment AS dd
        ON dd.DepartmentID = ca.DepartmentID
    LEFT JOIN Dim.DimShift AS ds
        ON ds.ShiftID = ca.ShiftID;

    IF (SELECT COUNT_BIG(*) FROM Fact.FactEmployeeSnapshot)
       <> (SELECT COUNT_BIG(*) FROM AdventureWorks2025.HumanResources.Employee)
    BEGIN
        ;THROW 51002, 'FactEmployeeSnapshot row count does not match the HR Employee source. Check employee dimension mappings.', 1;
    END;
END;
GO

/*==============================================================
  3. Employee department history fact
  Grain: one row per EmployeeDepartmentHistory record
==============================================================*/
CREATE OR ALTER PROCEDURE etl.usp_LoadFactEmployeeDepartmentHistory
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM Fact.FactEmployeeDepartmentHistory;

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
        de.EmployeeKey,
        dd.DepartmentKey,
        ds.ShiftKey,
        startDate.DateKey,
        endDate.DateKey,
        CONVERT(bit, CASE WHEN edh.EndDate IS NULL THEN 1 ELSE 0 END),
        DATEDIFF(DAY, edh.StartDate, COALESCE(edh.EndDate, CONVERT(date, GETDATE())))
    FROM AdventureWorks2025.HumanResources.EmployeeDepartmentHistory AS edh
    INNER JOIN Dim.DimEmployee AS de
        ON de.EmployeeID = edh.BusinessEntityID
    INNER JOIN Dim.DimDepartment AS dd
        ON dd.DepartmentID = edh.DepartmentID
    INNER JOIN Dim.DimShift AS ds
        ON ds.ShiftID = edh.ShiftID
    INNER JOIN Dim.DimDate AS startDate
        ON startDate.FullDate = CONVERT(date, edh.StartDate)
    LEFT JOIN Dim.DimDate AS endDate
        ON endDate.FullDate = CONVERT(date, edh.EndDate);

    IF (SELECT COUNT_BIG(*) FROM Fact.FactEmployeeDepartmentHistory)
       <> (SELECT COUNT_BIG(*) FROM AdventureWorks2025.HumanResources.EmployeeDepartmentHistory)
    BEGIN
        ;THROW 51003, 'FactEmployeeDepartmentHistory row count does not match the source. Check employee, department, shift, and date mappings.', 1;
    END;
END;
GO

/*==============================================================
  4. Employee pay history fact
  Grain: one row per EmployeePayHistory record
==============================================================*/
CREATE OR ALTER PROCEDURE etl.usp_LoadFactEmployeePayHistory
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM Fact.FactEmployeePayHistory;

    INSERT INTO Fact.FactEmployeePayHistory
    (
        EmployeeKey,
        PayFrequencyKey,
        RateChangeDateKey,
        Rate
    )
    SELECT
        de.EmployeeKey,
        dpf.PayFrequencyKey,
        dt.DateKey,
        eph.Rate
    FROM AdventureWorks2025.HumanResources.EmployeePayHistory AS eph
    INNER JOIN Dim.DimEmployee AS de
        ON de.EmployeeID = eph.BusinessEntityID
    INNER JOIN Dim.DimPayFrequency AS dpf
        ON dpf.PayFrequencyCode = eph.PayFrequency
    INNER JOIN Dim.DimDate AS dt
        ON dt.FullDate = CONVERT(date, eph.RateChangeDate);

    IF (SELECT COUNT_BIG(*) FROM Fact.FactEmployeePayHistory)
       <> (SELECT COUNT_BIG(*) FROM AdventureWorks2025.HumanResources.EmployeePayHistory)
    BEGIN
        ;THROW 51004, 'FactEmployeePayHistory row count does not match the source. Check employee, pay frequency, and date mappings.', 1;
    END;
END;
GO

/*==============================================================
  5. Master HR ETL procedure
==============================================================*/
CREATE OR ALTER PROCEDURE etl.usp_RunHRETL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        EXEC etl.usp_LoadHRDimensions;
        EXEC etl.usp_LoadFactEmployeeSnapshot;
        EXEC etl.usp_LoadFactEmployeeDepartmentHistory;
        EXEC etl.usp_LoadFactEmployeePayHistory;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH;
END;
GO

/*==============================================================
  6. Verify procedure creation
==============================================================*/
SELECT
    SCHEMA_NAME(schema_id) AS SchemaName,
    name AS ProcedureName
FROM sys.procedures
WHERE schema_id = SCHEMA_ID('etl')
  AND name IN
  (
      'usp_LoadHRDimensions',
      'usp_LoadFactEmployeeSnapshot',
      'usp_LoadFactEmployeeDepartmentHistory',
      'usp_LoadFactEmployeePayHistory',
      'usp_RunHRETL'
  )
ORDER BY name;
GO
