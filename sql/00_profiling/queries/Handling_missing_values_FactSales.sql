USE EnterpriseBI_DW
GO

-- 1. Investigating missing salesperson keys
SELECT
    OnlineOrderFlag,
    COUNT(*) AS TotalSalesLines,
    SUM(
        CASE WHEN SalesPersonKey IS NULL
             THEN 1 ELSE 0 END
    ) AS MissingSalesPerson,
    SUM(
        CASE WHEN SalesPersonKey IS NOT NULL
             THEN 1 ELSE 0 END
    ) AS AssignedSalesPerson
FROM Fact.FactSales
GROUP BY OnlineOrderFlag;

-- 2. Investigating missing currency information
SELECT
    COUNT(*) AS TotalRows,
    SUM(CASE WHEN CurrencyKey IS NULL
             THEN 1 ELSE 0 END) AS MissingCurrencyKey,
    SUM(CASE WHEN CurrencyRateID IS NULL
             THEN 1 ELSE 0 END) AS MissingCurrencyRateID,
    SUM(CASE WHEN CurrencyKey IS NOT NULL
              AND CurrencyRateID IS NULL
             THEN 1 ELSE 0 END) AS CurrencyWithoutRate,
    SUM(CASE WHEN CurrencyKey IS NULL
              AND CurrencyRateID IS NOT NULL
             THEN 1 ELSE 0 END) AS RateWithoutCurrency
FROM Fact.FactSales;