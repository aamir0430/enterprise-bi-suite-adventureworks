USE EnterpriseBI_DW
GO

SELECT
    COUNT(*) AS TotalSalesLines,
    COUNT(DISTINCT SalesOrderID) AS TotalOrders,
    COUNT(DISTINCT ProductKey) AS ProductsSold,
    SUM(OrderQty) AS TotalQuantity,
    SUM(LineTotal) AS TotalSalesRevenue
FROM Fact.FactSales;