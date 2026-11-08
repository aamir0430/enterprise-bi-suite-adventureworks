USE EnterpriseBI_DW;
GO

-- Verifying the total no. of records

SELECT
    COUNT_BIG(*) AS TotalRows
FROM Fact.FactSales;
GO

-- Checking duplicate Sales order lines

SELECT
    SalesOrderID,
    SalesOrderDetailID,
    COUNT(*) AS DuplicateCount
FROM Fact.FactSales
GROUP BY
    SalesOrderID,
    SalesOrderDetailID
HAVING COUNT(*) > 1;
GO

-- Checking for missing dimension mappings

USE EnterpriseBI_DW;
GO

SELECT
    COUNT_BIG(*) AS MissingDimensionMappings
FROM Fact.FactSales F
LEFT JOIN Dim.DimCustomer C
    ON F.CustomerKey = C.CustomerKey
LEFT JOIN Dim.DimProduct P
    ON F.ProductKey = P.ProductKey
LEFT JOIN Dim.DimSalesTerritory T
    ON F.SalesTerritoryKey = T.SalesTerritoryKey
WHERE
    C.CustomerKey IS NULL
    OR P.ProductKey IS NULL
    OR (
        F.SalesTerritoryKey IS NOT NULL
        AND T.SalesTerritoryKey IS NULL
    );
GO