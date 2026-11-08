USE EnterpriseBI_DW;
GO

SELECT 'FactPurchaseOrderHeader' AS TableName,
       COUNT_BIG(*) AS TotalRows
FROM Fact.FactPurchaseOrderHeader

UNION ALL

SELECT 'FactPurchaseOrders', COUNT_BIG(*)
FROM Fact.FactPurchaseOrders

UNION ALL

SELECT 'FactCurrencyRate', COUNT_BIG(*)
FROM Fact.FactCurrencyRate;
GO