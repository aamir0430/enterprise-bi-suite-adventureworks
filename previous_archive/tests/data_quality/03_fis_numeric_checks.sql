USE AdventureWorksDW2025
GO

SELECT
    SUM(CASE WHEN OrderQuantity <= 0 THEN 1 ELSE 0 END)
        AS NonPositiveQuantity,
    SUM(CASE WHEN UnitPrice < 0 THEN 1 ELSE 0 END)
        AS NegativeUnitPrice,
    SUM(CASE WHEN SalesAmount < 0 THEN 1 ELSE 0 END)
        AS NegativeSalesAmount,
    SUM(CASE WHEN TotalProductCost < 0 THEN 1 ELSE 0 END)
        AS NegativeTotalProductCost,
    SUM(CASE WHEN DiscountAmount < 0 THEN 1 ELSE 0 END)
        AS NegativeDiscountAmount,
    SUM(CASE WHEN UnitPriceDiscountPct < 0
               OR UnitPriceDiscountPct > 1 THEN 1 ELSE 0 END)
        AS InvalidDiscountFraction
FROM dbo.FactInternetSales;