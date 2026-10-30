USE EnterpriseBI_DW
GO


--Checking duplicate sales lines for FactSales
SELECT
    SalesOrderID,
    SalesOrderDetailID,
    COUNT(*) AS DuplicateCount
FROM Fact.FactSales
GROUP BY
    SalesOrderID,
    SalesOrderDetailID
HAVING COUNT(*) > 1;

--Checking Duplicate Order for FactSalesOrderHeader
SELECT
    SalesOrderID,
    COUNT(*) AS DuplicateCount
FROM Fact.FactSalesOrderHeader
GROUP BY SalesOrderID
HAVING COUNT(*) > 1;