--Generating my own DimDate. Not extracting a date dimension from AdventureWorks

USE EnterpriseBI_DW
GO

DECLARE @StartDate DATE = '2010-01-01';
DECLARE @EndDate DATE = '2035-12-31';

;WITH DateCalendar AS
(
    SELECT @StartDate AS FullDate

    UNION ALL

    SELECT DATEADD(DAY, 1, FullDate)
    FROM DateCalendar
    WHERE FullDate < @EndDate
)

SELECT
    CONVERT(INT, CONVERT(CHAR(8), FullDate, 112))
        AS DateKey,

    FullDate,

    DAY(FullDate) AS DayNumber,

    DATENAME(WEEKDAY, FullDate) AS DayName,

    MONTH(FullDate) AS MonthNumber,

    DATENAME(MONTH, FullDate) AS MonthName,

    DATEPART(QUARTER, FullDate) AS QuarterNumber,

    YEAR(FullDate) AS YearNumber,

    CONCAT(
        'Q',
        DATEPART(QUARTER, FullDate)
    ) AS QuarterName,

    CASE
        WHEN MONTH(FullDate) <= 6 THEN 1
        ELSE 2
    END AS HalfYearNumber,

    CASE
        WHEN DATENAME(WEEKDAY, FullDate)
             IN ('Saturday', 'Sunday')
        THEN 0
        ELSE 1
    END AS IsWeekday

INTO Dim.DimDate

FROM DateCalendar
OPTION (MAXRECURSION 0);
GO