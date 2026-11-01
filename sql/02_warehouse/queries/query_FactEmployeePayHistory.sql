USE EnterpriseBI_DW;
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

IF OBJECT_ID('Fact.FactEmployeePayHistory', 'U') IS NULL
BEGIN

    CREATE TABLE Fact.FactEmployeePayHistory
    (
        PayHistoryFactKey BIGINT IDENTITY(1,1) NOT NULL,

        EmployeeKey INT NOT NULL,
        PayFrequencyKey INT NOT NULL,
        RateChangeDateKey INT NOT NULL,
        Rate MONEY NOT NULL,

        CONSTRAINT PK_FactEmployeePayHistory
            PRIMARY KEY (PayHistoryFactKey),

        CONSTRAINT UQ_EmployeePayHistory
            UNIQUE (EmployeeKey, RateChangeDateKey),

        CONSTRAINT FK_PayHistory_Employee
            FOREIGN KEY (EmployeeKey)
            REFERENCES Dim.DimEmployee(EmployeeKey),

        CONSTRAINT FK_PayHistory_Frequency
            FOREIGN KEY (PayFrequencyKey)
            REFERENCES Dim.DimPayFrequency(PayFrequencyKey),

        CONSTRAINT FK_PayHistory_Date
            FOREIGN KEY (RateChangeDateKey)
            REFERENCES Dim.DimDate(DateKey)
    );

    PRINT 'FactEmployeePayHistory table created.';

END
ELSE
BEGIN

    PRINT 'FactEmployeePayHistory table already exists.';

END;
GO

IF EXISTS
(
    SELECT 1
    FROM AdventureWorks2025.HumanResources.EmployeePayHistory PH

    LEFT JOIN Dim.DimEmployee DE
        ON PH.BusinessEntityID = DE.EmployeeID

    LEFT JOIN Dim.DimPayFrequency DPF
        ON PH.PayFrequency = DPF.PayFrequencyCode

    LEFT JOIN Dim.DimDate DD
        ON CONVERT(INT, CONVERT(CHAR(8), PH.RateChangeDate, 112))
           = DD.DateKey

    WHERE DE.EmployeeKey IS NULL
       OR DPF.PayFrequencyKey IS NULL
       OR DD.DateKey IS NULL
)
BEGIN

    THROW 50001,
    'ETL stopped: One or more employee pay-history records have missing employee, pay-frequency, or date dimension matches.',
    1;

END;

PRINT 'All source records match the required dimensions.';
GO

IF EXISTS
(
    SELECT
        PH.BusinessEntityID,
        PH.RateChangeDate
    FROM AdventureWorks2025.HumanResources.EmployeePayHistory PH

    GROUP BY
        PH.BusinessEntityID,
        PH.RateChangeDate

    HAVING COUNT(*) > 1
)
BEGIN

    THROW 50002,
    'ETL stopped: Duplicate employee and rate-change-date combinations exist in the source.',
    1;

END;

PRINT 'Source natural-key uniqueness check passed.';
GO

BEGIN TRY

    BEGIN TRANSACTION;

    INSERT INTO Fact.FactEmployeePayHistory
    (
        EmployeeKey,
        PayFrequencyKey,
        RateChangeDateKey,
        Rate
    )

    SELECT
        DE.EmployeeKey,
        DPF.PayFrequencyKey,

        CONVERT(
            INT,
            CONVERT(CHAR(8), PH.RateChangeDate, 112)
        ),

        PH.Rate

    FROM AdventureWorks2025.HumanResources.EmployeePayHistory PH

    INNER JOIN Dim.DimEmployee DE
        ON PH.BusinessEntityID = DE.EmployeeID

    INNER JOIN Dim.DimPayFrequency DPF
        ON PH.PayFrequency = DPF.PayFrequencyCode

    INNER JOIN Dim.DimDate DD
        ON CONVERT(
            INT,
            CONVERT(CHAR(8), PH.RateChangeDate, 112)
        ) = DD.DateKey

    WHERE NOT EXISTS
    (
        SELECT 1

        FROM Fact.FactEmployeePayHistory F

        WHERE F.EmployeeKey = DE.EmployeeKey
          AND F.RateChangeDateKey =
              CONVERT(
                  INT,
                  CONVERT(CHAR(8), PH.RateChangeDate, 112)
              )
    );

    DECLARE @InsertedRows INT = @@ROWCOUNT;

    COMMIT TRANSACTION;

    PRINT 'Employee pay-history loading completed successfully.';

    SELECT
        @InsertedRows AS NewlyInsertedRows;

END TRY

BEGIN CATCH

    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    THROW;

END CATCH;
GO

-- Final Fact Table Validation
SELECT
    COUNT(*) AS TotalWarehouseRows,

    COUNT(DISTINCT PayHistoryFactKey)
        AS DistinctFactKeys,

    COUNT(DISTINCT EmployeeKey)
        AS DistinctEmployees,

    COUNT(DISTINCT RateChangeDateKey)
        AS DistinctRateChangeDates,

    MIN(RateChangeDateKey)
        AS EarliestRateChangeDateKey,

    MAX(RateChangeDateKey)
        AS LatestRateChangeDateKey,

    MIN(Rate) AS MinimumRate,

    MAX(Rate) AS MaximumRate

FROM Fact.FactEmployeePayHistory;
GO