USE EnterpriseBI_DW;
GO

SELECT
    COUNT_BIG(*) AS TotalRows
FROM Fact.FactSalesOrderHeader;
GO

SELECT
    SalesOrderID,
    COUNT(*) AS DuplicateCount
FROM Fact.FactSalesOrderHeader
GROUP BY SalesOrderID
HAVING COUNT(*) > 1;
GO