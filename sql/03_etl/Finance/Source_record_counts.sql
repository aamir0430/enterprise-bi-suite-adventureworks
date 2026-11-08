USE EnterpriseBI_DW;
GO

-- Checking source record counts

SELECT
    'Vendor' AS SourceTable,
    COUNT_BIG(*) AS TotalRows
FROM AdventureWorks2025.Purchasing.Vendor

UNION ALL

SELECT
    'Employee',
    COUNT_BIG(*)
FROM AdventureWorks2025.HumanResources.Employee

UNION ALL

SELECT
    'Product',
    COUNT_BIG(*)
FROM AdventureWorks2025.Production.Product

UNION ALL

SELECT
    'ShipMethod',
    COUNT_BIG(*)
FROM AdventureWorks2025.Purchasing.ShipMethod

UNION ALL

SELECT
    'Currency',
    COUNT_BIG(*)
FROM AdventureWorks2025.Sales.Currency

UNION ALL

SELECT
    'PurchaseOrderHeader',
    COUNT_BIG(*)
FROM AdventureWorks2025.Purchasing.PurchaseOrderHeader

UNION ALL

SELECT
    'PurchaseOrderDetail',
    COUNT_BIG(*)
FROM AdventureWorks2025.Purchasing.PurchaseOrderDetail

UNION ALL

SELECT
    'CurrencyRate',
    COUNT_BIG(*)
FROM AdventureWorks2025.Sales.CurrencyRate;
GO
