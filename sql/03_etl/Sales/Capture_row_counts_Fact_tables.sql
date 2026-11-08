USE EnterpriseBI_DW;
GO

SELECT 'FactSales' AS TableName, COUNT_BIG(*) AS TotalRows
FROM Fact.FactSales

UNION ALL

SELECT 'FactSalesOrderHeader', COUNT_BIG(*)
FROM Fact.FactSalesOrderHeader;
GO