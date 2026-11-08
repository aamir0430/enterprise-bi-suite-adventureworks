USE EnterpriseBI_DW
GO

-- 1. Verifying the FactCurrencyRate table row counts
SELECT
    COUNT_BIG(*) AS TotalRows,
    COUNT(DISTINCT CurrencyRateID) AS DistinctCurrencyRates
FROM Fact.FactCurrencyRate;
GO

-- 2. Checking missing mappings

SELECT COUNT_BIG(*) AS MissingMappings
FROM Fact.FactCurrencyRate
WHERE CurrencyRateDateKey IS NULL
   OR FromCurrencyKey IS NULL
   OR ToCurrencyKey IS NULL;
GO