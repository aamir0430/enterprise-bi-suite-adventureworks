USE AdventureWorksDW2025
GO

SELECT DISTINCT f.ProductKey
FROM dbo.FactInternetSales AS f
LEFT JOIN dbo.DimProduct AS p
    ON f.ProductKey = p.ProductKey
WHERE p.ProductKey IS NULL;