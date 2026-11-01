USE EnterpriseBI_DW
GO

--Validating product identifiers and duplicates
--Validating ProductKey and ProductID
SELECT
    COUNT(*) AS TotalRows,
    COUNT(DISTINCT ProductKey) AS DistinctProductKeys,
    COUNT(DISTINCT ProductID) AS DistinctProductIDs,
    SUM(CASE WHEN ProductKey IS NULL THEN 1 ELSE 0 END)
        AS NullProductKeys,
    SUM(CASE WHEN ProductID IS NULL THEN 1 ELSE 0 END)
        AS NullProductIDs
FROM Dim.DimProduct;

--Checking duplicate ProductID
SELECT
    ProductID,
    COUNT(*) AS DuplicateCount
FROM Dim.DimProduct
GROUP BY ProductID
HAVING COUNT(*) > 1;

--Checking duplicate ProductNumber
SELECT
    ProductNumber,
    COUNT(*) AS DuplicateCount
FROM Dim.DimProduct
GROUP BY ProductNumber
HAVING COUNT(*) > 1;

--Validating prices, costs, and stock levels
--Checking negative or invalid prices and costs
SELECT *
FROM Dim.DimProduct
WHERE StandardCost < 0
   OR ListPrice < 0;

--Checking negative stock levels
SELECT *
FROM Dim.DimProduct
WHERE SafetyStockLevel < 0
   OR ReorderPoint < 0;

--Reviewing weight values
SELECT *
FROM Dim.DimProduct
WHERE Weight <= 0
  AND Weight IS NOT NULL;

--Validating product categories and models
--Checking subcategory and category consistency
SELECT *
FROM Dim.DimProduct
WHERE
    (ProductSubcategoryID IS NULL
     AND SubcategoryName IS NOT NULL)
 OR (ProductSubcategoryID IS NOT NULL
     AND SubcategoryName IS NULL)
 OR (ProductCategoryID IS NULL
     AND CategoryName IS NOT NULL)
 OR (ProductCategoryID IS NOT NULL
     AND CategoryName IS NULL);

--Checking product model consistency
SELECT *
FROM Dim.DimProduct
WHERE
    (ProductModelID IS NULL
     AND ProductModelName IS NOT NULL)
 OR (ProductModelID IS NOT NULL
     AND ProductModelName IS NULL);

--Validating product dates
SELECT *
FROM Dim.DimProduct
WHERE
    (SellEndDate IS NOT NULL
     AND SellEndDate < SellStartDate)
 OR (DiscontinuedDate IS NOT NULL
     AND DiscontinuedDate < SellStartDate);

--Verifying the DiscontinuedDate column
SELECT
    COUNT(*) AS TotalProducts,
    SUM(
        CASE WHEN DiscontinuedDate IS NULL
             THEN 1 ELSE 0 END
    ) AS NullDiscontinuedDates,
    SUM(
        CASE WHEN DiscontinuedDate IS NOT NULL
             THEN 1 ELSE 0 END
    ) AS PopulatedDiscontinuedDates
FROM AdventureWorks2025.Production.Product;