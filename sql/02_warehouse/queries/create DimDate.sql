--Generating my own DimDate. Not extracting a date dimension from AdventureWorks

USE EnterpriseBI_DW;
GO

SET LANGUAGE English;
GO

BEGIN TRY
    BEGIN TRANSACTION;

    DECLARE @StartDate DATE = '20060630';
    DECLARE @EndDate DATE = '20091231';

    ;WITH CalendarDates AS
    (
        SELECT @StartDate AS CalendarDate

        UNION ALL

        SELECT DATEADD(DAY, 1, CalendarDate)
        FROM CalendarDates
        WHERE CalendarDate < @EndDate
    )

    INSERT INTO Dim.DimDate
    (
        DateKey,
        FullDate,
        DayNumber,
        DayName,
        MonthNumber,
        MonthName,
        QuarterNumber,
        YearNumber,
        QuarterName,
        HalfYearNumber,
        IsWeekday
    )
    SELECT
        CONVERT(INT, CONVERT(CHAR(8), C.CalendarDate, 112)),
        C.CalendarDate,
        DAY(C.CalendarDate),
        DATENAME(WEEKDAY, C.CalendarDate),
        MONTH(C.CalendarDate),
        DATENAME(MONTH, C.CalendarDate),
        DATEPART(QUARTER, C.CalendarDate),
        YEAR(C.CalendarDate),
        'Q' + CAST(DATEPART(QUARTER, C.CalendarDate) AS VARCHAR(1)),
        CASE
            WHEN MONTH(C.CalendarDate) <= 6 THEN 1
            ELSE 2
        END,
        CASE
            WHEN DATEDIFF(DAY, '19000101', C.CalendarDate) % 7
                 BETWEEN 0 AND 4
            THEN 1
            ELSE 0
        END
    FROM CalendarDates C
    WHERE NOT EXISTS
    (
        SELECT 1
        FROM Dim.DimDate D
        WHERE D.DateKey =
            CONVERT(INT, CONVERT(CHAR(8), C.CalendarDate, 112))
    )
    OPTION (MAXRECURSION 0);

    SELECT
        @@ROWCOUNT AS InsertedDateRecords;

    COMMIT TRANSACTION;

END TRY
BEGIN CATCH

    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    THROW;

END CATCH;
GO

-- Validation of DimDate table:
SELECT
    MIN(FullDate) AS EarliestDimDate,
    MAX(FullDate) AS LatestDimDate,
    COUNT(*) AS TotalDateRecords,
    COUNT(DISTINCT DateKey) AS DistinctDateKeys
FROM Dim.DimDate;