USE AdventureWorksDW2025
GO

SELECT DISTINCT f.PromotionKey
FROM dbo.FactInternetSales AS f
LEFT JOIN dbo.DimPromotion AS d
    ON f.PromotionKey = d.PromotionKey
WHERE d.PromotionKey IS NULL;