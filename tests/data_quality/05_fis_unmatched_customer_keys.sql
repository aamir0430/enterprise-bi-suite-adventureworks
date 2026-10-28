USE AdventureWorksDW2025
GO

SELECT DISTINCT f.CustomerKey
FROM dbo.FactInternetSales AS f
LEFT JOIN dbo.DimCustomer AS c
    ON f.CustomerKey = c.CustomerKey
WHERE c.CustomerKey IS NULL;