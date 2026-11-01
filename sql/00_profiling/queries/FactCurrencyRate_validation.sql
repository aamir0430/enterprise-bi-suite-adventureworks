USE EnterpriseBI_DW
GO

/*
Checking the currency columns:
1. FromCurrencyKey
2. ToCurrencyKey
*/

SELECT
    FromCurrencyKey,
    COUNT(*) AS TotalRecords
FROM Fact.FactCurrencyRate
GROUP BY FromCurrencyKey;

SELECT
    ToCurrencyKey,
    COUNT(*) AS TotalRecords
FROM Fact.FactCurrencyRate
GROUP BY ToCurrencyKey
ORDER BY ToCurrencyKey;

/*
Validating date consistency:

Columns:
1. CurrencyRateDateKey
2. CurrencyRateDate
*/

SELECT *
FROM Fact.FactCurrencyRate
WHERE CurrencyRateDateKey <>
      CONVERT(INT, CONVERT(CHAR(8), CurrencyRateDate, 112));

SELECT
    COUNT(*) AS TotalRows,
    COUNT(DISTINCT CurrencyRateDateKey) AS DistinctDateKeys,
    COUNT(DISTINCT CurrencyRateDate) AS DistinctDates,
    MIN(CurrencyRateDate) AS FirstRateDate,
    MAX(CurrencyRateDate) AS LastRateDate
FROM Fact.FactCurrencyRate;

-- Validating exchange rates:

SELECT *
FROM Fact.FactCurrencyRate
WHERE AverageRate <= 0
   OR EndOfDayRate <= 0;

-- Checking the overall distribution
SELECT
    MIN(AverageRate) AS MinimumAverageRate,
    MAX(AverageRate) AS MaximumAverageRate,
    AVG(AverageRate) AS MeanAverageRate,
    MIN(EndOfDayRate) AS MinimumEndOfDayRate,
    MAX(EndOfDayRate) AS MaximumEndOfDayRate,
    AVG(EndOfDayRate) AS MeanEndOfDayRate
FROM Fact.FactCurrencyRate;

-- Validating key uniqueness:

SELECT
    COUNT(*) AS TotalRows,
    COUNT(DISTINCT CurrencyRateFactKey) AS DistinctFactKeys,
    COUNT(DISTINCT CurrencyRateID) AS DistinctCurrencyRateIDs
FROM Fact.FactCurrencyRate;

-- Checking duplicates
SELECT
    CurrencyRateID,
    COUNT(*) AS DuplicateCount
FROM Fact.FactCurrencyRate
GROUP BY CurrencyRateID
HAVING COUNT(*) > 1;

/*
Validating dimension relationships:
    1. DimDate through CurrencyRateDateKey
    2. DimCurrency through FromCurrencyKey
    3. DimCurrency through ToCurrencyKey
*/

SELECT 'CurrencyRateDateKey' AS ColumnName,
       COUNT(*) AS InvalidRows
FROM Fact.FactCurrencyRate f
LEFT JOIN Dim.DimDate d
    ON f.CurrencyRateDateKey = d.DateKey
WHERE d.DateKey IS NULL

UNION ALL

SELECT 'FromCurrencyKey',
       COUNT(*)
FROM Fact.FactCurrencyRate f
LEFT JOIN Dim.DimCurrency d
    ON f.FromCurrencyKey = d.CurrencyKey
WHERE d.CurrencyKey IS NULL

UNION ALL

SELECT 'ToCurrencyKey',
       COUNT(*)
FROM Fact.FactCurrencyRate f
LEFT JOIN Dim.DimCurrency d
    ON f.ToCurrencyKey = d.CurrencyKey
WHERE d.CurrencyKey IS NULL;