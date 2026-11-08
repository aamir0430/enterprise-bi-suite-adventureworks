USE EnterpriseBI_DW;
GO

-- Checking existing warehouse row counts

SELECT 'DimVendor' AS TableName, COUNT_BIG(*) AS TotalRows
FROM Dim.DimVendor

UNION ALL
SELECT 'DimEmployee', COUNT_BIG(*) FROM Dim.DimEmployee

UNION ALL
SELECT 'DimProduct', COUNT_BIG(*) FROM Dim.DimProduct

UNION ALL
SELECT 'DimShipMethod', COUNT_BIG(*) FROM Dim.DimShipMethod

UNION ALL
SELECT 'DimCurrency', COUNT_BIG(*) FROM Dim.DimCurrency

UNION ALL
SELECT 'DimDate', COUNT_BIG(*) FROM Dim.DimDate

UNION ALL
SELECT 'FactPurchaseOrderHeader', COUNT_BIG(*)
FROM Fact.FactPurchaseOrderHeader

UNION ALL
SELECT 'FactPurchaseOrders', COUNT_BIG(*)
FROM Fact.FactPurchaseOrders

UNION ALL
SELECT 'FactCurrencyRate', COUNT_BIG(*)
FROM Fact.FactCurrencyRate;
GO
