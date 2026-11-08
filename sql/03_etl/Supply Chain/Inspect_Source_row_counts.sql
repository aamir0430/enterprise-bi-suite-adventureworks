SELECT 'Production.Product' AS SourceTable, COUNT(*) AS TotalRows
FROM AdventureWorks2025.Production.Product

UNION ALL
SELECT 'Production.Location', COUNT(*)
FROM AdventureWorks2025.Production.Location

UNION ALL
SELECT 'Production.ScrapReason', COUNT(*)
FROM AdventureWorks2025.Production.ScrapReason

UNION ALL
SELECT 'Production.TransactionHistory', COUNT(*)
FROM AdventureWorks2025.Production.TransactionHistory

UNION ALL
SELECT 'Production.ProductInventory', COUNT(*)
FROM AdventureWorks2025.Production.ProductInventory

UNION ALL
SELECT 'Production.WorkOrder', COUNT(*)
FROM AdventureWorks2025.Production.WorkOrder

UNION ALL
SELECT 'Purchasing.PurchaseOrderDetail', COUNT(*)
FROM AdventureWorks2025.Purchasing.PurchaseOrderDetail;
GO