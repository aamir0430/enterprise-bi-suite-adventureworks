USE EnterpriseBI_DW
GO

-- Validating primary and business keys:

-- 1. Validating row count and keys
SELECT
    COUNT(*) AS TotalRows,
    COUNT(DISTINCT CurrencyKey) AS DistinctCurrencyKeys,
    COUNT(DISTINCT CurrencyCode) AS DistinctCurrencyCodes,
    SUM(CASE WHEN CurrencyKey IS NULL THEN 1 ELSE 0 END)
        AS NullCurrencyKeys,
    SUM(CASE WHEN CurrencyCode IS NULL THEN 1 ELSE 0 END)
        AS NullCurrencyCodes
FROM Dim.DimCurrency;

-- 2. Checking duplicate currency codes
SELECT
    CurrencyCode,
    COUNT(*) AS DuplicateCount
FROM Dim.DimCurrency
GROUP BY CurrencyCode
HAVING COUNT(*) > 1;

-- 3. Checking duplicate currency names
SELECT
    CurrencyName,
    COUNT(*) AS DuplicateCount
FROM Dim.DimCurrency
GROUP BY CurrencyName
HAVING COUNT(*) > 1;

-- Validating currency codes:

-- 1. Checking for blank or whitespace-only currency codes
SELECT *
FROM Dim.DimCurrency
WHERE CurrencyCode IS NULL
   OR LTRIM(RTRIM(CurrencyCode)) = '';

-- Inspecting currency codes that do not have exactly three characters
SELECT *
FROM Dim.DimCurrency
WHERE LEN(CurrencyCode) <> 3;