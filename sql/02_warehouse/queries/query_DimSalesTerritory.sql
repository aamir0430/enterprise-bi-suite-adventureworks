USE EnterpriseBI_DW;
GO

DROP TABLE IF EXISTS Dim.DimSalesTerritory;
GO

SELECT
    IDENTITY(INT, 1, 1) AS SalesTerritoryKey,

    CAST(TerritoryID AS INT) AS TerritoryID,

    Name AS TerritoryName,
    CountryRegionCode,
    [Group] AS TerritoryGroup,
    SalesYTD,
    SalesLastYear,
    CostYTD,
    CostLastYear

INTO Dim.DimSalesTerritory

FROM AdventureWorks2025.Sales.SalesTerritory;
GO