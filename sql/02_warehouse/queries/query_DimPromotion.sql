USE EnterpriseBI_DW;
GO

DROP TABLE IF EXISTS Dim.DimPromotion;
GO

SELECT
    IDENTITY(INT, 1, 1) AS PromotionKey,

    CAST(SpecialOfferID AS INT) AS SpecialOfferID,

    Description AS PromotionDescription,
    DiscountPct,
    Type AS PromotionType,
    Category AS PromotionCategory,
    StartDate,
    EndDate,
    MinQty,
    MaxQty

INTO Dim.DimPromotion

FROM AdventureWorks2025.Sales.SpecialOffer;
GO