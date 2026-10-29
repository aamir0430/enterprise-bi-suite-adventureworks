USE AdventureWorksDW2025;
GO

SELECT
    TABLE_NAME,
    COLUMN_NAME,
    DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'dbo'
  AND TABLE_NAME IN (
      'DimProduct',
      'DimProductSubcategory',
      'DimProductCategory'
  )
ORDER BY
    TABLE_NAME,
    ORDINAL_POSITION;

SELECT
    p.ProductKey,
    p.EnglishProductName,
    p.ProductSubcategoryKey,
    ps.EnglishProductSubcategoryName,
    pc.EnglishProductCategoryName
FROM dbo.DimProduct AS p
LEFT JOIN dbo.DimProductSubcategory AS ps
    ON p.ProductSubcategoryKey = ps.ProductSubcategoryKey
LEFT JOIN dbo.DimProductCategory AS pc
    ON ps.ProductCategoryKey = pc.ProductCategoryKey
ORDER BY p.ProductKey;

SELECT
    COUNT(*) AS ProductsWithoutMatchingSubcategory
FROM dbo.DimProduct AS p
LEFT JOIN dbo.DimProductSubcategory AS ps
    ON p.ProductSubcategoryKey = ps.ProductSubcategoryKey
WHERE p.ProductSubcategoryKey IS NOT NULL
  AND ps.ProductSubcategoryKey IS NULL;