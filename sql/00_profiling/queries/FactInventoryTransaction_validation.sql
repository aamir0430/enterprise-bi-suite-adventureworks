USE EnterpriseBI_DW
GO

-- Validation of FactInventoryTransaction table:

-- 1. Checking row count and key uniqueness
SELECT
    COUNT(*) AS TotalRows,
    COUNT(DISTINCT InventoryTransactionKey) AS DistinctInventoryKeys,
    COUNT(DISTINCT TransactionID) AS DistinctTransactionIDs,
    COUNT(DISTINCT ProductKey) AS DistinctProducts,
    COUNT(DISTINCT TransactionTypeKey) AS DistinctTransactionTypes,
    COUNT(DISTINCT TransactionDateKey) AS DistinctTransactionDates
FROM Fact.FactInventoryTransaction;

-- 2. Checking duplicate transaction IDs
SELECT
    TransactionID,
    COUNT(*) AS DuplicateCount
FROM Fact.FactInventoryTransaction
GROUP BY TransactionID
HAVING COUNT(*) > 1;

-- 3. Checking missing values
SELECT *
FROM Fact.FactInventoryTransaction
WHERE InventoryTransactionKey IS NULL
   OR TransactionID IS NULL
   OR ProductKey IS NULL
   OR TransactionTypeKey IS NULL
   OR TransactionDateKey IS NULL
   OR ReferenceOrderID IS NULL
   OR ReferenceOrderLineID IS NULL
   OR Quantity IS NULL
   OR ActualCost IS NULL;

-- 4. Validating product relationships
SELECT F.ProductKey
FROM Fact.FactInventoryTransaction F
LEFT JOIN Dim.DimProduct D
    ON F.ProductKey = D.ProductKey
WHERE D.ProductKey IS NULL;

-- 5. Validating transaction type relationships
SELECT F.TransactionTypeKey
FROM Fact.FactInventoryTransaction F
LEFT JOIN Dim.DimTransactionType D
    ON F.TransactionTypeKey = D.TransactionTypeKey
WHERE D.TransactionTypeKey IS NULL;

-- 6. Validating date relationships
SELECT F.TransactionDateKey
FROM Fact.FactInventoryTransaction F
LEFT JOIN Dim.DimDate D
    ON F.TransactionDateKey = D.DateKey
WHERE D.DateKey IS NULL;

-- 7. Inspecting transaction type distribution
SELECT
    D.TransactionTypeCode,
    D.TransactionTypeName,
    COUNT(*) AS TransactionCount,
    SUM(F.Quantity) AS TotalQuantity,
    SUM(F.ActualCost) AS TotalActualCost
FROM Fact.FactInventoryTransaction F
INNER JOIN Dim.DimTransactionType D
    ON F.TransactionTypeKey = D.TransactionTypeKey
GROUP BY
    D.TransactionTypeCode,
    D.TransactionTypeName
ORDER BY D.TransactionTypeCode;

-- 8. Inspecting quantity and cost ranges
SELECT
    MIN(Quantity) AS MinimumQuantity,
    MAX(Quantity) AS MaximumQuantity,
    SUM(CASE WHEN Quantity < 0 THEN 1 ELSE 0 END) AS NegativeQuantityRows,
    SUM(CASE WHEN Quantity = 0 THEN 1 ELSE 0 END) AS ZeroQuantityRows,
    MIN(ActualCost) AS MinimumActualCost,
    MAX(ActualCost) AS MaximumActualCost,
    SUM(CASE WHEN ActualCost < 0 THEN 1 ELSE 0 END) AS NegativeCostRows,
    SUM(CASE WHEN ActualCost = 0 THEN 1 ELSE 0 END) AS ZeroCostRows
FROM Fact.FactInventoryTransaction;