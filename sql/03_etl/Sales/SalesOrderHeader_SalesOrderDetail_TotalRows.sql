USE EnterpriseBI_DW;
GO

SELECT
    'SalesOrderHeader' AS SourceTable,
    COUNT_BIG(*) AS TotalRows
FROM AdventureWorks2025.Sales.SalesOrderHeader

UNION ALL

SELECT
    'SalesOrderDetail',
    COUNT_BIG(*)
FROM AdventureWorks2025.Sales.SalesOrderDetail;
GO