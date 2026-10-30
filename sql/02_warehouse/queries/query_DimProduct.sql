USE EnterpriseBI_DW
GO

SELECT
    IDENTITY(INT, 1, 1) AS ProductKey,

    P.ProductID,
    P.Name AS ProductName,
    P.ProductNumber,

    P.Color,
    P.Size,
    P.Weight,

    P.StandardCost,
    P.ListPrice,

    P.ProductLine,
    P.Class,
    P.Style,

    P.MakeFlag,
    P.FinishedGoodsFlag,

    P.SafetyStockLevel,
    P.ReorderPoint,

    P.ProductSubcategoryID,
    PSC.Name AS SubcategoryName,

    PC.ProductCategoryID,
    PC.Name AS CategoryName,

    P.ProductModelID,
    PM.Name AS ProductModelName,

    P.SellStartDate,
    P.SellEndDate,
    P.DiscontinuedDate

INTO Dim.DimProduct

FROM AdventureWorks2025.Production.Product P

LEFT JOIN AdventureWorks2025.Production.ProductSubcategory PSC
    ON P.ProductSubcategoryID = PSC.ProductSubcategoryID

LEFT JOIN AdventureWorks2025.Production.ProductCategory PC
    ON PSC.ProductCategoryID = PC.ProductCategoryID

LEFT JOIN AdventureWorks2025.Production.ProductModel PM
    ON P.ProductModelID = PM.ProductModelID;
GO