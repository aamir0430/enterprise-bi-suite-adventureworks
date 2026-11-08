USE EnterpriseBI_DW
GO

-- 1. Verifying warehouse row counts

SELECT
    'FactInventoryTransaction' AS TableName,
    COUNT(*) AS WarehouseRows
FROM Fact.FactInventoryTransaction;

-- 2. Verifying source row counts

SELECT
    'Production.TransactionHistory' AS SourceTable,
    COUNT(*) AS SourceRows
FROM AdventureWorks2025.Production.TransactionHistory;
GO

-- 3. Checking duplicate transaction records

SELECT
    TransactionID,
    COUNT(*) AS DuplicateCount
FROM Fact.FactInventoryTransaction
GROUP BY TransactionID
HAVING COUNT(*) > 1;
GO

-- 4. Checking missing product mappings

SELECT
    th.ProductID AS MissingProductID
FROM AdventureWorks2025.Production.TransactionHistory AS th
LEFT JOIN Dim.DimProduct AS dp
    ON dp.ProductID = th.ProductID
WHERE dp.ProductKey IS NULL;
GO

-- 5. Checking missing transaction type mappings

SELECT DISTINCT
    th.TransactionType AS MissingTransactionType
FROM AdventureWorks2025.Production.TransactionHistory AS th
LEFT JOIN Dim.DimTransactionType AS dtt
    ON th.TransactionType COLLATE DATABASE_DEFAULT
     = dtt.TransactionTypeCode COLLATE DATABASE_DEFAULT
WHERE dtt.TransactionTypeKey IS NULL;
GO

-- 6. Checking missing transaction date mappings

SELECT
    th.TransactionID,
    th.TransactionDate AS MissingTransactionDate
FROM AdventureWorks2025.Production.TransactionHistory AS th
LEFT JOIN Dim.DimDate AS dd
    ON dd.FullDate = CONVERT(date, th.TransactionDate)
WHERE dd.DateKey IS NULL;
GO

-- 7. Checking NULL keys and transaction mappings

SELECT *
FROM Fact.FactInventoryTransaction
WHERE TransactionID IS NULL
   OR ProductKey IS NULL
   OR TransactionTypeKey IS NULL
   OR TransactionDateKey IS NULL
   OR Quantity IS NULL
   OR ActualCost IS NULL;
GO