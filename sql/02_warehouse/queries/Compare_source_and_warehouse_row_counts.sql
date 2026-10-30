USE EnterpriseBI_DW
GO

SELECT
    (
        SELECT COUNT(*)
        FROM AdventureWorks2025.Sales.SalesOrderDetail
    ) AS SourceSalesLines,

    (
        SELECT COUNT(*)
        FROM EnterpriseBI_DW.Fact.FactSales
    ) AS WarehouseSalesLines;

SELECT
    (
        SELECT COUNT(*)
        FROM AdventureWorks2025.Sales.SalesOrderHeader
    ) AS SourceOrders,

    (
        SELECT COUNT(*)
        FROM EnterpriseBI_DW.Fact.FactSalesOrderHeader
    ) AS WarehouseOrders;