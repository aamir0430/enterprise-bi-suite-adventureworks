SELECT 'DimProduct' AS TableName, COUNT(*) AS TotalRows
FROM Dim.DimProduct

UNION ALL
SELECT 'DimLocation', COUNT(*)
FROM Dim.DimLocation

UNION ALL
SELECT 'DimScrapReason', COUNT(*)
FROM Dim.DimScrapReason

UNION ALL
SELECT 'DimTransactionType', COUNT(*)
FROM Dim.DimTransactionType

UNION ALL
SELECT 'DimDate', COUNT(*)
FROM Dim.DimDate

UNION ALL
SELECT 'FactInventorySnapshot', COUNT(*)
FROM Fact.FactInventorySnapshot

UNION ALL
SELECT 'FactInventoryTransaction', COUNT(*)
FROM Fact.FactInventoryTransaction

UNION ALL
SELECT 'FactWorkOrder', COUNT(*)
FROM Fact.FactWorkOrder

UNION ALL
SELECT 'FactPurchaseOrders', COUNT(*)
FROM Fact.FactPurchaseOrders;
GO