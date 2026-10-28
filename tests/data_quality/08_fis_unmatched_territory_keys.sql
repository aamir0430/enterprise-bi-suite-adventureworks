USE AdventureWorksDW2025
GO

SELECT DISTINCT f.SalesTerritoryKey
FROM dbo.FactInternetSales AS f
LEFT JOIN dbo.DimSalesTerritory AS d
    ON f.SalesTerritoryKey = d.SalesTerritoryKey
WHERE d.SalesTerritoryKey IS NULL;