USE AdventureWorksDW2025
GO

SELECT DISTINCT f.OrderDateKey
FROM dbo.FactInternetSales AS f
LEFT JOIN dbo.DimDate AS d
    ON f.OrderDateKey = d.DateKey
WHERE d.DateKey IS NULL;