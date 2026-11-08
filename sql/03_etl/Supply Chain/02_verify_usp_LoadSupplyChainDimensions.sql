USE EnterpriseBI_DW
GO

-- 1. Verifying warehouse row counts'

SELECT 'DimLocation' AS DimensionTable, COUNT(*) AS TotalRows
FROM Dim.DimLocation

UNION ALL

SELECT 'DimScrapReason', COUNT(*)
FROM Dim.DimScrapReason

UNION ALL

SELECT 'DimTransactionType', COUNT(*)
FROM Dim.DimTransactionType

UNION ALL

SELECT 'DimProduct', COUNT(*)
FROM Dim.DimProduct

UNION ALL

SELECT 'DimDate', COUNT(*)
FROM Dim.DimDate;
GO

-- 2. Verifying source row counts

SELECT 'Production.Location' AS SourceTable, COUNT(*) AS TotalRows
FROM AdventureWorks2025.Production.Location

UNION ALL

SELECT 'Production.ScrapReason', COUNT(*)
FROM AdventureWorks2025.Production.ScrapReason

UNION ALL

SELECT 'Production.TransactionHistory - Distinct Types',
       COUNT(DISTINCT TransactionType)
FROM AdventureWorks2025.Production.TransactionHistory

UNION ALL

SELECT 'Production.Product', COUNT(*)
FROM AdventureWorks2025.Production.Product;
GO

-- 3. Checking duplicate business keys

SELECT LocationID, COUNT(*) AS DuplicateCount
FROM Dim.DimLocation
GROUP BY LocationID
HAVING LocationID IS NULL OR COUNT(*) > 1;

SELECT ScrapReasonID, COUNT(*) AS DuplicateCount
FROM Dim.DimScrapReason
GROUP BY ScrapReasonID
HAVING ScrapReasonID IS NULL OR COUNT(*) > 1;

SELECT TransactionTypeCode, COUNT(*) AS DuplicateCount
FROM Dim.DimTransactionType
GROUP BY TransactionTypeCode
HAVING TransactionTypeCode IS NULL OR COUNT(*) > 1;

SELECT ProductID, COUNT(*) AS DuplicateCount
FROM Dim.DimProduct
GROUP BY ProductID
HAVING ProductID IS NULL OR COUNT(*) > 1;

SELECT FullDate, COUNT(*) AS DuplicateCount
FROM Dim.DimDate
GROUP BY FullDate
HAVING FullDate IS NULL OR COUNT(*) > 1;
GO

-- 4. Checking duplicate or NULL surrogate keys

SELECT LocationKey, COUNT(*) AS DuplicateCount
FROM Dim.DimLocation
GROUP BY LocationKey
HAVING LocationKey IS NULL OR COUNT(*) > 1;

SELECT ScrapReasonKey, COUNT(*) AS DuplicateCount
FROM Dim.DimScrapReason
GROUP BY ScrapReasonKey
HAVING ScrapReasonKey IS NULL OR COUNT(*) > 1;

SELECT TransactionTypeKey, COUNT(*) AS DuplicateCount
FROM Dim.DimTransactionType
GROUP BY TransactionTypeKey
HAVING TransactionTypeKey IS NULL OR COUNT(*) > 1;

SELECT ProductKey, COUNT(*) AS DuplicateCount
FROM Dim.DimProduct
GROUP BY ProductKey
HAVING ProductKey IS NULL OR COUNT(*) > 1;

SELECT DateKey, COUNT(*) AS DuplicateCount
FROM Dim.DimDate
GROUP BY DateKey
HAVING DateKey IS NULL OR COUNT(*) > 1;
GO

-- 5. Checking missing source-to-dimension mappings

USE EnterpriseBI_DW;
GO

SELECT LocationID AS MissingLocationID
FROM AdventureWorks2025.Production.Location
EXCEPT
SELECT LocationID
FROM Dim.DimLocation;

SELECT ScrapReasonID AS MissingScrapReasonID
FROM AdventureWorks2025.Production.ScrapReason
EXCEPT
SELECT ScrapReasonID
FROM Dim.DimScrapReason;

SELECT DISTINCT
    TransactionType COLLATE DATABASE_DEFAULT AS MissingTransactionType
FROM AdventureWorks2025.Production.TransactionHistory

EXCEPT

SELECT
    TransactionTypeCode COLLATE DATABASE_DEFAULT
FROM Dim.DimTransactionType;

SELECT ProductID AS MissingProductID
FROM AdventureWorks2025.Production.Product
EXCEPT
SELECT ProductID
FROM Dim.DimProduct;
GO

-- 6. Validating DimDate coverage

SELECT RequiredDates.SourceDate AS MissingDate
FROM
(
    SELECT CONVERT(date, TransactionDate) AS SourceDate
    FROM AdventureWorks2025.Production.TransactionHistory

    UNION

    SELECT CONVERT(date, DueDate)
    FROM AdventureWorks2025.Production.WorkOrder

    UNION

    SELECT CONVERT(date, StartDate)
    FROM AdventureWorks2025.Production.WorkOrder

    UNION

    SELECT CONVERT(date, EndDate)
    FROM AdventureWorks2025.Production.WorkOrder
    WHERE EndDate IS NOT NULL
) AS RequiredDates
EXCEPT
SELECT FullDate
FROM Dim.DimDate;
GO