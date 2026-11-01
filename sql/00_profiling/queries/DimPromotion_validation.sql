USE EnterpriseBI_DW
GO

-- Validating primary keys and duplicates:

-- 1. Validating table row count and keys
SELECT
    COUNT(*) AS TotalRows,
    COUNT(DISTINCT PromotionKey) AS DistinctPromotionKeys,
    COUNT(DISTINCT SpecialOfferID) AS DistinctSpecialOfferIDs,
    SUM(CASE WHEN PromotionKey IS NULL THEN 1 ELSE 0 END)
        AS NullPromotionKeys,
    SUM(CASE WHEN SpecialOfferID IS NULL THEN 1 ELSE 0 END)
        AS NullSpecialOfferIDs
FROM Dim.DimPromotion;

-- 2. Checking duplicate SpecialOfferID values
SELECT
    SpecialOfferID,
    COUNT(*) AS DuplicateCount
FROM Dim.DimPromotion
GROUP BY SpecialOfferID
HAVING COUNT(*) > 1;

-- 3. Checking duplicate promotion descriptions
SELECT
    PromotionDescription,
    COUNT(*) AS DuplicateCount
FROM Dim.DimPromotion
GROUP BY PromotionDescription
HAVING COUNT(*) > 1;

-- Validating discount percentages:

-- Checking whether the values fall within a valid percentage range
SELECT *
FROM Dim.DimPromotion
WHERE DiscountPct < 0
   OR DiscountPct > 1;

-- Validating Promotion dates:

-- 1. Checking whether any promotion ends before it starts
SELECT *
FROM Dim.DimPromotion
WHERE EndDate < StartDate;

-- 2. Checking whether the dates contain reasonable values
SELECT
    MIN(StartDate) AS EarliestStartDate,
    MAX(StartDate) AS LatestStartDate,
    MIN(EndDate) AS EarliestEndDate,
    MAX(EndDate) AS LatestEndDate
FROM Dim.DimPromotion;

-- Validating minimum and maximum quantities:

-- 1. Checking invalid quantity values
SELECT *
FROM Dim.DimPromotion
WHERE MinQty < 0
   OR MaxQty < 0;

-- 2. Checking whether quantity is less than minimum quantity
SELECT *
FROM Dim.DimPromotion
WHERE MaxQty IS NOT NULL
  AND MaxQty < MinQty;

-- 3. Reviewing the distribution of maximum quantities
SELECT
    MinQty,
    MaxQty,
    COUNT(*) AS PromotionCount
FROM Dim.DimPromotion
GROUP BY MinQty, MaxQty
ORDER BY MinQty, MaxQty;