USE AdventureWorksDW2025
GO

SELECT
    COUNT_BIG(*) AS TotalRows,
    COUNT(DISTINCT SalesOrderNumber) AS DistinctOrders,
    SUM(OrderQuantity) AS TotalUnitsSold,
    SUM(SalesAmount) AS TotalSales,
    SUM(TotalProductCost) AS TotalProductCost,
    SUM(DiscountAmount) AS TotalDiscount,
    SUM(TaxAmt) AS TotalTax,
    SUM(Freight) AS TotalFreight
FROM dbo.FactInternetSales;