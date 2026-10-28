USE AdventureWorksDW2025
GO

SELECT
    COUNT_BIG(*) AS TotalRows,
    SUM(CASE WHEN ProductKey IS NULL THEN 1 ELSE 0 END) AS NullProductKey,
    SUM(CASE WHEN OrderDateKey IS NULL THEN 1 ELSE 0 END) AS NullOrderDateKey,
    SUM(CASE WHEN CustomerKey IS NULL THEN 1 ELSE 0 END) AS NullCustomerKey,
    SUM(CASE WHEN SalesTerritoryKey IS NULL THEN 1 ELSE 0 END) AS NullTerritoryKey,
    SUM(CASE WHEN SalesOrderNumber IS NULL THEN 1 ELSE 0 END) AS NullOrderNumber,
    SUM(CASE WHEN SalesAmount IS NULL THEN 1 ELSE 0 END) AS NullSalesAmount,
    SUM(CASE WHEN TotalProductCost IS NULL THEN 1 ELSE 0 END) AS NullTotalProductCost
FROM dbo.FactInternetSales;