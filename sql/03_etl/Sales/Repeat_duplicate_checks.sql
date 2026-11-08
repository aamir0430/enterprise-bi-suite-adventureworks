USE EnterpriseBI_DW;
GO

-- Duplicate sales orders
SELECT SalesOrderID, COUNT(*) AS DuplicateCount
FROM Fact.FactSalesOrderHeader
GROUP BY SalesOrderID
HAVING COUNT(*) > 1;

-- Duplicate sales order lines
SELECT
    SalesOrderID,
    SalesOrderDetailID,
    COUNT(*) AS DuplicateCount
FROM Fact.FactSales
GROUP BY SalesOrderID, SalesOrderDetailID
HAVING COUNT(*) > 1;
GO